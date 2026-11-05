# dotfiles

macOS dev setup (`macos` branch; Linux lives on `linux`): **AeroSpace** (windows) + **tmux** (sessions/panes) + **nvim** (editor) + **zsh**.
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
git clone -b macos git@github.com:wassimkassem-jp-sre/dotfiles.git ~/workspace/dotfiles
brew bundle --file ~/workspace/dotfiles/Brewfile
~/workspace/dotfiles/install.sh       # stow every package (target is ~, see .stowrc)
```

oh-my-zsh and powerlevel10k are installed separately (see their docs).
If a real file already exists where a link should go, `install.sh` moves it to
`~/dotfiles-backup-<date>/` first. `./install.sh -n` shows what would change.

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

Printable, searchable version: [`cheatsheet.html`](cheatsheet.html) (run `keys` in a shell to open it).

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

Monitors: with any external display connected, every workspace lives on it and the laptop screen
shows a spare, empty one. Undocked, all workspaces fall back to the laptop.
If the Option shortcuts ever stop working (e.g. after granting Accessibility), quit AeroSpace from
its menu-bar icon and reopen it; `reload-config` alone doesn't fix that.
If a window misses its rule (e.g. it was off-screen at startup), re-run the rules with
`aerospace run-callback --for-every-window on-window-detected`.

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

## Coder VM (nvim instead of Cursor)

Code runs on the Coder VM, so nvim does too: SSH in from iTerm and run tmux + nvim there.
The VM uses the `linux` branch, which shares this branch's `nvim`, `tmux` and `bin` packages
(see its README for the setup).

```bash
coder config-ssh                                         # once: adds <workspace>.coder hosts
ssh green-sturgeon-38.coder -t tmux new -A -s main       # attach to tmux on the VM
```

- Open that from an iTerm tab that is **not** inside local tmux, or both tmuxes fight over Ctrl-Space.
- Copying (`y` in tmux copy mode, `y` in nvim) reaches the Mac clipboard over SSH via OSC 52 once
  iTerm → Settings → General → Selection → "Applications in terminal may access clipboard" is on.
- Web apps on the VM: `coder port-forward green-sturgeon-38 --tcp 8080`.
- Keep the shared packages identical on both branches: change them on one branch, then
  `git checkout <other-branch> -- nvim tmux bin install.sh` on the other.

## Local, untracked files

- `~/host_aliases` — host shortnames exported by `.zshrc`
- `~/.zshrc.local` — machine-specific settings or secrets, sourced last
