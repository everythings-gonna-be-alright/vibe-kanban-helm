#!/bin/bash
set -euo pipefail

read -rp "REMOTE_SERVER_TAG [remote-v0.1.22]: " REMOTE_SERVER_TAG
REMOTE_SERVER_TAG="${REMOTE_SERVER_TAG:-remote-v0.1.22}"

read -rp "WORKER_TAG [v0.1.30]: " WORKER_TAG
WORKER_TAG="${WORKER_TAG:-v0.1.30}"

read -rp "DOCKER_REGISTRY [your-registry]: " DOCKER_REGISTRY
DOCKER_REGISTRY="${DOCKER_REGISTRY:-your-registry}"

read -rp "VITE_RELAY_API_BASE_URL [https://relay.your-domain.com]: " VITE_RELAY_API_BASE_URL
VITE_RELAY_API_BASE_URL="${VITE_RELAY_API_BASE_URL:-https://relay.your-domain.com}"

git clone --branch ${REMOTE_SERVER_TAG} https://github.com/BloopAI/vibe-kanban.git /tmp/vibe-kanban

# Build remote server image
docker build \
  --build-arg VITE_RELAY_API_BASE_URL=${VITE_RELAY_API_BASE_URL} \
  -t ${DOCKER_REGISTRY}/vibe-kanban:${REMOTE_SERVER_TAG} \
  -f /tmp/vibe-kanban/crates/remote/Dockerfile \
  /tmp/vibe-kanban

docker push ${DOCKER_REGISTRY}/vibe-kanban:${REMOTE_SERVER_TAG}

# Build relay image
docker build \
  -t ${DOCKER_REGISTRY}/vibe-kanban:relay-${REMOTE_SERVER_TAG} \
  -f /tmp/vibe-kanban/crates/relay-tunnel/Dockerfile \
  /tmp/vibe-kanban

docker push ${DOCKER_REGISTRY}/vibe-kanban:relay-${REMOTE_SERVER_TAG}


# Build worker image
docker build \
  --build-arg WORKER_TAG=${WORKER_TAG} \
  -t ${DOCKER_REGISTRY}/vibe-kanban:worker-${WORKER_TAG} \
  -f Dockerfile-worker \
  .

docker push ${DOCKER_REGISTRY}/vibe-kanban:worker-${WORKER_TAG}