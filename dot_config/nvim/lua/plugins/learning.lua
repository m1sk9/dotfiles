-- vim 操作の学習支援．操作が身についたら遠慮なく削っていい区画
return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>b", group = "バッファ" },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "このバッファのキーマップ",
      },
    },
  },
}
