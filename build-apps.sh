#!/usr/bin/env bash
# Build small launcher apps into ~/Applications so Spotlight (⌘Space) can run
# shell commands from this repo. Re-run after changing them; safe to repeat.
#   ./build-apps.sh
#
#   Coder VM.app   runs `vm` (see zsh/.zshrc): the Coder VM's tmux in its own
#                  iTerm window on AeroSpace workspace O.
#
# The first launch asks whether "Coder VM" may control iTerm; allow it.
set -euo pipefail
apps="$HOME/Applications"
mkdir -p "$apps"

# $1 = app name, $2 = zsh command. A login + interactive zsh loads .zprofile
# (Homebrew PATH, for aerospace) and .zshrc (where vm is defined).
build() {
  local app="$apps/$1.app"
  rm -rf "$app"
  osacompile -o "$app" -e "do shell script \"/bin/zsh -lic '$2' >/dev/null 2>&1\""
  # No Dock icon or menu bar while it runs: it exits as soon as vm returns.
  /usr/libexec/PlistBuddy -c 'Add :LSUIElement bool true' "$app/Contents/Info.plist"
  # Editing Info.plist breaks osacompile's ad-hoc signature; sign it again.
  codesign --force --deep --sign - "$app" 2>/dev/null
  echo "built $app"
}

build "Coder VM" "vm"
