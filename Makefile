GOPATH := $(shell pwd)/
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

.PHONY: helm-package
helm-package:
	helm package --version 0.1.0 deploy/hello-dockerhub-manifest

helm-deploy:
	helm install hello-dockerhub-manifest-0.1.0.tgz