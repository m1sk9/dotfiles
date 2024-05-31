require ('core.keymap')
require ('core.options')

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
    { import = "plugins.ui" },
})
require('trouble').setup()

require('nvim-tree').setup({
  sort_by = 'case_sensitive',
  view = {
    adaptive_size = true,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})
require("nvim-tree.api").tree.toggle(false, true)

require('lualine').setup({
  options = { theme = 'auto' },
})

vim.cmd[[colorscheme rose-pine]]
