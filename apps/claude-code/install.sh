#!/usr/bin/env bash
# Claude Code CLI via Homebrew.
# https://formulae.brew.sh/cask/claude-code
set -euo pipefail

BREW="/home/linuxbrew/.linuxbrew/bin/brew"

if ! command -v brew &>/dev/null; then
  if [[ -x "$BREW" ]]; then
    eval "$("$BREW" shellenv bash)"
  else
    echo "Homebrew isn't installed. Run apps/homebrew/install.sh first."
    exit 1
  fi
fi

if command -v claude &>/dev/null && [[ "$(command -v claude)" != *linuxbrew* ]]; then
  echo "Note: 'claude' is currently resolved from $(command -v claude) (not brew)."
  echo "Once brew's shellenv is sourced, brew's Cellar comes first on PATH and"
  echo "will shadow it — the older install isn't removed, just no longer picked up."
  echo
fi

echo "Installing Claude Code (stable channel) via Homebrew..."
brew install --cask claude-code

cat <<'EOF'

Homebrew casks don't auto-update in the background — refresh with:
  brew upgrade claude-code
(there's also a `claude-code@latest` cask if you want the bleeding edge
instead of the ~1-week-behind stable channel)

~/.claude/settings.json and ~/.claude/statusline-command.sh are tracked by
dotfiles/install.sh (symlinked). Everything else under ~/.claude/ (auth
credentials, session history, project state) is intentionally NOT tracked.
EOF
