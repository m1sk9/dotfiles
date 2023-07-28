import {
    exec,
    defineTask,
    home,
    link,
    printCheckResults,
} from "./deps.ts"

if(!home) {
    throw new Error("[$HOME] is not set")
}

const deployDotfiles = defineTask([
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

const setupDotfiles = defineTask([
    // Install Homebrew
    exec({
        cmd: "bin/bash",
        args: ["-c", "\"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)\""],
    }),
    // Install Rosetta2
    exec({
        cmd: "sudo",
        args: ["softwareupdate", "--install-rosetta", "--agree-to-license"],
    }),
    exec({
        cmd: "source",
        args: ["~/dotfiles/.zshrc"],
    }),
    exec({
        cmd: "./homebrew.sh",
        args: [""],
    }),
    exec({
        cmd: "git",
        args: ["clone", "https://github.com/tmux-plugins/tpm", "~/.tmux/plugins/tpm"],
    }),
])

if (Deno.args.includes('deploy')) {
    if(Deno.args.includes('run')) {
        await deployDotfiles.run()
    } else {
        printCheckResults(await deployDotfiles.check())
    }
} else if (Deno.args.includes('setup')) {
    if(Deno.args.includes('run')) {
        await setupDotfiles.run()
    } else {
        printCheckResults(await setupDotfiles.check())
    }
} else {
    console.log('Usage: deno run --allow-read --allow-write dotfiles.ts [deploy|setup]')
    Deno.exit(1)
}
