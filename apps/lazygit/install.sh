#!/usr/bin/env bash
# lazygit — official [extra] repo package, no AUR needed.
set -euo pipefail

sudo pacman -S --needed lazygit

echo
echo "✓ lazygit: $(lazygit --version 2>/dev/null || echo 'installed')"
