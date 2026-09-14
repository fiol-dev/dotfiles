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

~/.config/JetBrains/PyCharm*/ is not one of the tracked paths in
lib/targets.sh. It mixes real preferences (keymap, code style) with
machine state — jdk.table.xml (local SDK paths), databaseDrivers.xml /
gitlab.xml (connection strings/tokens), recentProjects.xml (local
project paths) — and its path is version-suffixed.

The safe subset (keymaps/colors/codestyles/templates/fileTemplates) is
tracked as a snapshot and synced explicitly:
  apps/pycharm/sync-config.sh apply    # after first launch on a new machine
  apps/pycharm/sync-config.sh export   # after you customize something

JetBrains' built-in Settings Sync is still worth turning on too, for
plugins/UI state this repo doesn't track:
  Settings/Preferences -> Settings Sync -> Enable, sign in with a JetBrains Account.

apps/pycharm/backup-config.sh remains as a local (non-git, timestamped)
fallback snapshot if you ever want one outside of git.
EOF
