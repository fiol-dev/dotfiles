# Shared list of tracked config, grouped for export.sh/import.sh.
# Each group is "repo/relative/path:$HOME/relative/path" entries.
# Wallpapers aren't listed here — export.sh/import.sh discover them
# dynamically under home/Pictures/Wallpapers/.

TARGET_GROUPS=(bash fish caelestia vscodium chrome_flags claude)
declare -A GROUP_LABEL=(
  [bash]="bash (.bashrc)"
  [fish]="fish (config, functions, conf.d, completions)"
  [caelestia]="caelestia (cli.json, shell.json, hypr-vars.lua, user-config.fish, templates/)"
  [vscodium]="VSCodium (settings.json, keybindings.json)"
  [chrome_flags]="Chrome/Codium launch flags"
  [claude]="Claude Code (settings.json, statusline-command.sh)"
)

GROUP_bash=(
  "home/.bashrc:.bashrc"
)

GROUP_fish=(
  "home/.config/fish/config.fish:.config/fish/config.fish"
  "home/.config/fish/fish_plugins:.config/fish/fish_plugins"
  "home/.config/fish/functions:.config/fish/functions"
  "home/.config/fish/conf.d:.config/fish/conf.d"
  "home/.config/fish/completions:.config/fish/completions"
)

GROUP_caelestia=(
  "home/.config/caelestia/cli.json:.config/caelestia/cli.json"
  "home/.config/caelestia/shell.json:.config/caelestia/shell.json"
  "home/.config/caelestia/hypr-vars.lua:.config/caelestia/hypr-vars.lua"
  "home/.config/caelestia/user-config.fish:.config/caelestia/user-config.fish"
  "home/.config/caelestia/templates:.config/caelestia/templates"
)

GROUP_vscodium=(
  "home/.config/VSCodium/User:.config/VSCodium/User"
)

GROUP_chrome_flags=(
  "home/.config/codium-flags.conf:.config/codium-flags.conf"
  "home/.config/google-chrome-flags.conf:.config/google-chrome-flags.conf"
)

GROUP_claude=(
  "home/.claude/settings.json:.claude/settings.json"
  "home/.claude/statusline-command.sh:.claude/statusline-command.sh"
)
