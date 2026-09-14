# dotfiles

Config + install scripts for this caelestia (Hyprland) setup.

## Layout

```
install.sh              symlinks home/ into $HOME (backs up conflicts first)
bootstrap.sh             interactive menu over apps/*/install.sh
packages/pacman.txt       official-repo deps
packages/aur.txt          AUR deps (yay)
home/                     tracked config, mirrors $HOME
apps/<name>/install.sh    per-app install/setup script
```

## First-time setup on a new machine

```fish
grep -vE '^\s*(#|$)' ~/dotfiles/packages/pacman.txt | xargs -r sudo pacman -S --needed
grep -vE '^\s*(#|$)' ~/dotfiles/packages/aur.txt | xargs -r yay -S --needed
bash ~/dotfiles/install.sh
exec fish
```

(`pacman -S --needed - < file` looks tempting but doesn't work reliably here —
pacman's stdin-as-targets mode treats every line literally, comments
included, and depending on your shell/sudo setup can fail outright with
`argument '-' specified without input on stdin`. `xargs` sidesteps all of
that.)

Then run `bash ~/dotfiles/bootstrap.sh` for the apps that need more than a
package install (extension restore, flags files, etc), or run each
`apps/<name>/install.sh` on its own.

## What's tracked and why

- **fish** — `config.fish`, `functions/`, `conf.d/`, `completions/`,
  `fish_plugins`. `fish_variables` is deliberately *not* tracked — it's
  local session/universal-variable state, not portable config.
- **bash** — `.bashrc`.
- **caelestia** — individual files under `~/.config/caelestia/` (`cli.json`,
  `shell.json`, `hypr-user.lua`, `hypr-vars.lua`, `user-config.fish`,
  `templates/`), linked one by one rather than the whole directory. Do
  **not** hand-edit `~/.config/hypr/` directly — caelestia owns that and
  update conflicts are the result; `hypr-user.lua`/`hypr-vars.lua` are the
  sanctioned override points.
  `~/.config/caelestia/monitors/` is deliberately *not* tracked — it's
  per-machine output config (monitor names/scale/position), not portable
  between machines. Linking file-by-file instead of the whole directory
  also means `install.sh` never touches it.
  `install.sh` runs `hyprctl reload` at the end (when Hyprland is actually
  running) so these changes take effect immediately.
  `templates/sddm-theme.conf` is the caelestia SDDM theme's (minimalistV2)
  user-customizable config — colors are templated (`#{{ primary.hex }}`
  etc.) and filled in by `sync.sh` on every wallpaper/theme change (see
  the SDDM row below); everything above that line (radius, blur, avatar
  shape...) is yours to edit.
- **VSCodium** — `settings.json`, `keybindings.json` (symlinked), plus
  `apps/vscodium/extensions.txt` (restored via `codium --install-extension`,
  regenerate with `codium --list-extensions`).
- **Chrome/Codium launch flags** — `codium-flags.conf` and
  `google-chrome-flags.conf` set `--gtk-version=4` + Wayland flags so both
  apps render with native GTK decorations and pick up caelestia's theme.
- **AmneziaVPN** — *not* tracked. `~/.config/AmneziaVPN.ORG/AmneziaVPN.conf`
  holds live WireGuard/AmneziaWG private keys and server root passwords.
  Use `apps/amneziavpn/backup-config.sh` for a local, gpg-encrypted backup
  instead (never committed).
- **PyCharm** — *not* tracked either. Its config dir mixes real prefs with
  machine state (SDK paths, DB connection strings, recent project paths).
  Use JetBrains' built-in **Settings Sync** for keymap/plugins/editor
  prefs; `apps/pycharm/backup-config.sh` gives a local fallback for the
  genuinely safe subset (keymaps/colors/codestyles).
- **Claude Code** — only `~/.claude/settings.json` (permissions mode,
  enabled plugins/marketplaces, statusline command) and
  `statusline-command.sh` are tracked. Everything else under `~/.claude/`
  (`.credentials.json`, `history.jsonl`, `sessions/`, `projects/`,
  `session-env/`, ...) is runtime state or secrets and is git-ignored.

