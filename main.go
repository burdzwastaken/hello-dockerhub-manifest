package main

import (
	b64 "encoding/base64"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/gorilla/websocket"
)

var (
	authURL  = getenv("DOCKER_AUTH_URL")
	url      = getenv("DOCKER_URL")
	username = getenv("DOCKER_USERNAME")
	password = getenv("DOCKER_PASSWORD")
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

const (
	port = ":8080"
)

type authResponse struct {
	Token       string    `json:"token"`
	AccessToken string    `json:"access_token"`
	ExpiresIn   int       `json:"expires_in"`
	IssuedAt    time.Time `json:"issued_at"`
}

func getenv(name string) string {
	v := os.Getenv(name)
	if v == "" {
		panic("missing required environment variable " + name)
	}
	return v
}

func authToken(image string) string {
	req, err := http.NewRequest("GET", authURL+"token?service=registry.docker.io&scope=repository:"+image+":pull", nil)
	if err != nil {
		log.Fatal("NewRequest: ", err)
	}

	credentials := username + ":" + password
	credentialsEncoded := b64.StdEncoding.EncodeToString([]byte(credentials))

	req.Header.Set("content-type", "application/json")
	req.Header.Set("X-Docker-Token", "True")
	req.Header.Set("Authorization", "Basic "+credentialsEncoded)

	client := &http.Client{}
	respAuth, err := client.Do(req)
	if err != nil {
		log.Fatal("NewRequest: ", err)
	}

	defer respAuth.Body.Close()

	var response authResponse

	if err := json.NewDecoder(respAuth.Body).Decode(&response); err != nil {
		log.Println(err)
	}

	return response.Token
}

func getManifest(msg []byte) []byte {
	imageString := string(msg)
	imageMap := strings.Split(imageString, ":")

	image := imageMap[0]
	tag := imageMap[1]

	token := authToken(image)

	req, err := http.NewRequest("GET", url+"v2/"+image+"/manifests/"+tag, nil)
	if err != nil {
		log.Fatal("NewRequest: ", err)
	}
	req.Header.Set("Accept", "application/vnd.docker.distribution.manifest.list.v2+json")
	req.Header.Set("Authorization", "Bearer "+token)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Fatal("NewRequest: ", err)
	}

	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)

	return body
}

func main() {

	http.HandleFunc("/search", func(w http.ResponseWriter, r *http.Request) {
		conn, _ := upgrader.Upgrade(w, r, nil)
		for {
			msgType, msg, err := conn.ReadMessage()
			if err != nil {
				return
			}

			fmt.Printf("%s sent: %s\n", conn.RemoteAddr(), string(msg))

			body := getManifest(msg)

			if err = conn.WriteMessage(msgType, body); err != nil {
				return
			}
		}
	})

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "websockets.html")
	})

	http.ListenAndServe(port, nil)

}
