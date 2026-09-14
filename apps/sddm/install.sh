#!/usr/bin/env bash
# SDDM + the caelestia SDDM theme, minimalistV2 variant, from AUR.
# https://github.com/ItsABigIgloo/caelestia-sddm
set -euo pipefail

THEME_DIR=/usr/share/sddm/themes/caelestia
SYNC_SCRIPT="$THEME_DIR/scripts/sync.sh"
SUDOERS_FILE=/etc/sudoers.d/caelestia-sddm-sync
REAL_USER="$(id -un)"

echo "Installing sddm..."
sudo pacman -S --needed sddm

# minimalist/minimalistV2/locklike all install to the same path
# (/usr/share/sddm/themes/caelestia) and conflict with each other.
for other in caelestia-sddm caelestia-sddm-locklike-git caelestia-sddm-minimalist-git; do
  if pacman -Qq "$other" &>/dev/null; then
    echo "Removing conflicting theme variant: $other"
    sudo pacman -R --noconfirm "$other"
  fi
done

echo "Installing caelestia-sddm-minimalistv2-git from AUR..."
yay -S --needed caelestia-sddm-minimalistv2-git

# The package's own post-install hook already:
#  - writes /etc/sddm.conf.d/caelestia.conf -> [Theme] Current=caelestia
#  - copies theme.conf.template to ~/.config/caelestia/templates/sddm-theme.conf
#    (this repo tracks that file — dotfiles/install.sh's symlink takes over
#    if it lands there first, or gets backed up if the package wrote a real
#    file there first; either order is safe)
# cli.json (also tracked by this repo) already has the wallpaper/theme
# postHook wired to "$SYNC_SCRIPT --posthook", so color sync works as soon
# as it's symlinked in.

if [[ -f "$SUDOERS_FILE" ]]; then
  echo "✓ passwordless sudo for sync.sh already configured"
else
  echo "Granting passwordless sudo for $SYNC_SCRIPT (required by the postHook)..."
  tmp=$(mktemp)
  echo "$REAL_USER ALL=(root) NOPASSWD: $SYNC_SCRIPT" > "$tmp"
  sudo visudo -cf "$tmp"
  sudo install -o root -g root -m 0440 "$tmp" "$SUDOERS_FILE"
  rm -f "$tmp"
fi

echo "Running first sync..."
sudo "$SYNC_SCRIPT"

echo "Enabling sddm.service..."
sudo systemctl enable sddm

cat <<EOF

✓ sddm enabled as the display manager.
If it's not already running (fresh install), start it with:
  sudo systemctl start sddm
or just reboot.
EOF
