#!/usr/bin/env bash
# Installs x11-ssh-askpass and enables the ssh-agent.service user unit.
set -euo pipefail

echo "Installing x11-ssh-askpass..."
sudo pacman -S --needed x11-ssh-askpass

UNIT="$HOME/.config/systemd/user/ssh-agent.service"
if [[ ! -f "$UNIT" ]]; then
  echo "! $UNIT not found — run 'bash import.sh' to bring in the tracked"
  echo "  unit file, then re-run this script."
  exit 0
fi

echo "Enabling + starting ssh-agent.service (user unit)..."
systemctl --user daemon-reload
systemctl --user enable --now ssh-agent.service

echo
echo "✓ ssh-agent listening on \$XDG_RUNTIME_DIR/ssh-agent.socket"
