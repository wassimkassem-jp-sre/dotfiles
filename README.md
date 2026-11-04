# dotfiles

macOS dev setup: **AeroSpace** (windows) + **tmux** (sessions/panes) + **nvim** (editor) + **zsh**.
Each top-level directory is a [GNU stow](https://www.gnu.org/software/stow/) package that mirrors `$HOME`.

| Package     | Links to                                   |
|-------------|--------------------------------------------|
| `zsh`       | `~/.zshrc`, `~/.zprofile`, `~/.p10k.zsh`   |
| `tmux`      | `~/.config/tmux/tmux.conf`                 |
| `aerospace` | `~/.config/aerospace/aerospace.toml`       |
| `nvim`      | `~/.config/nvim` (NvChad v2.5 starter)     |
| `bin`       | `~/.local/bin/tmux-sessionizer`            |

## Install on a new Mac

```bash
git clone <this repo> ~/dotfiles
brew bundle --file ~/dotfiles/Brewfile
~/dotfiles/install.sh          # stow every package (target is ~, see .stowrc)
```

oh-my-zsh and powerlevel10k are installed separately (see their docs).
If a real file already exists where a link should go, stow refuses; move it
away, or run `stow --adopt <pkg>` to pull it into the repo, then `git diff`.

Optional tmux plugins (session restore after reboot):

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
# then inside tmux: Ctrl-Space I
```

## One-time macOS settings

- **Free up Ctrl-Space** for tmux: System Settings → Keyboard → Keyboard Shortcuts →
  Input Sources → untick "Select the previous input source" (and "next source").
  On a JIS keyboard, 英数 / かな already switch input.
- **Quit Rectangle** (and remove it from Login Items): it fights AeroSpace over window placement.
- Recommended by AeroSpace: System Settings → Desktop & Dock → Mission Control →
  turn on "Group windows by application".

## Key map

Modifier ownership: **Option** = AeroSpace, **Ctrl-Space** = tmux prefix, **Space** = nvim leader.

### AeroSpace (Option)

| Keys                        | Action                                         |
|-----------------------------|------------------------------------------------|
| `⌥ h/j/k/l`                 | focus window                                   |
| `⌥ ⇧ h/j/k/l`               | move window                                    |
| `⌥ 1-5`, `⌥ c/a/s/t/e/b/n`  | workspace (Chrome, clAude, Slack, Terminal, Editor, safari/Browser, Notion) |
| `⌥ ⇧ <ws>`                  | send window to workspace and follow            |
| `⌥ tab`                     | previous workspace                             |
| `⌥ f` / `⌥ ⇧ f`             | fullscreen / float toggle                      |
| `⌥ /` / `⌥ ,`               | tiles / accordion layout                       |
| `⌥ -` / `⌥ ^`               | shrink / grow (JIS `^` = US `=`)               |
| `⌥ r`                       | resize mode (h/j/k/l, b balance, esc)          |
| `⌥ enter`                   | new iTerm window                               |
| `⌥ ⇧ ;`                     | service mode (esc reload, r reset, f float)    |

Every new window is sent to its app's workspace when it opens: Chrome → C, Claude → A, Slack → S,
iTerm/Terminal → T, Cursor/VS Code → E, Safari → B, Notion → N.
Workspaces take the app's first letter; on a collision, the next free letter
(Claude: C is Chrome's and L is focus-right, so A).

### tmux (prefix `Ctrl-Space`)

| Keys              | Action                                        |
|-------------------|-----------------------------------------------|
| `v` or `\|`       | split side by side                            |
| `s` or `-`        | split stacked                                 |
| `h/j/k/l`         | select pane (`H/J/K/L` resize, repeatable)    |
| `Ctrl-h/j/k/l`    | move between panes *and nvim splits* (no prefix) |
| `z`               | zoom pane                                     |
| `x` / `X`         | kill pane / window                            |
| `c`, `n`, `p`     | new / next / previous window                  |
| `f`               | fuzzy session picker (zoxide dirs + ~/workspace) |
| `S`               | session tree · `Tab` last session             |
| `[`               | copy mode (`v` select, `y` copy to clipboard) |
| `r`               | reload config                                 |
| `Ctrl-Space` ×2   | send Ctrl-Space to the app (nvim completion)  |
| `Ctrl-l`          | clear the shell screen                        |

Shell aliases: `t` attaches to a `main` session, `tf` runs the session picker.

## Local, untracked files

- `~/host_aliases` — host shortnames exported by `.zshrc`
- `~/.zshrc.local` — machine-specific settings or secrets, sourced last
