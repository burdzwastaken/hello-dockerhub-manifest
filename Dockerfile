# build stage
FROM golang:alpine AS build-env
ADD . /src
WORKDIR /src
ENV GOPATH /src
RUN GOOS=linux GOARCH=amd64 go build -o ./bin/hello-dockerhub-manifest main.go

FROM alpine
RUN apk update && apk add ca-certificates
COPY --from=build-env src/bin/hello-dockerhub-manifest /app/
COPY ./websockets.html /app/
EXPOSE 8080
WORKDIR /app/
ENTRYPOINT ./hello-dockerhub-manifest

LABEL maintainer "Matt Burdan <burdz@burdz.net>"