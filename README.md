# dotfiles

Config + install scripts for this caelestia (Hyprland) setup.

`export.sh` copies live config from `$HOME` into the repo. `import.sh`
copies tracked config from the repo into `$HOME`. Nothing here is
symlinked — every file is a real, independent copy on both sides.

## Layout

```
export.sh                $HOME -> repo (review with git diff, then commit + push)
import.sh                repo -> $HOME (backs up first, asks before each group)
bootstrap.sh              interactive menu over apps/*/install.sh, multi-select
lib/targets.sh            shared list of tracked paths, grouped
lib/ui.sh                 shared output formatting
packages/pacman.txt       official-repo deps
packages/aur.txt          AUR deps (yay)
home/                     tracked config, mirrors $HOME
apps/<name>/install.sh    per-app install/setup script
```

## First-time setup on a new machine

```fish
grep -vE '^\s*(#|$)' ~/dotfiles/packages/pacman.txt | xargs -r sudo pacman -S --needed
grep -vE '^\s*(#|$)' ~/dotfiles/packages/aur.txt | xargs -r yay -S --needed
bash ~/dotfiles/import.sh
exec fish
```

`pacman -S --needed - < file` does not reliably install every line of a
package list; use the `xargs` form above instead.

Then run `bash ~/dotfiles/bootstrap.sh` for the apps that need more than a
package install (extension restore, flags files, etc). It lists every app
with a number — type the ones you want space-separated (`1 3 5`), type
`all`, or hit enter for everything. Non-interactive:
`bash bootstrap.sh 1 3 5` or `bash bootstrap.sh all`. Each app also has
its own standalone `apps/<name>/install.sh`.

## export.sh / import.sh

Both walk the same grouped list in `lib/targets.sh` (bash, fish,
caelestia, VSCodium, Chrome/Codium flags, Claude Code, ssh-agent).
Wallpapers used to be discovered dynamically here too; they now live in
Google Drive instead (see **Wallpapers** below).

**`export.sh`** — one-way, `$HOME` → repo. Copies whatever differs and
prints a summary. No prompts, no backups, nothing committed for you.

**`import.sh`** — one-way, repo → `$HOME`. For each group: backs it up,
then asks for confirmation before copying:

```
== caelestia (cli.json, shell.json, hypr-vars.lua, user-config.fish, templates/) ==
Import this group? [Y/n]
```

`-y`/`--yes` skips the prompts (what `bootstrap.sh` uses); the backup
step still runs regardless.

Backup behavior: a group's target directory is backed up in full when it
has 2+ path segments under `$HOME` (e.g. `.config/caelestia`) — this also
captures anything else living in that directory, tracked or not (e.g.
`caelestia/monitors/`). A file living directly under `$HOME` or directly
under `.config/` (e.g. `.bashrc`, `codium-flags.conf`) is backed up
individually.

## What's tracked

- **fish** — `config.fish`, `functions/`, `conf.d/`, `completions/`,
  `fish_plugins`. `fish_variables` is not tracked (session/universal
  variable state).
- **bash** — `.bashrc`.
- **ssh-agent** — `~/.config/systemd/user/ssh-agent.service` (a `--user`
  unit binding the agent to `$XDG_RUNTIME_DIR/ssh-agent.socket`; enabled
  by `apps/ssh-agent/install.sh`). `home/.config/fish/conf.d/ssh-agent.fish`
  (tracked as part of **fish** below) points `SSH_AUTH_SOCK` at that same
  socket.
- **caelestia** — individual files under `~/.config/caelestia/` (`cli.json`,
  `shell.json`, `hypr-vars.lua`, `user-config.fish`, `templates/`). Don't
  hand-edit `~/.config/hypr/` directly — caelestia regenerates it;
  `hypr-vars.lua` and `hypr-user.lua` are its override points.
  `~/.config/caelestia/monitors/` (per-machine monitor names/scale/position)
  and `hypr-user.lua` (per-machine monitor layout) are not tracked.
  `hypr-user.lua.example` has the monitor block commented out — copy it
  to `hypr-user.lua` and fill in `hyprctl monitors` output. An absent
  `hypr-user.lua` is fine too; `hyprland.lua` creates an empty one and
  Hyprland auto-detects monitors.
  `import.sh` runs `hyprctl reload` at the end when Hyprland is running.
  `templates/sddm-theme.conf` is the caelestia SDDM theme's
  (minimalistV2) config — the color fields (`#{{ primary.hex }}` etc.)
  are filled in by `sync.sh` on every wallpaper/theme change; everything
  above that (radius, blur, avatar shape...) is a plain setting.
- **VSCodium** — `settings.json`, `keybindings.json`, plus
  `apps/vscodium/extensions.txt` (`codium --install-extension` per line;
  regenerate with `codium --list-extensions`).
- **Chrome/Codium launch flags** — `codium-flags.conf` and
  `google-chrome-flags.conf` set `--gtk-version=4` + Wayland flags.
- **AmneziaVPN** — not tracked. `~/.config/AmneziaVPN.ORG/AmneziaVPN.conf`
  holds WireGuard/AmneziaWG private keys and server root passwords.
  `apps/amneziavpn/backup-config.sh` makes a local, gpg-encrypted backup.
