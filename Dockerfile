# build stage
FROM golang:alpine AS build-env
ADD . /src
WORKDIR /src
ENV GOPATH /src
RUN GOOS=linux GOARCH=amd64 go build -o ./bin/dockerhub main.go

FROM alpine
RUN apk update && apk add ca-certificates
COPY --from=build-env src/bin/dockerhub /app/
COPY ./websockets.html /app/
EXPOSE 8080
WORKDIR /app/
ENTRYPOINT ./dockerhub

MAINTAINER Matt Burdan <burdz@burdz.net>