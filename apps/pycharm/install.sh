#!/usr/bin/env bash
# PyCharm on this machine is managed by JetBrains Toolbox (/opt/JetBrains/ToolBox),
# not a standalone AUR package — this script just makes sure Toolbox is present
# and points you at it, it doesn't reinstall the IDE.
set -euo pipefail

if [[ -x /opt/JetBrains/ToolBox/jetbrains-toolbox ]] || command -v jetbrains-toolbox &>/dev/null; then
  echo "✓ JetBrains Toolbox already installed."
else
  echo "Installing JetBrains Toolbox from AUR..."
  yay -S --needed jetbrains-toolbox
fi

cat <<'EOF'

Install/update PyCharm itself from inside Toolbox (GUI), not via pacman/AUR —
that's how the existing PyCharm2026.2 install here was set up.

Why this repo doesn't symlink ~/.config/JetBrains/PyCharm*/ :
Its config directory mixes real preferences (keymap, code style) with
machine state you don't want in git — jdk.table.xml (local SDK paths),
databaseDrivers.xml / gitlab.xml (can hold connection strings/tokens),
recentProjects.xml (local project paths).

Use JetBrains' built-in Settings Sync instead — it's the supported way to
carry keymap/plugins/editor prefs across installs and even across IDEs
(PyCharm <-> IntelliJ):
  Settings/Preferences -> Settings Sync -> Enable, sign in with a JetBrains Account.

See apps/pycharm/backup-config.sh for a local (non-git) snapshot of the
safe subset (keymaps/, colors/, codestyles/) if you want a portable
fallback that doesn't need a JetBrains Account.
EOF
