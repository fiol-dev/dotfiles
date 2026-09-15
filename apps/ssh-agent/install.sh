#!/usr/bin/env bash
# Enables the ssh-agent.service user unit and installs the caelestia-styled
# askpass prompt that home/.config/fish/conf.d/ssh-agent.fish points at.
set -euo pipefail

UNIT="$HOME/.config/systemd/user/ssh-agent.service"
if [[ ! -f "$UNIT" ]]; then
  echo "! $UNIT not found — run 'bash import.sh' to bring in the tracked"
  echo "  unit file, then re-run this script."
  exit 0
fi

echo "Enabling + starting ssh-agent.service (user unit)..."
systemctl --user daemon-reload
systemctl --user enable --now ssh-agent.service

ASKPASS_REPO="$HOME/Projects/caelestia-ssh-askpass"
if [[ -x "$ASKPASS_REPO/install.sh" ]]; then
  echo "Installing caelestia-ssh-askpass..."
  "$ASKPASS_REPO/install.sh"
else
  echo
  echo "! caelestia-ssh-askpass not found at $ASKPASS_REPO"
  echo "  Clone https://github.com/fiol-dev/caelestia-ssh-askpass there and"
  echo "  run its install.sh, or SSH_ASKPASS in ssh-agent.fish will point at"
  echo "  a missing binary."
fi

echo
echo "✓ ssh-agent listening on \$XDG_RUNTIME_DIR/ssh-agent.socket"
