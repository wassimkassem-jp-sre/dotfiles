#!/usr/bin/env bash
# Install the tools these dotfiles expect on a Linux dev machine (a Coder VM,
# Ubuntu/Debian, x86_64 or arm64). Safe to re-run; -u upgrades to the latest.
#   ./bootstrap.sh       install whatever is missing
#   ./bootstrap.sh -u    reinstall the ~/.local tools at their latest release
#
# System packages (stow, tmux, zsh, ripgrep, build tools) come from apt and
# need sudo. Everything else goes into ~/.local without sudo, because apt's
# versions are too old (NvChad needs nvim 0.10+):
#   nvim, lazygit, gh, fzf, zoxide, node (for Mason's language servers)
set -euo pipefail

upgrade=false
[[ ${1:-} == -u ]] && upgrade=true

BIN="$HOME/.local/bin"
OPT="$HOME/.local/opt"
mkdir -p "$BIN" "$OPT"
export PATH="$BIN:$PATH"

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }

case $(uname -m) in
  x86_64)        arch=x86_64; deb=amd64; node_arch=x64 ;;
  aarch64|arm64) arch=arm64;  deb=arm64; node_arch=arm64 ;;
  *) echo "unsupported CPU: $(uname -m)" >&2; exit 1 ;;
esac

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# --- apt packages -------------------------------------------------------------
apt_pkgs=(stow tmux zsh git curl unzip xz-utils build-essential ripgrep)
missing=()
for p in "${apt_pkgs[@]}"; do dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p"); done
if [[ ${#missing[@]} -gt 0 ]]; then
  if sudo -n true 2>/dev/null; then
    say "apt install ${missing[*]}"
    sudo apt-get update -qq 2>&1 | grep -v "^W: .*legacy trusted.gpg" || true
    sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${missing[@]}"
  else
    warn "no passwordless sudo; install these yourself: ${missing[*]}"
  fi
fi

# --- GitHub release tools into ~/.local --------------------------------------
# Print the download URL of the newest release asset of $1 matching regex $2.
release_url() {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" |
    grep -o '"browser_download_url": *"[^"]*"' | cut -d'"' -f4 |
    grep -E -- "$2" | head -1
}

need() { $upgrade || ! command -v "$1" >/dev/null; }

# Download a tarball and copy the named binary from it into ~/.local/bin.
install_bin() {   # name repo asset-regex
  local name=$1 url
  need "$name" || { say "$name already installed"; return; }
  url=$(release_url "$2" "$3")
  [[ -n $url ]] || { warn "no $name release found for $arch"; return; }
  say "$name <- $url"
  rm -rf "$tmp/$name" && mkdir -p "$tmp/$name"
  curl -fsSL "$url" | tar -xz -C "$tmp/$name"
  install -m 755 "$(find "$tmp/$name" -type f -name "$name" | head -1)" "$BIN/$name"
}

# nvim ships as a whole tree (binary + runtime), so it goes into ~/.local/opt.
# Always our own copy, even if the image has one: the snap build can't see a
# private /tmp, and this keeps every VM on the same version.
if $upgrade || [[ ! -x $BIN/nvim ]]; then
  url=$(release_url neovim/neovim "nvim-linux-${arch}\.tar\.gz$")
  say "nvim <- $url"
  rm -rf "$OPT/nvim" && mkdir -p "$OPT/nvim"
  curl -fsSL "$url" | tar -xz -C "$OPT/nvim" --strip-components=1
  ln -sf "$OPT/nvim/bin/nvim" "$BIN/nvim"
else
  say "nvim already installed"
fi

lg_arch=$([[ $arch == x86_64 ]] && echo x86_64 || echo arm64)
install_bin lazygit jesseduffield/lazygit "_[Ll]inux_${lg_arch}\.tar\.gz$"
install_bin gh      cli/cli               "_linux_${deb}\.tar\.gz$"
install_bin fzf     junegunn/fzf          "-linux_${deb}\.tar\.gz$"
zx_arch=$([[ $arch == x86_64 ]] && echo x86_64 || echo aarch64)
install_bin zoxide  ajeetdsouza/zoxide    "-${zx_arch}-unknown-linux-musl\.tar\.gz$"

# Node LTS, for language servers Mason installs with npm (pyright, ...).
if need node; then
  file=$(curl -fsSL https://nodejs.org/dist/latest-v22.x/SHASUMS256.txt |
    grep -o "node-v[0-9.]*-linux-${node_arch}\.tar\.xz" | head -1)
  say "node <- $file"
  rm -rf "$OPT/node" && mkdir -p "$OPT/node"
  curl -fsSL "https://nodejs.org/dist/latest-v22.x/$file" | tar -xJ -C "$OPT/node" --strip-components=1
  for b in node npm npx; do ln -sf "$OPT/node/bin/$b" "$BIN/$b"; done
else
  say "node already installed"
fi

# --- checks -------------------------------------------------------------------
if command -v tmux >/dev/null; then
  v=$(tmux -V | grep -o '[0-9]\+\.[0-9]\+' | head -1)
  awk -v v="$v" 'BEGIN { exit !(v < 3.2) }' &&
    warn "tmux $v is older than 3.2: the prefix-f popup and some settings won't work"
fi

if command -v zsh >/dev/null && [[ $(basename "${SHELL:-}") != zsh ]]; then
  if sudo -n true 2>/dev/null; then
    say "making zsh your login shell"
    sudo chsh -s "$(command -v zsh)" "$USER"
  else
    warn "run: chsh -s $(command -v zsh)"
  fi
fi

say "done. Next: ./install.sh to link the dotfiles, then open a new shell."
