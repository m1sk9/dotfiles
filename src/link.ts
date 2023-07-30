import { defineTask, link, home } from "../deps.ts";

if(!home) {
    throw new Error('[home] is not defined')
}

export const linkDotfile = defineTask([
    // zsh
    link({
        source: './config/zsh/.zprofile',
        destination: `${home}/.zprofile`,
    }),
    link({
        source: './config/zsh/.zshrc',
        destination: `${home}/.zshrc`,
    }),
    link({
        source: './config/zsh/.zshenv',
        destination: `${home}/.zshenv`,
    }),
    // tmux
    link({
        source: './config/tmux/.tmux.conf',
        destination: `${home}/.tmux.conf`,
    }),
    link({
        source: './config/tmux/theme.conf',
        destination: `${home}/.tmux/theme.conf`,
    }),
    // Alacritty
    link({
        source: './config/alacritty',
        destination: `${home}/.config/alacritty`,
    }),
    // git
    link({
        source: './config/git',
        destination: `${home}/.config/git`,
    }),
    // lazygit
    link({
        source: './config/lazygit',
        destination: `${home}/.config/lazygit`,
    }),
    // Homebrew
    link({
        source: './config/Brewfile',
        destination: `${home}/Brewfile`,
    }),
    // SSH
    link({
        source: './ssh',
        destination: `${home}/.ssh`,
    }),
    /**
     * .config, .gitconfig は GitHub Actions 上では必ず失敗する
     * これは、GitHub Actions のホスト環境で既に存在しているためである
     */
    link({
        source: './config/others',
        destination: `${home}/.config/others`,
    }),
    // Git
    link({
        source: './.gitconfig',
        destination: `${home}/.gitconfig`,
    })
])
