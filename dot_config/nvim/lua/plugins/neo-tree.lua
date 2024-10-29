local set = vim.keymap.set
set('n', '<C-n>', ':Neotree filesystem reveal left<CR>')

return {
    { 
        "nvim-tree/nvim-tree.lua",
        version = "v1.x"
    }
}
