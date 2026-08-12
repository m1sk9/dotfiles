-- Why not lazy.nvim を先に読み込む: keymaps.lua が vim.g.mapleader を設定しており，
-- これが lazy.nvim の読み込みより後だとプラグイン側の <leader> マッピングが
-- 素の <Space> として登録されてしまう
require("options")
require("keymaps")

-- Why not .chezmoiexternal.toml で取得: lazy.nvim 自身が自己更新と
-- バージョン固定 (lazy-lock.json) を持つため，chezmoi external とは二重管理になる
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "lazy.nvim の clone に失敗しました\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- lua/plugins/ 配下の全ファイルを spec として読み込む．
  -- プラグインの追加はこのディレクトリに 1 ファイル置くだけで完結する
  spec = { { import = "plugins" } },
  install = { colorscheme = { "gruvbox" } },
  -- Why not checker を有効化: 起動ごとに更新確認の通知が出ると入門時のノイズになる．
  -- 更新は :Lazy update を手で叩く
  checker = { enabled = false },
  change_detection = { notify = false },
})
