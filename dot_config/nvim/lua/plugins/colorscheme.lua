-- Ghostty (theme = Gruvbox Dark Hard) と herdr (theme = gruvbox) に配色を揃える
return {
  "ellisonleao/gruvbox.nvim",
  lazy = false,
  -- 他プラグインより先に読み込まないと，起動直後に既定配色が一瞬見える
  priority = 1000,
  opts = {
    contrast = "hard",
  },
  config = function(_, opts)
    require("gruvbox").setup(opts)
    vim.cmd.colorscheme("gruvbox")
  end,
}
