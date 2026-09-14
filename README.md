# dotfiles

Config + install scripts for this caelestia (Hyprland) setup.

This repo manages **one machine at a time** — there's no symlinking back
into it. `export.sh` copies live config *from* `$HOME` *into* the repo;
`import.sh` copies tracked config *from* the repo *into* `$HOME`. The
workflow is: change something → `export.sh` → review with `git diff` →
commit → push; on another machine: `git pull` → `import.sh`.

Why not symlinks: this repo used to symlink `~/.config/...` straight into
`~/dotfiles/home/...`, and it caused real problems — a stray leftover
directory-symlink produced a self-referential loop ("too many levels of
symbolic links") that took real debugging to track down, and content
changes here would silently and immediately change live config on
whatever machine had it checked out, with no chance to review first.
Plain `cp` sidesteps all of that: every machine's config is a real,
independent file, and nothing here can affect a live system until you
explicitly run `import.sh`.

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

(`pacman -S --needed - < file` looks tempting but doesn't work reliably here —
pacman's stdin-as-targets mode treats every line literally, comments
included, and depending on your shell/sudo setup can fail outright with
`argument '-' specified without input on stdin`. `xargs` sidesteps all of
that.)

Then run `bash ~/dotfiles/bootstrap.sh` for the apps that need more than a
package install (extension restore, flags files, etc). It'll list every
app with a number — type the ones you want space-separated (`1 3 5`),
type `all`, or just hit enter for everything. Non-interactive:
`bash bootstrap.sh 1 3 5` or `bash bootstrap.sh all`. Each app also has
its own standalone `apps/<name>/install.sh`.

## export.sh / import.sh

Both walk the same grouped list in `lib/targets.sh` (bash, fish,
caelestia, VSCodium, Chrome/Codium flags, Claude Code), plus wallpapers
handled separately since that list is discovered dynamically.

**`export.sh`** — one-way, `$HOME` → repo. No prompts, no backups (git
history *is* the backup here) — it just copies whatever differs and
prints a summary. Nothing is committed for you.

**`import.sh`** — one-way, repo → `$HOME`. Every group gets backed up in
full *before* it's touched, unconditionally, and you're asked to confirm
before anything in that group actually changes:

```
== caelestia (cli.json, shell.json, hypr-vars.lua, user-config.fish, templates/) ==
Import this group? [Y/n]
```

Pass `-y`/`--yes` to skip the prompts and just go (what `bootstrap.sh`
does at the end, and what you'd want for an unattended fresh-machine
setup) — the backup still happens either way, that part isn't optional.

The backup step only fully-backs-up a group's target *directory* when
that directory is dedicated to one app (2+ path segments under `$HOME`,
e.g. `.config/caelestia`) — that's what catches untracked siblings like
`caelestia/monitors/` for free. A file living directly under `$HOME` or
directly under `.config/` (e.g. `.bashrc`, `codium-flags.conf`) gets
backed up individually instead, never its "parent directory" — that
parent would be `$HOME` itself or the entire `~/.config` tree, shared by
every other app on the machine. Getting this wrong the first time around
is what briefly turned a routine backup into an accidental 98GB copy of
this entire home directory; it's now covered by a sandboxed regression
test before either script touches a real `$HOME`.

## What's tracked and why

- **fish** — `config.fish`, `functions/`, `conf.d/`, `completions/`,
  `fish_plugins`. `fish_variables` is deliberately *not* tracked — it's
  local session/universal-variable state, not portable config.
- **bash** — `.bashrc`.
- **caelestia** — individual files under `~/.config/caelestia/` (`cli.json`,
  `shell.json`, `hypr-vars.lua`, `user-config.fish`, `templates/`). Do
  **not** hand-edit `~/.config/hypr/` directly — caelestia owns that and
  update conflicts are the result; `hypr-vars.lua` (and `hypr-user.lua`,
  see below) are the sanctioned override points.
  `~/.config/caelestia/monitors/` is deliberately *not* tracked — it's
  per-machine output config (monitor names/scale/position), not portable
  between machines. It's still covered by `import.sh`'s backup step
  though, since it lives inside `.config/caelestia`.
  `hypr-user.lua` is **not tracked either**, for the same reason — the
  version that used to be here hardcoded this machine's actual monitor
  layout (`eDP-1`/`DP-3`, specific scale/mode), which would silently apply
  the wrong monitor config on a different machine. `hypr-user.lua.example`
  ships instead, with the monitor block commented out — copy it to
  `hypr-user.lua` and uncomment/adjust per `hyprctl monitors` on whatever
  machine you're setting up. `hyprland.lua`'s own `maybe_create()` creates
  an empty `hypr-user.lua` if none exists, so leaving it absent is safe
  too (Hyprland just auto-detects monitors).
  `import.sh` runs `hyprctl reload` at the end (when Hyprland is actually
  running) so these changes take effect immediately.
  `templates/sddm-theme.conf` is the caelestia SDDM theme's (minimalistV2)
  user-customizable config — colors are templated (`#{{ primary.hex }}`
  etc.) and filled in by `sync.sh` on every wallpaper/theme change (see
  the SDDM row below); everything above that line (radius, blur, avatar
  shape...) is yours to edit.
- **VSCodium** — `settings.json`, `keybindings.json`, plus
  `apps/vscodium/extensions.txt` (restored via `codium --install-extension`,
  regenerate with `codium --list-extensions`).
- **Chrome/Codium launch flags** — `codium-flags.conf` and
  `google-chrome-flags.conf` set `--gtk-version=4` + Wayland flags so both
  apps render with native GTK decorations and pick up caelestia's theme.
- **AmneziaVPN** — *not* tracked. `~/.config/AmneziaVPN.ORG/AmneziaVPN.conf`
  holds live WireGuard/AmneziaWG private keys and server root passwords.
  Use `apps/amneziavpn/backup-config.sh` for a local, gpg-encrypted backup
  instead (never committed).
- **PyCharm / Android Studio** — the safe subset of each (`keymaps/`,
  `colors/`, `codestyles/`, `templates/`, `fileTemplates/`) is tracked as
  a snapshot under `apps/pycharm/config/` and `apps/android-studio/config/`,
  synced explicitly with `apps/<name>/sync-config.sh {export|apply}` —
  same export/import philosophy as the rest of this repo, just scoped to
  its own script since these live config dirs are version-suffixed
  (`PyCharm2026.2`, `AndroidStudio2026.1.4`, ...) and get superseded on
  every IDE update. `export` after you customize something (keymap tweak,
  new file template, color scheme), `apply` on a new machine or once a
  new version dir appears.
  Deliberately **not** tracked: `options/` (mixes real prefs with local
  SDK paths in `jdk.table.xml`, DB connection strings, GitHub/GitLab auth
  state, recent-project paths), `pycharm.key` (license), `workspace/`,
  `ssl/`, `tasks/`. Use JetBrains' built-in **Settings Sync** for
  plugins/UI state on top of this. `apps/pycharm/backup-config.sh` remains
  as a local, non-git, timestamped fallback.
- **Claude Code** — only `~/.claude/settings.json` (permissions mode,
  enabled plugins/marketplaces, statusline command) and
  `statusline-command.sh` are tracked. Everything else under `~/.claude/`
  (`.credentials.json`, `history.jsonl`, `sessions/`, `projects/`,
  `session-env/`, ...) is runtime state or secrets and is git-ignored.
- **Wallpapers** — the 41 static files directly under
  `~/Pictures/Wallpapers/` (~235MB). `~/Pictures/Wallpapers/Animated/`
  (~380MB of third-party anime/video wallpapers) is deliberately **not**
  tracked — both `export.sh` and `import.sh` discover the flat file list
  dynamically rather than copying the whole directory, so `Animated/`
  is simply never touched either direction. Note this repo is public: the
  wallhaven.cc images in here are third-party downloads, not original
  work, committed at the repo owner's explicit choice.

## Apps

| App | Source | Script |
|---|---|---|
| Homebrew | official installer script | `apps/homebrew/install.sh` |
| Claude Code | Homebrew cask `claude-code` | `apps/claude-code/install.sh` |
| VSCodium | AUR `vscodium-bin` + `vscodium-bin-marketplace` | `apps/vscodium/install.sh` |
| Google Chrome | AUR `google-chrome` | `apps/google-chrome/install.sh` (+ `theme.sh`) |
| Android Studio | AUR `android-studio` (Toolbox also works, already used here) | `apps/android-studio/install.sh` (+ `sync-config.sh`) |
| AmneziaVPN | AUR `amneziavpn-bin` | `apps/amneziavpn/install.sh` |
| PyCharm | official repo `pycharm-community-edition` (Toolbox also works, already used here) | `apps/pycharm/install.sh` (+ `sync-config.sh`) |
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
  download the one you pick (uses `sshget` under the hood).

`sshput`/`sshget` fall back to `scp -pr` automatically when `rsync` isn't
installed — no progress/resume/incremental-update, and `-d`/`-n` are
refused rather than silently ignored, since they only mean something with
rsync. `sshsync` requires rsync outright (no scp fallback): its `-u`
update-skip and pull-then-push semantics don't map onto scp safely.
`bootstrap.sh` installs rsync automatically before offering the app menu,
so this fallback is mainly for a bare machine that hasn't run it yet —
which is exactly the state this machine was in when it got added.

`backup-fish-config` (local fish-config snapshot) is the other pre-existing
helper in this directory, unchanged.

## Notes

- AUR builds run under your own user via `yay`; nothing here needs `sudo`
  except the pacman/qemu/group lines called out per-app.
- Re-running `import.sh` is safe — it skips anything already up to date
  (real content match, not just "a symlink exists") and always backs up
  before changing anything, into `~/.dotfiles-backup/<timestamp>/`.
  Nothing is ever deleted, only moved into that backup dir first.
