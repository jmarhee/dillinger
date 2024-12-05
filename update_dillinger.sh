#!/bin/bash

function pullReplace () {
	podman rm -f dillinger && \
	cd $HOME/repos/dillinger && \
	git pull origin master && \
	export VERSION=$(cat package.json | jq -r .version) && \
	podman build -t jmarhee/dillinger:$VERSION . && \
	podman run -d -p 0.0.0.0:8000:8080 --restart=always --cap-add=SYS_ADMIN --name=dillinger jmarhee/dillinger:$VERSION
}

function pushReplace () {
	export VERSION=$(cat package.json | jq -r .version) && \
	podman tag jmarhee/dillinger:$VERSION ghcr.io/jmarhee/dillinger:$VERSION && \
	podman push ghcr.io/jmarhee/dillinger:$VERSION
}

cd $HOME/repos/dillinger && \
git fetch origin

if [[ -z $(git rev-list --count HEAD..@{u}) ]]; then
  echo "Repository is up-to-date."
  if $1 == "--force"; then
    pullReplace && \
    echo "Updating Docker image" && \
    pushReplace
    exit 0
  fi
  exit 0
else
  echo "Repository is not up-to-date."
  pullReplace && \
  echo "Updating Docker image" && \
  pushReplace
  exit 0
fi
