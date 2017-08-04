# buildTime
FROM golang:alpine AS build-env
ADD . /src
WORKDIR /src
ENV GOPATH /src
RUN apk update && apk upgrade && \
    apk add --no-cache git
RUN go get github.com/tools/godep && bin/godep restore
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -a -installsuffix cgo -o ./bin/hello-dockerhub-manifest .

# runTime
FROM alpine
RUN apk update && apk add ca-certificates
COPY --from=build-env src/bin/hello-dockerhub-manifest /app/
COPY ./websockets.html /app/
EXPOSE 8080
WORKDIR /app/
ENTRYPOINT ./hello-dockerhub-manifest

LABEL maintainer "Matt Burdan <burdz@burdz.net>"