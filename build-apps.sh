#!/usr/bin/env bash
# Build small launcher apps into ~/Applications so Spotlight (⌘Space) can run
# shell commands from this repo. Re-run after changing them; safe to repeat.
#   ./build-apps.sh
#
#   Coder VM.app   runs `vm` (see zsh/.zshrc): the Coder VM's tmux in its own
#                  iTerm window on AeroSpace workspace O.
#   Review PR.app  asks for a PR (prefilled from the clipboard or Chrome's
#                  current tab) and runs `review` (bin/.local/bin/review):
#                  Chrome + nvim on that PR, stacked on AeroSpace workspace V.
#
# First launches ask whether the app may control iTerm (and Chrome, for the
# prefill); allow it.
set -euo pipefail
apps="$HOME/Applications"
mkdir -p "$apps"

# $1 = app name, $2 = AppleScript source, $3 = "background" for no Dock icon.
build() {
  local app="$apps/$1.app"
  rm -rf "$app"
  osacompile -o "$app" -e "$2"
  if [[ ${3:-} == background ]]; then
    /usr/libexec/PlistBuddy -c 'Add :LSUIElement bool true' "$app/Contents/Info.plist"
    # Editing Info.plist breaks osacompile's ad-hoc signature; sign it again.
    codesign --force --deep --sign - "$app" 2>/dev/null
  fi
  echo "built $app"
}

# A login + interactive zsh loads .zprofile (Homebrew PATH, for aerospace and
# gh) and .zshrc (where vm is defined, ~/.local/bin on PATH).

build "Coder VM" '
do shell script "/bin/zsh -lic vm >/dev/null 2>&1"
' background

build "Review PR" '
set prefill to ""
try
  set clip to (the clipboard as text)
  if clip contains "github.com/" and clip contains "/pull/" then set prefill to clip
end try
if prefill is "" and application "Google Chrome" is running then
  try
    tell application "Google Chrome" to set tabURL to URL of active tab of front window
    if tabURL contains "/pull/" then set prefill to tabURL
  end try
end if
activate
set pr to text returned of (display dialog "PR URL, or number (WayveCode):" default answer prefill with title "Review PR" buttons {"Cancel", "Review"} default button "Review")
-- Runs in the background (it can take a while to create a worktree); errors
-- show as a notification and in /tmp/review.log.
do shell script "/bin/zsh -lic " & quoted form of ("review " & quoted form of pr) & " >/tmp/review.log 2>&1 &"
'
