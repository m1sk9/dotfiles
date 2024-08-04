-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

lvim.plugins = {
  { "rose-pine/neovim", name = "rose-pine" },
  { "github/copilot.vim" }
}

lvim.colorscheme = "rose-pine"

--- Keymap
local disable_keys = { "<Up>", "<Down>", "<Left>", "<Right>" }

for _, key in ipairs(disable_keys) do
  vim.api.nvim_set_keymap('n', key, '<Nop>', { noremap = true, silent = true })
end

for _, key in ipairs(disable_keys) do
  vim.api.nvim_set_keymap('v', key, '<Nop>', { noremap = true, silent = true })
end

for _, key in ipairs(disable_keys) do
   vim.api.nvim_set_keymap('i', key, '<Nop>', { noremap = true, silent = true })
end

