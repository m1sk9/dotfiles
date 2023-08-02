import { defineTask, link, home } from "../deps.ts";

if(!home) {
    throw new Error('[home] is not defined')
}

export const linkDotfile = defineTask([
    // fish
    link({
        source: './config/fish/config.fish',
        destination: `${home}/.config/fish/config.fish`,
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
    // Git
    link({
        source: './.gitconfig',
        destination: `${home}/.gitconfig`,
    })
])
