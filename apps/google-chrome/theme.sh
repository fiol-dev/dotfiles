#!/usr/bin/env bash
# Wires google-chrome into the same Wayland/GTK/caelestia theming that
# codium-flags.conf already gives VSCodium on this system.
set -euo pipefail

FLAGS_FILE="$HOME/.config/google-chrome-flags.conf"

if [[ -e "$FLAGS_FILE" ]]; then
  echo "= $FLAGS_FILE already exists"
  echo "  (run import.sh to bring in the tracked version from this repo, if it differs)"
else
  mkdir -p "$(dirname "$FLAGS_FILE")"
  cat > "$FLAGS_FILE" <<'EOF'
--ozone-platform-hint=wayland
--gtk-version=4
--enable-features=UseOzonePlatform,WaylandWindowDecorations,TouchpadOverscrollHistoryNavigation,WebUIDarkMode
--enable-wayland-ime
--password-store=gnome-libsecret
EOF
  echo "+ wrote $FLAGS_FILE"
  echo "  (run export.sh to track this in the repo)"
fi

# caelestia's cli.json already has theme.enableChromium=true, so
# `caelestia theme` re-applies the current Material You colors to Chrome's
# native chrome (title bar / GTK widgets) whenever the wallpaper changes.
# Force a one-off resync now if the CLI is installed:
if command -v caelestia &>/dev/null; then
  caelestia theme apply 2>/dev/null || echo "  (run 'caelestia theme' manually to resync Chrome's colors)"
fi

cat <<'EOF'

One manual, one-time step (Chrome doesn't expose this as a flag or file):
  chrome://settings/appearance -> Themes -> "Use system theme"
This is what lets --gtk-version=4 above actually paint Chrome with your
caelestia GTK colors instead of Chrome's own Material theme.
EOF
