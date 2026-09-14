#!/usr/bin/env bash
# Symlinks tracked config into $HOME. Idempotent: safe to re-run.
# Existing real files/dirs are backed up (never deleted) before linking.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# repo-relative path : $HOME-relative target
LINKS=(
  "home/.bashrc:.bashrc"
  "home/.config/fish/config.fish:.config/fish/config.fish"
  "home/.config/fish/fish_plugins:.config/fish/fish_plugins"
  "home/.config/fish/functions:.config/fish/functions"
  "home/.config/fish/conf.d:.config/fish/conf.d"
  "home/.config/fish/completions:.config/fish/completions"
  "home/.config/caelestia:.config/caelestia"
  "home/.config/VSCodium/User:.config/VSCodium/User"
  "home/.config/codium-flags.conf:.config/codium-flags.conf"
  "home/.config/google-chrome-flags.conf:.config/google-chrome-flags.conf"
  "home/.claude/settings.json:.claude/settings.json"
  "home/.claude/statusline-command.sh:.claude/statusline-command.sh"
)

link_one() {
  local src="$DOTFILES_DIR/$1"
  local dest="$HOME/$2"

  if [[ ! -e "$src" ]]; then
    echo "skip (missing in repo): $1"
    return
  fi

  mkdir -p "$(dirname "$dest")"

  if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
    echo "= already linked: $2"
    return
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$2")"
    mv "$dest" "$BACKUP_DIR/$2"
    echo "~ backed up existing $2"
  fi

  ln -sfn "$src" "$dest"
  echo "+ linked $2 -> ${src#"$DOTFILES_DIR"/}"
}

for entry in "${LINKS[@]}"; do
  link_one "${entry%%:*}" "${entry#*:}"
done

echo
if [[ -d "$BACKUP_DIR" ]]; then
  echo "Pre-existing files were moved to: $BACKUP_DIR"
fi
echo "Done. Restart fish (or 'exec fish') to pick up shell changes."
