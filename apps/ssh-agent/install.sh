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
if [[ ! -d "$ASKPASS_REPO" ]]; then
  echo "Cloning caelestia-ssh-askpass..."
  mkdir -p "$(dirname "$ASKPASS_REPO")"
  git clone git@github.com:fiol-dev/caelestia-ssh-askpass.git "$ASKPASS_REPO"
fi

if [[ -x "$ASKPASS_REPO/install.sh" ]]; then
  echo "Installing caelestia-ssh-askpass..."
  "$ASKPASS_REPO/install.sh"
else
  echo
  echo "! $ASKPASS_REPO/install.sh missing or not executable."
  echo "  SSH_ASKPASS in ssh-agent.fish will point at a missing binary until"
  echo "  that's fixed and this script is re-run."
fi

echo
echo "✓ ssh-agent listening on \$XDG_RUNTIME_DIR/ssh-agent.socket"
