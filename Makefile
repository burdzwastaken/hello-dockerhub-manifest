PACKAGE       := github.com/burdzwastaken/hello-dockerhub-manifest
DISTNAME      := hello-dockerhub-manifest
VERSION       := 0.1.0
UPSTREAM      := upstream/master
PROJECT       := burdz/hello-dockerhub-manifest
TAG           := dev

GOPATH := $(shell pwd)/
export GOPATH

.PHONY: fmt
fmt:
	go fmt ./...

.PHONY: build
build:
	docker build . -t ${PROJECT}:${TAG}

.PHONY: push
push-dev:
	docker push -t ${PROJECT}:${TAG}

.PHONY: godep-save
godep-save:
	godep save ./...

.PHONY: godep-restore
godep-restore:
	godep restore

.PHONY: helm-package
helm-package:
	helm package --version ${VERSION} deploy/${DISTNAME}

.PHONY: helm-deploy
helm-deploy:
	helm install hello-dockerhub-manifest-${VERSION}.tgz