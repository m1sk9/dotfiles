-- Ghostty (theme = TokyoNight Night) と herdr (theme = tokyo-night) に配色を揃える
return {
  "folke/tokyonight.nvim",
  lazy = false,
  -- 他プラグインより先に読み込まないと，起動直後に既定配色が一瞬見える
  priority = 1000,
  opts = {
    style = "night",
    -- Why not 不透明: Ghostty 側の background-opacity = 0.85 と background-blur を活かす
    transparent = true,
    styles = { sidebars = "transparent", floats = "transparent" },
  },
  config = function(_, opts)
    require("tokyonight").setup(opts)
    vim.cmd.colorscheme("tokyonight")
  end,
}
