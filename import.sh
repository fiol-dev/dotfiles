#!/usr/bin/env bash
# Copies tracked config from this repo into $HOME as real files.
#
# For each group: back it up, ask for confirmation, then copy.
# -y/--yes skips the confirmation; the backup still runs.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/lib/ui.sh"
source "$DOTFILES_DIR/lib/targets.sh"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

ASSUME_YES=false
for arg in "$@"; do
  [[ "$arg" == "-y" || "$arg" == "--yes" ]] && ASSUME_YES=true
done

confirm() {
  $ASSUME_YES && return 0
  local reply
  read -r -p "$1 [Y/n] " reply
  [[ -z "$reply" || "$reply" =~ ^[Yy]$ ]]
}

# Backs up every $HOME path a group touches, before any of it is copied.
backup_group() {
  local group="$1"
  local entries_var="GROUP_${group}[@]"
  local -A parent_dirs=()
  local -A standalone=()
  for entry in "${!entries_var}"; do
    local home_rel="${entry#*:}"
    local parent
    parent="$(dirname "$home_rel")"
    # Parent directories with 2+ path segments under $HOME (e.g.
    # .config/caelestia) are backed up in full. Shallower parents ("."
    # for .bashrc, ".config" for codium-flags.conf) are backed up as the
    # single file instead.
    if [[ "$parent" != */* ]]; then
      standalone["$home_rel"]=1
    else
      parent_dirs["$parent"]=1
    fi
  done
  for dir in "${!parent_dirs[@]}"; do
    local src="$HOME/$dir"
    [[ -e "$src" ]] || continue
    mkdir -p "$BACKUP_DIR/$dir"
    cp -r "$src/." "$BACKUP_DIR/$dir/" 2>/dev/null || true
  done
  for f in "${!standalone[@]}"; do
    local src="$HOME/$f"
    [[ -e "$src" || -L "$src" ]] || continue
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp -r "$src" "$BACKUP_DIR/$f" 2>/dev/null || true
  done
}

import_one() {
  local repo_rel="$1" home_rel="$2"
  local src="$DOTFILES_DIR/$repo_rel"
  local dest="$HOME/$home_rel"

  if [[ ! -e "$src" ]]; then
    ui_skip "missing in repo: $repo_rel"
    return
  fi

  # A symlink is always replaced with a real copy, even if its content
  # already matches.
  if [[ -e "$dest" && ! -L "$dest" ]] && diff -rq "$src" "$dest" &>/dev/null; then
    ui_ok "up to date: $home_rel"
    return
  fi

  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  cp -r "$src" "$dest"
  ui_changed "imported: $home_rel"
}

for group in "${TARGET_GROUPS[@]}"; do
  ui_header "${GROUP_LABEL[$group]}"
  if confirm "Import this group?"; then
    backup_group "$group"
    entries_var="GROUP_${group}[@]"
    for entry in "${!entries_var}"; do
      import_one "${entry%%:*}" "${entry#*:}"
    done
  else
    ui_skip "declined — group left untouched"
  fi
done

ui_header "Wallpapers (excluding Animated/)"
if [[ -d "$DOTFILES_DIR/home/Pictures/Wallpapers" ]]; then
  if confirm "Import wallpapers?"; then
    if [[ -e "$HOME/Pictures/Wallpapers" ]]; then
      mkdir -p "$BACKUP_DIR/Pictures/Wallpapers"
      find "$HOME/Pictures/Wallpapers" -maxdepth 1 -type f -exec cp -t "$BACKUP_DIR/Pictures/Wallpapers/" {} + 2>/dev/null || true
    fi
    while IFS= read -r -d '' f; do
      name="$(basename "$f")"
      import_one "home/Pictures/Wallpapers/$name" "Pictures/Wallpapers/$name"
    done < <(find "$DOTFILES_DIR/home/Pictures/Wallpapers" -maxdepth 1 -type f -print0)
  else
    ui_skip "declined — wallpapers left untouched"
  fi
else
  ui_skip "no wallpapers tracked in repo"
fi

ui_header "Done"
if [[ -d "$BACKUP_DIR" ]]; then
  echo "Backups: $BACKUP_DIR"
fi

if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl &>/dev/null; then
  echo "Reloading Hyprland config (hyprctl reload)..."
  hyprctl reload
else
  echo "(hyprctl reload skipped — Hyprland isn't running in this session)"
fi

echo "Restart fish (or 'exec fish') to pick up shell changes."
