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
  "home/.config/caelestia/cli.json:.config/caelestia/cli.json"
  "home/.config/caelestia/shell.json:.config/caelestia/shell.json"
  "home/.config/caelestia/hypr-user.lua:.config/caelestia/hypr-user.lua"
  "home/.config/caelestia/hypr-vars.lua:.config/caelestia/hypr-vars.lua"
  "home/.config/caelestia/user-config.fish:.config/caelestia/user-config.fish"
  "home/.config/caelestia/templates:.config/caelestia/templates"
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

# Wallpapers: individual files, not the whole directory — this repo tracks
# the static PNG/JPG set but not ~/Pictures/Wallpapers/Animated/ (untracked,
# ~380MB of third-party video wallpapers), so a directory-level symlink
# would either drag Animated/ into the repo or wipe it out on backup, same
# problem caelestia/monitors/ had.
if [[ -d "$DOTFILES_DIR/home/Pictures/Wallpapers" ]]; then
  while IFS= read -r -d '' f; do
    name="$(basename "$f")"
    link_one "home/Pictures/Wallpapers/$name" "Pictures/Wallpapers/$name"
  done < <(find "$DOTFILES_DIR/home/Pictures/Wallpapers" -maxdepth 1 -type f -print0)
fi

echo
if [[ -d "$BACKUP_DIR" ]]; then
  echo "Pre-existing files were moved to: $BACKUP_DIR"
fi

if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl &>/dev/null; then
  echo "Reloading Hyprland config (hyprctl reload)..."
  hyprctl reload
else
  echo "(hyprctl reload skipped — Hyprland isn't running in this session)"
fi

echo "Done. Restart fish (or 'exec fish') to pick up shell changes."
