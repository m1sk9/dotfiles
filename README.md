# dotfiles

dotfiles for setting up m1sk9's development environment.

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

After completing all setups, switch the URL in your Git repository config to SSH. (I hate HTTPS authentication via PAT, so I use SSH authentication. Otherwise, operations like pull will fail.)

```bash
vim .git/config
```

## Special Thanks

The following content is sourced from the references listed below. Thank you, as always, for the helpful information.

All files (everyday): [Anthropic](https://www.anthropic.com) & [Claude](https://claude.ai/) ;)

- `private_dot_claude/CLAUDE.md`
  - **情報源の扱い**: Void戦士ちゃん (@voidwarriorchan) - [「日本語でAIが馬鹿にならないようにするSkill」](https://x.com/voidwarriorchan/status/2070841754815971773)
- `private_dot_claude/executable_statusline.sh`: kawarimidoll - [「うちのClaude Codeのstatuslineモエス見てつーか見ろ♪」](https://zenn.dev/kawarimidoll/articles/00cfa200c12c5f)

## License

These dotfiles are distributed under ["The Unlicense"](./LICENSE). Feel free to reference the config, but I take no responsibility.
