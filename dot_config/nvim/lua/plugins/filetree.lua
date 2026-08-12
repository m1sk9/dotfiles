-- Why not netrw のまま: netrw は開くたびにカレントバッファを置き換えるため，
-- Zed の project_panel のような「常設の左サイドバー」にはならない
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- 起動時に自動で開きたいので cmd 遅延ではなく VimEnter で読み込む
  event = "VimEnter",
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "ファイルツリーの開閉" },
    { "<leader>E", "<cmd>NvimTreeFindFile<CR>", desc = "ツリーで現在のファイルを表示" },
  },
  -- netrw を無効化しないと nvim-tree と競合する（公式が strongly advised としている）．
  -- lazy.nvim の init は require("lazy").setup() 中に走るので，
  -- Neovim が runtime の netrw プラグインを読む前に間に合う
  init = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  opts = {
    view = { width = 34 },
    renderer = {
      group_empty = true,
      icons = {
        -- Zed の project_panel (file_icons: true / folder_icons: false) に揃える．
        -- ディレクトリは矢印だけで表す
        show = { file = true, folder = false, folder_arrow = true },
      },
    },
    -- 編集中のファイルをツリー側でも選択状態にする（Zed の project_panel と同じ挙動）
    update_focused_file = { enable = true },
    -- 既定は false．LSP の診断をツリーにも出す
    diagnostics = { enable = true },
    filters = {
      -- Why not dotfiles = true: このリポジトリは .chezmoiignore /
      -- .chezmoitemplates / .chezmoi.toml.tmpl といったドットファイル自体が
      -- 管理対象なので，隠すと肝心のものが見えなくなる（既定値だが意図として明示）
      dotfiles = false,
    },
  },
  config = function(_, opts)
    require("nvim-tree").setup(opts)
    require("nvim-tree.api").tree.open()
  end,
}
