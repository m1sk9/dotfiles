# dotfiles

[![test](https://github.com/m1sk9/dotfiles/actions/workflows/test.yml/badge.svg)](https://github.com/m1sk9/dotfiles/actions/workflows/test.yml)

```shell
git clone https://github.com/lis2a/dotfiles.git
cd dotfiles
curl -fsSL https://deno.land/x/install/install.sh | sh
deno task ...
```

----

## Available tasks

- `deploy`: dotfiles を展開します。
  - `deploy:check`: 展開状況を表示します。
- `setup`: Homebrew などのインストールを行います。
  - `setup:check`: 設定状況を表示します。
