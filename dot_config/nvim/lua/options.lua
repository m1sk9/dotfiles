local opt = vim.opt

-- 行番号
opt.number = true
opt.relativenumber = true

-- 入力
opt.mouse = "a"
opt.clipboard = "unnamedplus"

-- インデント
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true

-- 検索
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- 表示
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.wrap = false
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- ウィンドウ分割
opt.splitright = true
opt.splitbelow = true

-- ファイル
opt.swapfile = false
opt.undofile = true

-- Why not 既定の 4000ms / 1000ms: LSP の診断表示と which-key のポップアップが
-- 体感で「出てこない」と感じる長さになるため詰める
opt.updatetime = 250
opt.timeoutlen = 300