## Apps

| App | Source | Script |
|---|---|---|
| Homebrew | official installer script | `apps/homebrew/install.sh` |
| Claude Code | Homebrew cask `claude-code` | `apps/claude-code/install.sh` |
| VSCodium | AUR `vscodium-bin` + `vscodium-bin-marketplace` | `apps/vscodium/install.sh` |
| Google Chrome | AUR `google-chrome` | `apps/google-chrome/install.sh` (+ `theme.sh`) |
| Android Studio | AUR `android-studio` | `apps/android-studio/install.sh` |
| AmneziaVPN | AUR `amneziavpn-bin` | `apps/amneziavpn/install.sh` |
| PyCharm | official repo `pycharm-community-edition` (Toolbox also works, already used here) | `apps/pycharm/install.sh` |
| lazygit | AUR `lazygit-git` (replaces stable `lazygit`) | `apps/lazygit/install.sh` |
| Docker | official repo: `docker`, `docker-compose`, `docker-buildx` | `apps/docker/install.sh` |
| lazydocker | official repo `lazydocker` | `apps/lazydocker/install.sh` |
| SDDM + caelestia theme | official repo `sddm` + AUR `caelestia-sddm-minimalistv2-git` | `apps/sddm/install.sh` |

Claude Code was already installed here via a native/npm install at
`/usr/bin/claude`; `apps/claude-code/install.sh` adds the Homebrew cask
alongside it — once brew's shellenv is sourced its Cellar wins on `PATH`,
shadowing (not removing) the older install.

SDDM: `apps/sddm/install.sh` installs the minimalistV2 variant of
[caelestia-sddm](https://github.com/ItsABigIgloo/caelestia-sddm) (there's
also `-locklike-git` and `-minimalist-git`; all three conflict since they
share the same install path, `/usr/share/sddm/themes/caelestia`), sets up
the `/etc/sudoers.d/caelestia-sddm-sync` NOPASSWD rule the theme's
postHook needs (validated with `visudo -cf` before installing), runs a
first sync, and `systemctl enable`s sddm. It does **not** `systemctl
start` it — on a fresh install that's a reboot or a manual `systemctl
start sddm` away, to avoid yanking an already-running session out from
under you if you re-run this on a live machine.

Docker: `apps/docker/install.sh` installs the engine, enables
`docker.service`, and adds your user to the `docker` group automatically —
that group change needs a new login session (or `newgrp docker`) to take
effect. `docker-compose` provides both the standalone `docker-compose`
binary and the `docker compose` plugin; `docker-buildx` gives BuildKit
(the default builder on Docker 23+) via `docker buildx build`.

## SSH file-transfer fish functions

All in `home/.config/fish/functions/`:

- `sshput [-d] [-n] LOCAL HOST:REMOTE` — upload via rsync (`-d` mirrors
  deletions, `-n` dry-runs).
- `sshget [-d] [-n] HOST:REMOTE [LOCAL]` — download via rsync.
- `sshsync [-n] LOCAL_DIR HOST:REMOTE_DIR` — pull-then-push rsync between a
  local and remote dir; never deletes on either side.
- `sshmount HOST:REMOTE LOCAL_DIR` / `sshumount LOCAL_DIR` — mount/unmount
  a remote dir with sshfs.
- `sshpick HOST [START_DIR]` — fzf-browse files on a remote host and
  download the one you pick.

`backup-fish-config` (local fish-config snapshot) is the other pre-existing
helper in this directory, unchanged.

## Notes

- AUR builds run under your own user via `yay`; nothing here needs `sudo`
  except the pacman/qemu/group lines called out per-app.
- Re-running `install.sh` is safe — it skips already-correct symlinks and
  backs up (never deletes) anything real it would overwrite, into
  `~/.dotfiles-backup/<timestamp>/`.
