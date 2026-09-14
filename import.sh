#!/usr/bin/env bash
# Copies tracked config FROM this repo INTO $HOME. No symlinks — every
# import is a real copy, so the live files always work even if the repo
# moves, gets deleted, or the machine loses network.
#
# Every group gets backed up in full before it's touched, and you're
# asked to confirm before anything changes (pass -y/--yes to skip both
# the confirmation and just go, e.g. from bootstrap.sh or a fresh-machine
# unattended run — the backup still happens either way).
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

# Back up every $HOME path a group touches, whether or not it's about to
# change — unconditional, up front, before anything in the group is
# copied. This is what makes it safe to import into a machine whose
# config is in some unknown/mangled state: there's always a full,
# untouched snapshot of what was there, including files this repo
# doesn't track (e.g. caelestia/monitors/ living next to caelestia/cli.json).
backup_group() {
  local group="$1"
  local entries_var="GROUP_${group}[@]"
  local -A parent_dirs=()
  local -A standalone=()
  for entry in "${!entries_var}"; do
    local home_rel="${entry#*:}"
    local parent
    parent="$(dirname "$home_rel")"
    # Only back up a parent directory in full when it's dedicated to one
    # app (2+ path segments under $HOME, e.g. .config/caelestia) — that's
    # what safely catches untracked siblings like caelestia/monitors/. A
    # shallower parent ("." for a bare top-level file like .bashrc, or
    # ".config" for a file living directly under it, like
    # codium-flags.conf) is shared by every other app on the machine, so
    # "back up the parent" there would mean copying all of $HOME or all
    # of ~/.config. Back up the specific file instead.
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

  # -L check matters even when content matches: a leftover symlink from
  # the old symlink-based install.sh would otherwise be left in place
  # forever (same content, so diff sees no difference) instead of being
  # converted to a real, independent copy — which is the whole point.
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
