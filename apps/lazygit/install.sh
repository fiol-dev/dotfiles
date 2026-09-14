#!/usr/bin/env bash
# lazygit-git (AUR) tracks upstream's latest commit; it conflicts with
# the stable extra/lazygit package, removed below if present.
set -euo pipefail

if pacman -Qq lazygit &>/dev/null; then
  echo "Removing stable 'lazygit' (extra repo) before installing lazygit-git..."
  sudo pacman -R --noconfirm lazygit
fi

yay -S --needed lazygit-git

echo
echo "✓ lazygit: $(lazygit --version 2>/dev/null || echo 'installed')"
