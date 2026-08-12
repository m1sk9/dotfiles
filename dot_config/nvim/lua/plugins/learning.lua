-- vim 操作の学習支援．操作が身についたら遠慮なく削っていい区画
return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>b", group = "バッファ" },
        { "<leader>c", group = "コード / LSP" },
        { "<leader>f", group = "検索" },
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

  {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      -- Why not 既定の "block": 入門初日から入力を弾かれると作業が止まる．
      -- まず警告だけ出し，hjkl 連打が減ってきたら "block" に上げる
      restriction_mode = "hint",
      -- Why not 既定の矢印キー無効化: 上と同じ理由で最初は許可する．
      -- 慣れたらこのテーブルごと消せば既定の「矢印キー禁止」に戻る
      disabled_keys = {
        ["<Up>"] = false,
        ["<Down>"] = false,
        ["<Left>"] = false,
        ["<Right>"] = false,
      },
      disable_mouse = false,
    },
  },
}
