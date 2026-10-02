# dotfiles

dotfiles for setting up m1sk9's development environment.

Supports macOS and can be set up using [chezmoi](https://github.com/twpayne/chezmoi).

## Installation

### Before you start

1. Sign in to the App Store (the Brewfile installs App Store apps with `mas`, which cannot sign in by itself).
2. Insert the YubiKey.

### Run

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply m1sk9
```

This clones the repository to `~/dotfiles` and applies it. Along the way it asks for:

- the passphrase of the age key (`.chezmoi-key.age`)
- your password for `sudo` (Homebrew, and switching the login shell to fish)

In order, the apply:

1. decrypts the age key to `~/.config/chezmoi/key.txt`
2. installs Homebrew (with the Command Line Tools), runs `brew bundle`, and installs Claude Code
3. deploys the dotfiles and runs the setup scripts (Rust, MCP servers, herdr plugins, macOS defaults)
4. imports the GPG public key and creates the YubiKey stubs
5. switches the `~/dotfiles` remote to SSH
6. makes fish the login shell, and removes the bootstrap copy of chezmoi in favour of the Homebrew one

If the YubiKey or the App Store sign-in was missing, fix it and run `chezmoi apply` again.

### After it finishes

1. Open Hammerspoon and grant it Accessibility access.
2. Run `claude` and log in.
3. Open a new terminal (fish starts as the login shell).
4. Enter the YubiKey PIN on the first `git pull` / `git push`.

## Special Thanks

The following content is sourced from the references listed below. Thank you, as always, for the helpful information.

All files (everyday): [Anthropic](https://www.anthropic.com) & [Claude](https://claude.ai/) ;)

- `private_dot_claude/CLAUDE.md`
  - **情報源の扱い**: Void戦士ちゃん (@voidwarriorchan) - [「日本語でAIが馬鹿にならないようにするSkill」](https://x.com/voidwarriorchan/status/2070841754815971773)

## License

These dotfiles are distributed under ["The Unlicense"](./LICENSE). Feel free to reference the config, but I take no responsibility.
