#!/usr/bin/env make -f

SHELL := /bin/bash

PACKAGE       := github.com/burdzwastaken/hello-dockerhub-manifest
DISTNAME      := hello-dockerhub-manifest
VERSION       := 0.1.0
UPSTREAM      := upstream/master
PROJECT       := burdz/hello-dockerhub-manifest
TAG           := dev

default: all

.PHONY: all
all: fmt lint build push helm-package

.PHONY: fmt
fmt:
	go fmt ./...

.PHONY: build
build:
	docker build --rm -t ${PROJECT}:${TAG} .

.PHONY: push
push:
	docker push ${PROJECT}:${TAG}

.PHONY: godep-save
godep-save:
	godep save ./...

.PHONY: helm-package
helm-package:
	helm package --version ${VERSION} deploy/${DISTNAME}

.PHONY: helm-deploy
helm-deploy:
	helm install ${DISTNAME}-${VERSION}.tgz

.PHONY: lint
lint:
		go get -u github.com/alecthomas/gometalinter
		gometalinter --install --update
		gometalinter          \
		--enable-gc           \
		--deadline 40s        \
		--exclude bindata     \
		--exclude .pb.        \
		--exclude vendor      \
		--skip vendor         \
		--disable-all         \
		--enable=errcheck     \
		--enable=goconst      \
		--enable=gofmt        \
		--enable=golint       \
		--enable=gosimple     \
		--enable=ineffassign  \
		--enable=gotype       \
		--enable=misspell     \
		--enable=vet          \
		--enable=vetshadow    \
		./...