- **PyCharm / Android Studio** — the safe subset of each (`keymaps/`,
  `colors/`, `codestyles/`, `templates/`, `fileTemplates/`) lives under
  `apps/pycharm/config/` and `apps/android-studio/config/`, synced with
  `apps/<name>/sync-config.sh {export|apply}` since the live config dirs
  are version-suffixed (`PyCharm2026.2`, `AndroidStudio2026.1.4`, ...).
  `export` after customizing something, `apply` on a new machine or a new
  version dir.
  Not tracked: `options/` (SDK paths, DB connection strings, GitHub/GitLab
  auth state, recent-project paths), `pycharm.key` (license), `workspace/`,
  `ssl/`, `tasks/`. JetBrains' built-in Settings Sync covers plugins/UI
  state. `apps/pycharm/backup-config.sh` makes a local, timestamped,
  non-git snapshot.
- **Claude Code** — `~/.claude/settings.json` and `statusline-command.sh`.
  Everything else under `~/.claude/` (`.credentials.json`, `history.jsonl`,
  `sessions/`, `projects/`, `session-env/`, ...) is not tracked.
- **Wallpapers** — not tracked in git (this repo is public; ~615MB of
  wallhaven.cc/anime images was too much to keep in a public repo's
  history). Both the 41 static files and `Animated/` live in
  [Google Drive](https://drive.google.com/drive/folders/1FM-8uMKr4L5cfsjphGF-ZmVsYxe_yCys?usp=sharing)
  instead — download them to `~/Pictures/Wallpapers/` by hand on a new
  machine. `home/Pictures/Wallpapers/` is `.gitignore`d to keep them from
  being re-added by accident.

## Apps

| App | Source | Script |
|---|---|---|
| Homebrew | official installer script | `apps/homebrew/install.sh` |
| Claude Code | Homebrew cask `claude-code` | `apps/claude-code/install.sh` |
| VSCodium | AUR `vscodium-bin` + `vscodium-bin-marketplace` | `apps/vscodium/install.sh` |
| Google Chrome | AUR `google-chrome` | `apps/google-chrome/install.sh` (+ `theme.sh`) |
| Android Studio | AUR `android-studio` (Toolbox also works) | `apps/android-studio/install.sh` (+ `sync-config.sh`) |
| AmneziaVPN | AUR `amneziavpn-bin` | `apps/amneziavpn/install.sh` |
| PyCharm | official repo `pycharm-community-edition` (Toolbox also works) | `apps/pycharm/install.sh` (+ `sync-config.sh`) |
| lazygit | official repo `lazygit` | `apps/lazygit/install.sh` |
| Telegram Desktop | official repo `telegram-desktop` | `apps/telegram-desktop/install.sh` |
| Discord | official repo `discord` | `apps/discord/install.sh` |
| Docker | official repo: `docker`, `docker-compose`, `docker-buildx` | `apps/docker/install.sh` |
| lazydocker | official repo `lazydocker` | `apps/lazydocker/install.sh` |
| SDDM + caelestia theme | official repo `sddm` + AUR `caelestia-sddm-minimalistv2-git` | `apps/sddm/install.sh` |
| ssh-agent | — | `apps/ssh-agent/install.sh` |

`apps/claude-code/install.sh` installs Claude Code via Homebrew, adding
it alongside any existing native/npm install at `/usr/bin/claude`; once
brew's shellenv is sourced, brew's Cellar takes priority on `PATH`.

`apps/sddm/install.sh` installs the minimalistV2 variant of
[caelestia-sddm](https://github.com/ItsABigIgloo/caelestia-sddm) (there's
also `-locklike-git` and `-minimalist-git`; the three conflict since they
share one install path, `/usr/share/sddm/themes/caelestia`), sets up
the `/etc/sudoers.d/caelestia-sddm-sync` NOPASSWD rule the theme's
postHook needs, runs a first sync, and `systemctl enable`s sddm without
starting it.

`apps/docker/install.sh` installs the engine, enables `docker.service`,
and adds your user to the `docker` group (needs a new login session to
take effect). `docker-compose` provides both the standalone
`docker-compose` binary and the `docker compose` plugin; `docker-buildx`
gives BuildKit via `docker buildx build`.

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
  download the one you pick (uses `sshget`).

`sshput`/`sshget` fall back to `scp -pr` when `rsync` isn't installed —
no progress/resume/incremental-update, and `-d`/`-n` are refused rather
than ignored. `sshsync` requires rsync; no scp fallback.
`bootstrap.sh` installs rsync automatically before offering the app menu.

`backup-fish-config` (local fish-config snapshot) is the other
pre-existing helper in this directory.

## Notes

- AUR builds run under your own user via `yay`; nothing here needs `sudo`
  except the pacman/qemu/group lines called out per-app.
- Re-running `import.sh` skips anything already matching (real content
  comparison) and backs up before changing anything, into
  `~/.dotfiles-backup/<timestamp>/`. Nothing is deleted, only moved there
  first.
