#!/usr/bin/env bash
# AmneziaVPN client from AUR (amneziavpn-bin).
set -euo pipefail

# Per the AUR package notes: if you ever used the official .run installer,
# uninstall it first or the two installs will conflict.
if [[ -x /opt/AmneziaVPN/maintenancetool ]]; then
  echo "Found an official (non-AUR) AmneziaVPN install at /opt/AmneziaVPN."
  echo "Remove it first, then re-run this script:"
  echo "  /opt/AmneziaVPN/maintenancetool"
  exit 1
fi

echo "Installing amneziavpn-bin from AUR..."
yay -S --needed amneziavpn-bin

cat <<'EOF'

AmneziaVPN stores its server list, WireGuard/AmneziaWG private keys and
server root passwords in:
  ~/.config/AmneziaVPN.ORG/AmneziaVPN.conf

That file is secrets, not config — it is intentionally NOT part of this
git repo (see .gitignore). Use apps/amneziavpn/backup-config.sh for a
local, gpg-encrypted snapshot instead.

The fish function `vpn-status` (in this repo) reports connection state by
checking for the amn0 interface AmneziaWG brings up.
EOF
