#!/usr/bin/env bash
# google-chrome from AUR + Wayland/Hyprland launch flags.
set -euo pipefail

echo "Installing google-chrome from AUR..."
yay -S --needed google-chrome

bash "$(dirname "${BASH_SOURCE[0]}")/theme.sh"
