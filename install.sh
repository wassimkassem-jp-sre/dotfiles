#!/usr/bin/env bash
# Link every package in this repo into $HOME with GNU stow.
#   ./install.sh            link all packages
#   ./install.sh tmux nvim  link only some
#   ./install.sh -n         dry run: show what would change
#   ./install.sh -D tmux    unlink (any stow flag is passed through)
# Same script on the macos and linux branches.
#
# Before linking, any real file in $HOME that a package would replace is moved
# to ~/dotfiles-backup-<date>/, so stow doesn't refuse on a fresh machine.
set -euo pipefail
cd "$(dirname "$0")"
flags=(); pkgs=()
for a in "$@"; do [[ $a == -* ]] && flags+=("$a") || pkgs+=("$a"); done
if [[ ${#pkgs[@]} -eq 0 ]]; then
  for d in */; do pkgs+=("${d%/}"); done
fi

command -v stow >/dev/null || { echo "stow is not installed (see README)" >&2; exit 1; }

move_aside=true
for f in ${flags[@]+"${flags[@]}"}; do
  case $f in -D|--delete|-n|--no|--simulate) move_aside=false ;; esac
done

if $move_aside; then
  backup="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
  for pkg in "${pkgs[@]}"; do
    while IFS= read -r rel; do
      target="$HOME/$rel"
      # Skip what is missing or already this repo's file (directly or through
      # a linked parent directory); move any other real file aside.
      [[ -e $target || -L $target ]] || continue
      [[ $target -ef $pkg/$rel ]] && continue
      [[ -L $target ]] && continue   # someone else's link: let stow report it
      mkdir -p "$backup/$(dirname "$rel")"
      mv "$target" "$backup/$rel"
      echo "moved ~/$rel to $backup/"
    done < <(cd "$pkg" && find . -type f ! -name .DS_Store | sed 's|^\./||')
  done
  # ~/.gnupg must stay a real, private directory, so stow links only the files
  # inside it instead of turning the whole directory into a link.
  if [[ -d gnupg ]]; then mkdir -p -m 700 "$HOME/.gnupg"; fi
fi

stow --verbose=1 --restow ${flags[@]+"${flags[@]}"} "${pkgs[@]}"
