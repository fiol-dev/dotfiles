#!/usr/bin/env bash
# Android Studio from AUR + emulator hardware-acceleration check.
set -euo pipefail

echo "Installing android-studio from AUR (this is a large download)..."
yay -S --needed android-studio

echo
if [[ -e /dev/kvm ]]; then
  echo "✓ /dev/kvm present — emulator can use hardware acceleration."
else
  echo "! /dev/kvm not found. For a usable emulator, run:"
  echo "    sudo pacman -S --needed qemu-full"
  echo "    sudo usermod -aG kvm \$USER   # then log out/in"
fi

if ! groups | grep -qw kvm; then
  echo "! Your user isn't in the 'kvm' group yet (needed for AVDs)."
  echo "    sudo usermod -aG kvm \$USER   # then log out/in"
fi

echo
echo "Android Studio itself bundles its own JBR JDK, so no separate JDK install is needed."
echo "First run: Android Studio > More Actions > SDK Manager to grab platform-tools/emulator."

cat <<'EOF'

This machine's existing Android Studio install came from JetBrains
Toolbox (~/.local/share/JetBrains/Toolbox/apps/android-studio), not this
AUR package.

After first launch, pull in the tracked
keymaps/colors/codestyles/templates/fileTemplates with:
  apps/android-studio/sync-config.sh apply
EOF
