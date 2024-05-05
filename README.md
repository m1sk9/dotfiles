# dotfiles

m1sk9's dotfiles.

![m1sk9's dotfiles](./screenshot.jpg)
I love the Rust and I'm a Rustacean. 🦀

## Features

- **Editor & IDE**: [Visual Studio Code](https://code.visualstudio.com/), [JetBrains IDE](https://www.jetbrains.com/)
    - Other. Use [Vim](https://www.vim.org/) for simple terminal editing. I don't use it for everyday use.
- **Termial**: [Alacritty](https://alacritty.org/)
- **Shell**: [Fish](https://fishshell.com/)

## Usage

### How to setup

Summarized in [the article](https://zenn.dev/m1sk9/articles/my-dotfiles-docs). Read it.

> [!WARNING]
>
> This dotfiles is supported on macOS. Other OSs are not tested.

> [!NOTE]
> 
> The following files are located in 1Password's Vault. These dotfiles contain only the uuid used by 1Password and do not work by themselves.
> 
> - SSH Config (`~/.ssh/config`)
> - SSH Smartcard Pub (`~/.ssh/smardcard.pub`)
> 
> You must be logged into 1Password and 1Password CLI to access these file entities. After logging in, run `chezmoi apply`.

### Update formula and packages (using [topgrade](https://github.com/topgrade-rs/topgrade))

To update the entire ecosystem, including the macOS software, simply run the following command.

```sh 
topgrade
```

> [!IMPORTANT]
>
> With the setting [`.config/topgrade.toml`](./dot_config/topgrade.toml), topgrade does not apply `pnpm`, `yarn` globally installed packages, and `chezmoi`. (The culture of installing npm modules globally is disgusting. lol)
