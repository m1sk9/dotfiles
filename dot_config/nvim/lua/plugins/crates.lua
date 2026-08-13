-- Cargo.toml の依存バージョン補完・更新通知．
-- lsp.enabled = true で in-process language server として動くので，
-- 既存の blink.cmp "lsp" ソースにそのまま補完が流れる（cmp 個別設定は不要）
return {
  "saecki/crates.nvim",
  tag = "stable",
  event = { "BufRead Cargo.toml" },
  opts = {
    lsp = {
      enabled = true,
      completion = true,
      hover = true,
      actions = true,
    },
  },
}
