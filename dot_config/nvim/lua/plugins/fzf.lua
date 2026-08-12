-- Why not telescope.nvim: 検索の実体を既にある fzf / fd / ripgrep に委ねられ，
-- plenary.nvim などの依存も増えないため最小構成に向く
return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  keys = {
    { "<leader>ff", "<cmd>FzfLua files<CR>", desc = "ファイルを探す" },
    { "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "全文検索 (grep)" },
    { "<leader>fb", "<cmd>FzfLua buffers<CR>", desc = "バッファ一覧" },
    { "<leader>fd", "<cmd>FzfLua diagnostics_document<CR>", desc = "このファイルの診断" },
    { "<leader>fh", "<cmd>FzfLua helptags<CR>", desc = "ヘルプを引く" },
    { "<leader>fk", "<cmd>FzfLua keymaps<CR>", desc = "キーマップ一覧" },
    { "<leader>fr", "<cmd>FzfLua resume<CR>", desc = "直前の検索を再開" },
  },
  opts = {},
}
