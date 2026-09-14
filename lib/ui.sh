# Small output helpers shared by export.sh/import.sh/bootstrap.sh.
# Degrades gracefully when stdout isn't a terminal (tput returns empty).

if [[ -t 1 ]]; then
  UI_BOLD="$(tput bold 2>/dev/null || true)"
  UI_DIM="$(tput dim 2>/dev/null || true)"
  UI_RED="$(tput setaf 1 2>/dev/null || true)"
  UI_GREEN="$(tput setaf 2 2>/dev/null || true)"
  UI_YELLOW="$(tput setaf 3 2>/dev/null || true)"
  UI_BLUE="$(tput setaf 4 2>/dev/null || true)"
  UI_RESET="$(tput sgr0 2>/dev/null || true)"
else
  UI_BOLD="" UI_DIM="" UI_RED="" UI_GREEN="" UI_YELLOW="" UI_BLUE="" UI_RESET=""
fi

ui_header() {
  echo
  echo "${UI_BOLD}${UI_BLUE}== $1 ==${UI_RESET}"
}

ui_ok()      { echo "${UI_GREEN}✓${UI_RESET} $1"; }
ui_changed() { echo "${UI_GREEN}+${UI_RESET} $1"; }
ui_skip()    { echo "${UI_DIM}-${UI_RESET} $1"; }
ui_warn()    { echo "${UI_YELLOW}!${UI_RESET} $1"; }
ui_err()     { echo "${UI_RED}✗${UI_RESET} $1"; }
