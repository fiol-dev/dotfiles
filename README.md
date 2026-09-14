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
sudo pacman -S --needed - < ~/dotfiles/packages/pacman.txt
yay -S --needed - < ~/dotfiles/packages/aur.txt
bash ~/dotfiles/install.sh
exec fish
```

Then run `bash ~/dotfiles/bootstrap.sh` for the apps that need more than a
package install (extension restore, flags files, etc), or run each
`apps/<name>/install.sh` on its own.

## What's tracked and why

- **fish** — `config.fish`, `functions/`, `conf.d/`, `completions/`,
  `fish_plugins`. `fish_variables` is deliberately *not* tracked — it's
  local session/universal-variable state, not portable config.
- **bash** — `.bashrc`.
- **caelestia** — everything under `~/.config/caelestia/` (`cli.json`,
  `shell.json`, `hypr-user.lua`, `hypr-vars.lua`, `user-config.fish`,
  `monitors/`, `templates/`). Do **not** hand-edit `~/.config/hypr/`
  directly — caelestia owns that and update conflicts are the result;
  `hypr-user.lua`/`hypr-vars.lua` are the sanctioned override points.
  `monitors/` is hardware-specific (currently `eDP-1` + `DP-3`) — adjust
  output names on a new machine.
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

## Apps

| App | Source | Script |
|---|---|---|
| VSCodium | AUR `vscodium-bin` + `vscodium-bin-marketplace` | `apps/vscodium/install.sh` |
| Google Chrome | AUR `google-chrome` | `apps/google-chrome/install.sh` (+ `theme.sh`) |
| Android Studio | AUR `android-studio` | `apps/android-studio/install.sh` |
| AmneziaVPN | AUR `amneziavpn-bin` | `apps/amneziavpn/install.sh` |
| PyCharm | JetBrains Toolbox (already installed here) | `apps/pycharm/install.sh` |

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

These are separate from the existing `transfer-dotfiles` (rsyncs *this*
dotfiles set to another machine) and `backup-fish-config` functions, which
are unchanged.

## Notes

- AUR builds run under your own user via `yay`; nothing here needs `sudo`
  except the pacman/qemu/group lines called out per-app.
- Re-running `install.sh` is safe — it skips already-correct symlinks and
  backs up (never deletes) anything real it would overwrite, into
  `~/.dotfiles-backup/<timestamp>/`.
