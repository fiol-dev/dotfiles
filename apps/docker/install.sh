#!/usr/bin/env bash
# Docker Engine + Compose v2 + BuildKit (buildx), per the Arch wiki:
# https://wiki.archlinux.org/title/Docker
set -euo pipefail

echo "Installing docker, docker-compose, docker-buildx..."
sudo pacman -S --needed docker docker-compose docker-buildx

echo "Enabling + starting docker.service..."
sudo systemctl enable --now docker.service

if getent group docker | grep -qw "$USER"; then
  echo "✓ $USER already in the 'docker' group"
else
  echo "Adding $USER to the 'docker' group..."
  sudo usermod -aG docker "$USER"
  echo "! Group membership needs a new login session to take effect:"
  echo "    log out/in, or run: newgrp docker"
fi

cat <<'EOF'

Compose: docker-compose installs BOTH the standalone `docker-compose`
binary and the `docker compose` CLI plugin (/usr/lib/docker/cli-plugins/) —
same package, use either.

BuildKit: docker-buildx registers `docker buildx build`. BuildKit is the
default builder on Docker 23+, so plain `docker build` already uses it;
DOCKER_BUILDKIT=1 is only needed if you're pinned to the legacy builder
for some reason.

Verify everything works: docker run hello-world
EOF
