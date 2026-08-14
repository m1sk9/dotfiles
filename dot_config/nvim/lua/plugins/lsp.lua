-- 有効化する言語サーバーはここに列挙する．
-- 追加手順は Obsidian vault の Notes/Neovim 早見表.md に記載．
--
-- Why not tsgo: ネイティブバイナリで軽いが，LSP 機能自体が発展途上（README
-- 上も in progress）で，かつ @typescript/native-preview を devDependency に
-- 持つプロジェクトが実質存在しない．ts_ls は起動している typescript-language-
-- server 自体は Node.js だが，型検査は各プロジェクトの typescript パッケージを
-- 自動解決するため，バージョン・設定を完全にプロジェクト任せにできる
local servers = { "lua_ls", "rust_analyzer", "ts_ls" }

return {
  {
    -- Why not require("lspconfig").xxx.setup{}: この "framework" API は非推奨であり，
    -- 将来 require('lspconfig') 自体が削除される．このプラグインは lsp/ 配下の
    -- サーバー定義を提供するだけの存在として使い，有効化は vim.lsp.enable で行う
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            -- Why not nvim_get_runtime_file("", true) で runtimepath 全体を渡す:
            -- プラグインが増えるほど lua_ls の初期インデックスが重くなる．
            -- 補完したいのは Neovim 本体の API なのでそこだけに絞る
            workspace = {
              library = { vim.env.VIMRUNTIME .. "/lua" },
              checkThirdParty = false,
            },
            diagnostics = { globals = { "vim" } },
            telemetry = { enable = false },
          },
        },
      })

      -- Why not checkOnSave.command (旧設定名): rust-analyzer が新しくなり
      -- checkOnSave は常時 true 化された．check.command だけ指定すれば良い
      vim.lsp.config("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {
            check = { command = "clippy" },
          },
        },
      })

      vim.lsp.enable(servers)

      -- Zed の diagnostics.inline.enabled = true に相当する．
      -- Nvim 0.11 以降は virtual_text が既定で無効なので明示的に戻す
      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
        float = { border = "rounded" },
      })

      -- Why not グローバルにマッピング: LSP が付いていないバッファで gd などが
      -- 無反応になるのを避けるため，付いたバッファにだけ張る．
      -- grn / gra / grr / K などは Nvim 0.11 の標準マッピングなので再定義しない
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
          end
          map("gd", vim.lsp.buf.definition, "定義へ移動")
          map("gD", vim.lsp.buf.declaration, "宣言へ移動")
          map("<leader>cd", vim.diagnostic.open_float, "診断の詳細を見る")
          map("<leader>cf", function()
            vim.lsp.buf.format({ async = true })
          end, "フォーマット")

          -- Why not 全 filetype に広げる: rustfmt のように保存時整形が
          -- 前提のツールチェーンを持つのは今のところ Rust だけ
          if vim.bo[args.buf].filetype == "rust" then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = args.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = args.buf, async = false })
              end,
            })
          end
        end,
      })
    end,
  },

  {
    -- Why not version = "*" や main ブランチ: V2 が破壊的変更を含む開発中で，
    -- 別途 blink.lib の導入も必要になる．安定している V1 系に固定する
    "Saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
      keymap = { preset = "super-tab" },
      completion = { documentation = { auto_show = true } },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      -- Why not "rust": prebuilt バイナリが取得できない環境では Lua 実装に
      -- 落ちて動き続けてほしい（警告だけ出す）
      fuzzy = { implementation = "prefer_rust_with_warning" },
      signature = { enabled = true },
    },
  },
}
