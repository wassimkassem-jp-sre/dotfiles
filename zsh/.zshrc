# ~/.zshrc — managed in the dotfiles repo, linux branch (zsh package, linked
# with GNU stow). Used on Linux dev machines such as Coder VMs.

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Tools installed by ./bootstrap.sh live in ~/.local/bin (nvim, lazygit, gh, ...).
typeset -U path
path=("$HOME/.local/bin" $path)

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History (same file and size as the Coder VM template's own .zshrc, so the
# existing history carries over)
mkdir -p ~/.config/zsh
HISTSIZE=1000000
HISTFILE=~/.config/zsh/history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Editor
export EDITOR=nvim
export VISUAL=nvim

# Aliases (t / tf match the macos branch)
alias ls='ls --color'
alias vim='nvim'
alias c='clear'
alias t='tmux new-session -A -s main'   # attach to (or create) the "main" session
alias tf='tmux-sessionizer'             # pick a project, jump to its session

# tmux-sessionizer (prefix f) offers the folders inside these directories.
export TMUX_SESSIONIZER_DIRS="$HOME/workspace $HOME"

# Shell integrations: Ctrl-r history search, Ctrl-t file picker, Alt-c cd.
if command -v fzf >/dev/null && fzf --zsh >/dev/null 2>&1; then
  source <(fzf --zsh)
fi
eval "$(zoxide init --cmd cd zsh)"

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

export GPG_TTY=$(tty)

# CUDA
if [[ -d "/usr/local/cuda" ]]; then
  export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda/lib64
fi

# Machine-specific settings that should not be committed.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
