dotfiles for various dev tools

## Requirements

- stow
- zsh

## Installation and use

First time use?


```bash
stow -d. -t~
```

When adding to your dotfiles

```bash
stow -d. -t~ --adopt
```

> [!warning]
> Commit changes before running the above command. It will overwrite you dotfiles.

## Tools

- lazygit
- neovim
- zinit
- fzf
- zoxide
