#!/usr/bin/env bash
# Homebrew (Linuxbrew) — installs to /home/linuxbrew/.linuxbrew.
# claude-code and anything else installed via `brew` depend on this running first.
set -euo pipefail

BREW="/home/linuxbrew/.linuxbrew/bin/brew"

if command -v brew &>/dev/null || [[ -x "$BREW" ]]; then
  echo "✓ Homebrew already installed: $("$BREW" --version 2>/dev/null | head -1 || brew --version | head -1)"
else
  echo "Installing Homebrew (official installer)..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

cat <<'EOF'

fish PATH wiring lives in ~/.config/caelestia/user-config.fish:
  /home/linuxbrew/.linuxbrew/bin/brew shellenv fish | source
(already tracked by this dotfiles repo — run `exec fish` to pick it up)

For bash, add to ~/.bashrc if you use brew from bash too:
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
EOF
