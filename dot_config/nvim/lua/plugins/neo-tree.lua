local set = vim.keymap.set
set('n', '<C-n>', ':Neotree filesystem reveal left<CR>')

return {
    { 
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
    }
}
