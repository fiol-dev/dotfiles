#!/usr/bin/env bash
# Two-way sync of the safe, non-secret subset of PyCharm's config
# (keymaps, colors, codestyles, templates, fileTemplates) between the live
# config dir and this repo.
#
# PyCharm's config dir is version-suffixed (~/.config/JetBrains/PyCharm<ver>/)
# and gets superseded on every IDE update, so this can't be a plain symlink
# like the rest of this repo — `export` after you customize something,
# `apply` after a fresh install or once a new version dir shows up.
#
# NOT included: options/ (jdk.table.xml has local SDK paths,
# recentProjects.xml/trusted-paths.xml leak local project paths,
# databaseDrivers.xml/databaseSettings.xml/gitlab.xml can hold connection
# strings or auth state), pycharm.key (license), workspace/, ssl/, tasks/.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config"
LIVE_DIR="$(find "$HOME/.config/JetBrains" -maxdepth 1 -iname 'PyCharm*' -type d 2>/dev/null | sort -V | tail -n1)"
SUBDIRS=(keymaps colors codestyles templates fileTemplates)

usage() {
  echo "Usage: $(basename "$0") export   # live config -> this repo (after customizing something)"
  echo "       $(basename "$0") apply    # this repo -> live config (new machine / after an IDE update)"
  exit 1
}

[[ $# -eq 1 ]] || usage

if [[ -z "$LIVE_DIR" ]]; then
  echo "No ~/.config/JetBrains/PyCharm*/ found — launch PyCharm at least once first."
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
    echo "Review with: cd ~/dotfiles && git diff --stat -- apps/pycharm/config"
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
    echo "Restart PyCharm to pick these up."
    ;;
  *) usage ;;
esac
