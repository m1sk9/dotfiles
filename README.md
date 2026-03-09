# dotfiles

Dotfiles for setting up m1sk9's development environment.

Supports macOS and can be set up using [chezmoi](https://github.com/twpayne/chezmoi).

## Installation

First, install [“Command Line Tools for Xcode”](https://developer.apple.com/documentation/xcode/installing-the-command-line-tools/#Download-and-install-the-Command-Line-Tools-for-Xcode-package) to enable Homebrew and Git.

```bash
# git will prompt you to install it during first execution
git
# Install Homebrew
/bin/bash -c “$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)”
```

After installation, install chezmoi and initialize using this repository

```bash
brew install chezmoi
chezmoi init <url>
```

Once initialization is complete, use Homebrew to install the application.

```bash
brew bundle --zap --file ‘~/.Brewfile’
```

After completing all setups, switch the URL in your Git repository config to SSH. (I dislike HTTPS authentication via PAT, so I use SSH authentication. Otherwise, operations like pull will fail.)

```bash
vim .git/config
```

## License

These dotfiles are distributed under ["The Unlicense"](./LICENSE). Feel free to reference the config, but I take no responsibility.
