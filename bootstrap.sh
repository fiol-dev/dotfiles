#!/usr/bin/env bash
# Interactive menu to (re)install the apps covered by this dotfiles repo.
# Each app also has its own apps/<name>/install.sh you can run standalone.
#
# Usage:
#   bash bootstrap.sh          interactive: pick numbers, or blank for all
#   bash bootstrap.sh 1 3 5    non-interactive: install just those
#   bash bootstrap.sh all      install everything, no prompt
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/lib/ui.sh"

apps=(homebrew claude-code vscodium google-chrome android-studio amneziavpn pycharm lazygit docker lazydocker sddm)

# rsync is a hard dependency of the sshput/sshget/sshsync fish functions —
# ensure it's present regardless of which app below gets picked.
if ! command -v rsync &>/dev/null; then
  ui_warn "Installing rsync (required by the sshput/sshget/sshsync fish functions)..."
  sudo pacman -S --needed rsync
fi

ui_header "Caelestia dotfiles bootstrap"
for i in "${!apps[@]}"; do
  printf "  %2d) %s\n" "$((i + 1))" "${apps[$i]}"
done
echo

if [[ $# -gt 0 && "$1" != "all" ]]; then
  selection="$*"
elif [[ $# -gt 0 && "$1" == "all" ]]; then
  selection=""
else
  read -r -p "Install which? (space-separated numbers, blank = all): " selection
fi

selected=()
if [[ -z "${selection// /}" ]]; then
  selected=("${apps[@]}")
else
  for n in $selection; do
    if ! [[ "$n" =~ ^[0-9]+$ ]]; then
      ui_err "not a number, skipping: $n"
      continue
    fi
    idx=$((n - 1))
    if [[ $idx -ge 0 && $idx -lt ${#apps[@]} ]]; then
      selected+=("${apps[$idx]}")
    else
      ui_err "no app #$n, skipping"
    fi
  done
fi

if [[ ${#selected[@]} -eq 0 ]]; then
  ui_err "Nothing selected. Exiting."
  exit 1
fi

ui_header "Installing: ${selected[*]}"
for a in "${selected[@]}"; do
  ui_header "$a"
  bash "$DOTFILES_DIR/apps/$a/install.sh"
done

ui_header "Done"
echo "Now bring your config in with: bash $DOTFILES_DIR/import.sh"
