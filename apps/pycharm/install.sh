#!/usr/bin/env bash
# PyCharm Community — now in Arch's official [extra] repo (not AUR).
# pycharm-professional is still AUR-only and needs a JetBrains license; if
# you want that one instead, swap the pacman line below for:
#   yay -S --needed pycharm-professional
set -euo pipefail

echo "Installing pycharm-community-edition..."
sudo pacman -S --needed pycharm-community-edition

cat <<'EOF'

Note: this machine's existing PyCharm2026.2 install came from JetBrains
Toolbox (/opt/JetBrains/ToolBox), a separate install method from the one
above. Both can coexist; Toolbox is still fine to keep using if you prefer
its auto-update/multi-IDE management — this script just gives you a
package-manager-only path for a fresh machine.

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
