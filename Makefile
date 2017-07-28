GOPATH := $(shell pwd)/vendor/
export GOPATH

PROJECT=burdz/hello-dockerhub-manifest
TAG=dev
FOLDER_DEST=github.com/burdzwastaken

get:
	go get -d github.com/gorilla/websocket

fmt:
	go fmt ./...

build:
	docker build . -t ${PROJECT}:${TAG}

push-dev:
	docker push -t ${PROJECT}:${TAG}

godep:
	godep save ./...