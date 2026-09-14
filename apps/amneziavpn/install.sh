#!/usr/bin/env bash
# AmneziaVPN client from AUR (amneziavpn-bin).
set -euo pipefail

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

That file is not tracked in this git repo (see .gitignore). Use
apps/amneziavpn/backup-config.sh for a local, gpg-encrypted snapshot.

The fish function `vpn-status` (in this repo) reports connection state by
checking for the amn0 interface AmneziaWG brings up.
EOF
