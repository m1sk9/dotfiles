-- Ghostty (theme = Terafox) と herdr (theme.custom = terafox 準拠) に配色を揃える
return {
  "EdenEast/nightfox.nvim",
  lazy = false,
  -- 他プラグインより先に読み込まないと，起動直後に既定配色が一瞬見える
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("terafox")
  end,
}
