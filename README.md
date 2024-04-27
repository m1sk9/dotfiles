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


**1. Install Command Line Tools**

```sh
xcode-select --install
```

> [!NOTE]
> If the installation is rejected, we recommend installing directly from the Apple Developer site.
> 
> [XCode Resources -- Apple Developer](https://developer.apple.com/xcode/resources/)

**2. Install Homebrew**

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**3. Install chezmoi**

```sh
brew install chezmoi
```

**4. Initialize chezmoi**

```sh
# HTTPS
chezmoi init https://github.com/m1sk9/dotfiles.git
# SSH
chezmoi init git@github.com:m1sk9/dotfiles.git
```

**5. Apply the dotfiles.**

```sh
chezmoi apply
```

### Edit dotfiles

Editing files in dotfiles is done via chezmoi. A commit push to `m1sk9/dotfiles` is done at the same time.

**Direct editing is not recommended.**

```sh
chezmoi edit <file_path>
```

**Don't forget to apply the edits.**

```sh
chezmoi apply
```

### Update formula and packages (using [topgrade](https://github.com/topgrade-rs/topgrade))

To update the entire ecosystem, including the macOS software, simply run the following command.

```sh 
topgrade
```

> [!IMPORTANT]
>
> With the setting [`.config/topgrade.toml`](./dot_config/topgrade.toml), topgrade does not apply `pnpm`, `yarn` globally installed packages, and `chezmoi`. (The culture of installing npm modules globally is disgusting. lol)
