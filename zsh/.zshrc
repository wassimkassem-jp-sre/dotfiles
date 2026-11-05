# ~/.zshrc — managed in ~/workspace/dotfiles, macos branch (zsh package, linked with GNU stow)

# Powerlevel10k instant prompt. Keep near the top; anything that needs console
# input (password prompts, y/n) must go above this block.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Keep PATH/FPATH free of duplicates.
typeset -U path fpath

# ------------------------------------------------------------- oh-my-zsh ----
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git httpie)

# Homebrew completions must be on FPATH before oh-my-zsh runs compinit
# (previously compinit ran a second time after oh-my-zsh, slowing startup).
# $HOMEBREW_PREFIX is set by `brew shellenv` in ~/.zprofile.
[[ -n $HOMEBREW_PREFIX ]] && fpath=("$HOMEBREW_PREFIX/share/zsh-completions" $fpath)

source "$ZSH/oh-my-zsh.sh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ------------------------------------------------------------------ PATH ----
path=(
  "$HOME/.local/bin"
  /opt/homebrew/opt/libpq/bin
  /opt/homebrew/opt/make/libexec/gnubin
  /opt/homebrew/opt/coreutils/libexec/gnubin
  /opt/homebrew/bin
  $path
)

# ------------------------------------------------------------- toolchain ----
export PYTHON3=/opt/homebrew/bin/python3

# OpenSSL (static path instead of 3x `brew --prefix`, which slowed startup)
_openssl=/opt/homebrew/opt/openssl
export LDFLAGS="-L$_openssl/lib"
export CPPFLAGS="-I$_openssl/include"
export LIBRARY_PATH="$_openssl/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"   # fallback if the linker ignores LDFLAGS
unset _openssl

# --------------------------------------------------------------- editors ----
# Do not set VIMRUNTIME: nvim finds its own runtime, and a pinned Cellar path
# (previously 0.12.5_1) breaks nvim on every `brew upgrade`.
export EDITOR=nvim
export VISUAL=nvim
alias vim=nvim

# ------------------------------------------------------------------ tmux ----
# `t` attaches to (or creates) a "main" session; `tf` opens the fuzzy session picker.
alias t='tmux new-session -A -s main'
alias tf='tmux-sessionizer'

# Open the key cheatsheet (tmux / AeroSpace / nvim)
alias keys='open ~/workspace/dotfiles/cheatsheet.html'

# ------------------------------------------------------------- Coder VM ----
# `vm [workspace]` opens the Coder VM's tmux session ("main") in its own iTerm
# window on AeroSpace workspace O (⌥O). If that window already exists it just
# switches there. The window is always a fresh one outside local tmux, so the
# two tmuxes never fight over Ctrl-Space. Detach (Ctrl-Space d) or exit to
# close it; the VM's tmux keeps running.
CODER_VM=${CODER_VM:-green-sturgeon-38}
vm() {
  local ws=${1:-$CODER_VM}
  if (( $(aerospace list-windows --workspace O --count 2>/dev/null || echo 0) > 0 )); then
    aerospace workspace O
    return
  fi
  osascript -e "tell application \"iTerm\" to create window with default profile command \"/bin/zsh -lic '_vm_attach $ws'\"" >/dev/null
}
# Runs inside the new window: move it to workspace O, then attach over ssh.
_vm_attach() {
  sleep 0.3   # let AeroSpace's new-window rule (iTerm -> T) run first
  local id
  id=$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null)
  [[ -n $id ]] && aerospace move-node-to-workspace --focus-follows-window --window-id "$id" O
  ssh "$1.coder" -t tmux new -A -s main ||
    { print "\nssh exited with $?. Press Enter to close."; read -r; }
}

# ------------------------------------------------------------ local only ----
# Host shortnames (kept out of the dotfiles repo).
[[ -f ~/host_aliases ]] && export $(grep -v '^[[:space:]]*#' ~/host_aliases | xargs)
# Machine-specific overrides / secrets, never committed.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# zoxide (keep last: it hooks the prompt)
eval "$(zoxide init zsh)"
