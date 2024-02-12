# dotfiles

m1sk9's dotfiles.

## How to setup

### macOS

1. Install Command Line Tools.

```sh
xcode-select --install
```

> [!NOTE]
> If the installation is rejected, we recommend installing directly from the Apple Developer site.
> [XCode Resources -- Apple Developer](https://developer.apple.com/xcode/resources/)

2. Install Homebrew.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

3. Install chezmoi.

```sh
brew install chezmoi
```

4. Initialize chezmoi with the contents of `m1sk9/dotfiles`.

```sh
# HTTPS
chezmoi init https://github.com/m1sk9/dotfiles.git
# SSH
chezmoi init git@github.com:m1sk9/dotfiles.git
```

5. Apply the dotfiles.

```sh
chezmoi apply
```

## Edit dotfiles

Editing files in dotfiles is done via chezmoi. Direct editing is not recommended.

```sh
chezmoi edit <file_path>
```

**Don't forget to apply the edits.**

```sh
chezmoi apply
```

## Note: For secure files managed by 1Password

The following files are located in 1Password's Vault. These dotfiles contain only the uuid used by 1Password and do not work by themselves.

- SSH Config (`~/.ssh/config`)
- SSH Smartcard Pub (`~/.ssh/smardcard.pub`)

You must be logged into 1Password and 1Password CLI to access these file entities. After logging in, run `chezmoi apply`.
