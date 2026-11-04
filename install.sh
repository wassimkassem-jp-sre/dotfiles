#!/usr/bin/env bash
# Link every package in this repo into $HOME with GNU stow.
#   ./install.sh            link all packages
#   ./install.sh tmux nvim  link only some
#   ./install.sh -D tmux    unlink (any stow flag is passed through)
set -euo pipefail
cd "$(dirname "$0")"
flags=(); pkgs=()
for a in "$@"; do [[ $a == -* ]] && flags+=("$a") || pkgs+=("$a"); done
if [[ ${#pkgs[@]} -eq 0 ]]; then
  for d in */; do pkgs+=("${d%/}"); done
fi
stow --verbose=1 --restow "${flags[@]}" "${pkgs[@]}"
