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

TARGET_PKG=caelestia-sddm-minimalistv2-git

# minimalist/minimalistV2/locklike all install to the same path
# (/usr/share/sddm/themes/caelestia) and conflict with each other, but
# none of them is literally a package named "caelestia-sddm" — that's
# just the virtual name each one `provides`. Ask pacman which real
# package currently provides it (if any), and only remove it if that's
# not already the target — `pacman -R` can't resolve a virtual name on
# its own, and `-Qq caelestia-sddm` would otherwise resolve straight to
# TARGET_PKG on an idempotent re-run.
current_provider="$(pacman -Qq caelestia-sddm 2>/dev/null || true)"
if [[ -n "$current_provider" && "$current_provider" != "$TARGET_PKG" ]]; then
  echo "Removing conflicting theme variant: $current_provider"
  sudo pacman -R --noconfirm "$current_provider"
fi

echo "Installing $TARGET_PKG from AUR..."
yay -S --needed --noconfirm --answerclean None --answerdiff None --answeredit None "$TARGET_PKG"

# The package's own post-install hook already:
#  - writes /etc/sddm.conf.d/caelestia.conf -> [Theme] Current=caelestia
#  - copies theme.conf.template to ~/.config/caelestia/templates/sddm-theme.conf
#    (this repo tracks that file — run import.sh to bring in the tracked
#    version, or export.sh to capture whatever the package wrote)
# cli.json (also tracked by this repo) already has the wallpaper/theme
# postHook wired to "$SYNC_SCRIPT --posthook", so color sync works as soon
# as cli.json is imported.

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
