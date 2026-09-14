#!/usr/bin/env bash
# VSCodium: AUR install + Microsoft marketplace shim + extension restore.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "Installing vscodium-bin + marketplace shim..."
yay -S --needed vscodium-bin vscodium-bin-marketplace

# vscodium-bin-marketplace patches product.json so the Extensions view
# talks to marketplace.visualstudio.com instead of open-vsx.org, which is
# what lets extensions like the caelestia theme integration resolve.

if command -v codium &>/dev/null; then
  echo
  echo "Restoring extensions from apps/vscodium/extensions.txt..."
  while read -r ext; do
    [[ -z "$ext" || "$ext" == \#* ]] && continue
    codium --install-extension "$ext" || echo "  ! failed: $ext"
  done < "$DOTFILES_DIR/apps/vscodium/extensions.txt"
else
  echo "codium not on PATH yet — re-run this script after a shell restart to restore extensions."
fi

echo
echo "settings.json / keybindings.json are managed by dotfiles/install.sh (symlinked)."
