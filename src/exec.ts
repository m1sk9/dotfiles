import { defineTask, exec } from "../deps.ts"

export const execDotfiles = defineTask([
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
