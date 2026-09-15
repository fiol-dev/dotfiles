#!/usr/bin/env bash
# discord — official [extra] repo package, no AUR needed.
set -euo pipefail

sudo pacman -S --needed discord

echo
echo "✓ discord installed."
