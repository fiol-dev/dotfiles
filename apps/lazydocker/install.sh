#!/usr/bin/env bash
# lazydocker — now in the official [extra] repo, no AUR needed.
set -euo pipefail

sudo pacman -S --needed lazydocker

echo
echo "Run 'lazydocker' as your normal user (needs the 'docker' group from"
echo "apps/docker/install.sh, not sudo)."
