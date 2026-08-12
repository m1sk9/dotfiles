-- leader は lazy.nvim の読み込み前に確定させる必要がある（init.lua の Why not 参照）
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "検索ハイライトを消す" })

-- ウィンドウ間の移動（herdr の prefix を挟まないので衝突しない）
map("n", "<C-h>", "<C-w>h", { desc = "左のウィンドウへ" })
map("n", "<C-j>", "<C-w>j", { desc = "下のウィンドウへ" })
map("n", "<C-k>", "<C-w>k", { desc = "上のウィンドウへ" })
map("n", "<C-l>", "<C-w>l", { desc = "右のウィンドウへ" })

-- 選択行の移動とインデント（gv で選択を保持し続ける）
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "選択行を下へ" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "選択行を上へ" })
map("v", "<", "<gv", { desc = "インデントを減らす" })
map("v", ">", ">gv", { desc = "インデントを増やす" })

map("n", "<leader>w", "<cmd>write<CR>", { desc = "保存" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "ウィンドウを閉じる" })

-- <leader>e / <leader>E はファイルツリーの担当（lua/plugins/filetree.lua）

map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "バッファを閉じる" })
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "次のバッファ" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "前のバッファ" })
