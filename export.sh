#!/usr/bin/env bash
# Copies live config FROM $HOME INTO this repo, grouped, with a summary at
# the end. Never touches git for you — review with `git diff`, then commit
# and push yourself. The other half of this is import.sh.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/lib/ui.sh"
source "$DOTFILES_DIR/lib/targets.sh"

CHANGED=0

export_one() {
  local repo_rel="$1" home_rel="$2"
  local src="$HOME/$home_rel"
  local dest="$DOTFILES_DIR/$repo_rel"

  if [[ ! -e "$src" ]]; then
    ui_skip "not present on this machine: $home_rel"
    return
  fi

  if [[ -e "$dest" ]] && diff -rq "$src" "$dest" &>/dev/null; then
    ui_ok "unchanged: $home_rel"
    return
  fi

  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  cp -r "$src" "$dest"
  ui_changed "exported: $home_rel"
  CHANGED=$((CHANGED + 1))
}

for group in "${TARGET_GROUPS[@]}"; do
  ui_header "${GROUP_LABEL[$group]}"
  entries_var="GROUP_${group}[@]"
  for entry in "${!entries_var}"; do
    export_one "${entry%%:*}" "${entry#*:}"
  done
done

ui_header "Wallpapers (excluding Animated/)"
if [[ -d "$HOME/Pictures/Wallpapers" ]]; then
  mkdir -p "$DOTFILES_DIR/home/Pictures/Wallpapers"
  while IFS= read -r -d '' f; do
    name="$(basename "$f")"
    dest="$DOTFILES_DIR/home/Pictures/Wallpapers/$name"
    if [[ -e "$dest" ]] && cmp -s "$f" "$dest"; then
      continue
    fi
    cp "$f" "$dest"
    ui_changed "exported: Pictures/Wallpapers/$name"
    CHANGED=$((CHANGED + 1))
  done < <(find "$HOME/Pictures/Wallpapers" -maxdepth 1 -type f -print0)
else
  ui_skip "~/Pictures/Wallpapers not present on this machine"
fi

ui_header "Summary"
if [[ "$CHANGED" -eq 0 ]]; then
  ui_ok "Nothing changed — repo already matches this machine."
else
  ui_warn "$CHANGED path(s) updated in the repo."
  echo
  echo "Review:  cd $DOTFILES_DIR && git status --short && git diff --stat"
  echo "Commit:  git add -A && git commit -m '...'"
  echo "Publish: git push"
fi
