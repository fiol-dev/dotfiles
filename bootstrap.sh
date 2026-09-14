#!/usr/bin/env bash
# Interactive menu to (re)install the apps covered by this dotfiles repo.
# Each app also has its own apps/<name>/install.sh you can run standalone.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

apps=(vscodium google-chrome android-studio amneziavpn pycharm)

echo "Caelestia dotfiles bootstrap"
echo "============================"
select choice in "${apps[@]}" "all" "quit"; do
  case "$choice" in
    all)
      for a in "${apps[@]}"; do
        echo; echo ">>> $a"; bash "$DOTFILES_DIR/apps/$a/install.sh"
      done
      break
      ;;
    quit) break ;;
    "") echo "Invalid choice." ;;
    *)
      bash "$DOTFILES_DIR/apps/$choice/install.sh"
      break
      ;;
  esac
done

echo
echo "Now symlink configs with: bash $DOTFILES_DIR/install.sh"
