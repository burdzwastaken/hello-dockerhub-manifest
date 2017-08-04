# hello-dockerhub-manifest
A small web application to query a manifest of a docker image stored within dockerhub

## run
build the container and helm chart:
```
make 
```
run the container with required variables (default auth, URL included):
```
docker run --rm \
-p 8080:8080 \
-e DOCKER_AUTH_URL=https://auth.docker.io/ \
-e DOCKER_URL=https://registry-1.docker.io/ \
-e DOCKER_USERNAME= \
-e DOCKER_PASSWORD= \
burdz/hello-dockerhub-manifest:dev
```