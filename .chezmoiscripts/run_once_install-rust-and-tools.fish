#!/usr/bin/env fish

# Install Rust via rustup
if not command -q rustc
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # Add cargo to PATH for the current session
    set -gx PATH $HOME/.cargo/bin $PATH
end
