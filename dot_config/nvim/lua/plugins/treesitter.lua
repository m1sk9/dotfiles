-- Why not master ブランチ: master は Nvim 0.11 向けにロックされ新規 parser の追加が止まっている．
-- main は完全な書き直しで Nvim 0.12+ と tree-sitter CLI を要求するが，
-- Homebrew の neovim が 0.12 系なので条件を満たす（CLI は dot_Brewfile の tree-sitter-cli 参照）
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  -- main ブランチは遅延読み込みを未サポートと明言している
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install({
      "bash",
      "diff",
      "fish",
      "git_rebase",
      "gitcommit",
      "json",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "query",
      "toml",
      "vim",
      "vimdoc",
      "yaml",
    })

    -- Why not install に "jsonc" を並べる: main ブランチに jsonc parser は存在せず
    -- "skipping unsupported language" で捨てられる．コメント付き JSON
    -- (Zed の settings.json，MCP 設定など) は json parser に流す
    vim.treesitter.language.register("json", "jsonc")

    -- main ブランチはハイライトを自動で有効化しない（旧 highlight = { enable = true } は無い）．
    -- parser が未導入の filetype では start() が失敗するので pcall で黙って通す
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
