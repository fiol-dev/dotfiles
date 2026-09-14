#!/usr/bin/env bash
# Two-way sync of the safe, non-secret subset of Android Studio's config
# (keymaps, colors, codestyles, templates, fileTemplates) between the live
# config dir and this repo.
#
# Finds the current ~/.config/Google/AndroidStudio<ver>/ dir (the exact
# name changes with each IDE update). `export` after customizing
# something, `apply` after a fresh install or a new version dir.
#
# NOT included: options/ (jdk.table.xml has local SDK paths,
# recentProjects.xml/trusted-paths.xml leak local project paths,
# github.xml/gitlab.xml/googleLoginApplicationSettings.xml can hold auth
# state), pycharm.key-style license files, workspace/, ssl/, tasks/.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config"
LIVE_DIR="$(find "$HOME/.config/Google" -maxdepth 1 -iname 'AndroidStudio*' -type d 2>/dev/null | sort -V | tail -n1)"
SUBDIRS=(keymaps colors codestyles templates fileTemplates)

usage() {
  echo "Usage: $(basename "$0") export   # live config -> this repo (after customizing something)"
  echo "       $(basename "$0") apply    # this repo -> live config (new machine / after an IDE update)"
  exit 1
}

[[ $# -eq 1 ]] || usage

if [[ -z "$LIVE_DIR" ]]; then
  echo "No ~/.config/Google/AndroidStudio*/ found — launch Android Studio at least once first."
  exit 1
fi
echo "Live config dir: $LIVE_DIR"

case "$1" in
  export)
    for d in "${SUBDIRS[@]}"; do
      if [[ -d "$LIVE_DIR/$d" ]]; then
        rm -rf "$REPO_DIR/$d"
        mkdir -p "$REPO_DIR/$d"
        cp -r "$LIVE_DIR/$d/." "$REPO_DIR/$d/"
        echo "✓ exported $d"
      fi
    done
    echo
    echo "Review with: cd ~/dotfiles && git diff --stat -- apps/android-studio/config"
    echo "Then commit."
    ;;
  apply)
    for d in "${SUBDIRS[@]}"; do
      if [[ -d "$REPO_DIR/$d" ]]; then
        mkdir -p "$LIVE_DIR/$d"
        cp -r "$REPO_DIR/$d/." "$LIVE_DIR/$d/"
        echo "✓ applied $d"
      fi
    done
    echo "Restart Android Studio to pick these up."
    ;;
  *) usage ;;
esac
