-- Load the core modules
require ('core.keymap')
require ('core.options')

-- lazy.nvim setup
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { import = "plugins" },
    { import = "plugins.themes" },
    { import = "plugins.neo-tree" }
})

-- Visual setup
vim.opt.termguicolors = true
vim.opt.winblend = 0
vim.opt.pumblend = 0
require('rose-pine').setup({
  styles = {
    bold = true,
    italic = true,
    transparency = true,
  },
})
vim.cmd[[colorscheme rose-pine-moon]]
