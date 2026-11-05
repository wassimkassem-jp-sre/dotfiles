# dotfiles

Linux dev setup (`linux` branch; the Mac lives on `macos`): **tmux** + **nvim** + **zsh**,
used on Coder VMs so nvim can replace Cursor. Each top-level directory is a
[GNU stow](https://www.gnu.org/software/stow/) package that mirrors `$HOME`.

| Package  | Links to                                           | Shared with `macos` |
|----------|----------------------------------------------------|---------------------|
| `nvim`   | `~/.config/nvim` (NvChad v2.5)                     | yes, identical      |
| `tmux`   | `~/.config/tmux/tmux.conf`                         | yes, identical      |
| `bin`    | `~/.local/bin/tmux-sessionizer`                    | yes, identical      |
| `zsh`    | `~/.zshrc`, `~/.p10k.zsh` (zinit + powerlevel10k)  | no, Linux only      |
| `gnupg`  | `~/.gnupg/gpg-agent.conf` (terminal pinentry)      | no, Linux only      |

## Set up a Coder VM

From the Mac, connect without going through local tmux:

```bash
coder config-ssh                    # once: adds <workspace>.coder SSH hosts
ssh green-sturgeon-38.coder
```

On the VM:

```bash
git clone -b linux https://github.com/wassimkassem-jp-sre/dotfiles.git ~/workspace/dotfiles
cd ~/workspace/dotfiles
./bootstrap.sh     # apt: stow tmux zsh ripgrep; ~/.local: nvim lazygit gh fzf zoxide node
./install.sh       # stow every package; existing files move to ~/dotfiles-backup-<date>/
exec zsh           # zinit downloads its plugins on first start (takes a minute)
nvim               # lazy.nvim installs the plugins on first start
gh auth login      # for Octo (PRs inside nvim)
```

The very first nvim start may show "Failed to run `config` for indent-blankline": NvChad
builds its theme cache on that run. Quit and start nvim again; it's clean from then on.

`bootstrap.sh` is safe to re-run; `./bootstrap.sh -u` upgrades the `~/.local` tools.
It makes zsh the login shell when it has sudo.

From then on, one command from the Mac lands in the VM's tmux:

```bash
ssh green-sturgeon-38.coder -t tmux new -A -s main
```

tmux keeps running on the VM, so a dropped connection or a sleeping laptop loses nothing:
reconnect and you're back where you were.

## Clipboard

`y` in tmux copy mode and yanks in nvim reach the Mac clipboard over SSH (OSC 52).
On the Mac, turn on iTerm → Settings → General → Selection →
"Applications in terminal may access clipboard".

## Keeping the branches in sync

`nvim`, `tmux`, `bin` and `install.sh` are the same files on both branches. After changing
them on one branch, copy them to the other:

```bash
git checkout macos -- nvim tmux bin install.sh   # run on the linux branch
```

## Coder notes

- `~/.zprofile` is written by Coder (git author, `CLAUDE_CONFIG_DIR`, ...), so this repo
  doesn't manage it. Tools from `/workspace/WayveCode/tools` (gh, rg, claude) come in via
  `/etc/environment`; `bootstrap.sh` skips anything already on `PATH`.
- The home directory is on NFS, so `~/.local` (nvim, node, lazygit, ...) and the stow links
  survive VM rebuilds; apt packages don't. stow is only needed to relink, so after a rebuild
  just re-run `./bootstrap.sh` before the next `./install.sh`.

## Local, untracked files

- `~/.zshrc.local` — machine-specific settings or secrets, sourced last
- `TMUX_SESSIONIZER_DIRS` (set in `.zshrc`) — folders the `prefix f` picker lists
