# Zed preset

プロジェクトの `.zed/settings.json` を用意する．`rust` preset とは独立しており，CI などは触らない．

出典: `m1sk9/Pythia`（基準）と `m1sk9/babyrite`（biome の例）の `.zed/settings.json`，2026-11-05 時点．chime は `"!biome"` を使う別書式なので採らなかった．上流が変わったら `assets/zed/settings.json` と下記の biome ブロックを再同期すること．

## 1. 検出する

カレントディレクトリで次を調べる．

- `Cargo.toml` の有無 → あれば Rust ブロックを入れる．
- `biome.json` / `biome.jsonc` の有無（ルートと `docs/` を探す）→ あれば biome ブロックを入れる．

どちらも無い場合は，共通部分（`enable_language_server` と `format_on_save`）だけを書き，言語別のブロックは入れていないと報告する．言語を推測して足さない．

## 2. 生成する

`assets/zed/settings.json` が Rust 用の基準（`languages.Rust` と clippy の `--all-features`）になっている．

- Rust ブロックが不要（`Cargo.toml` が無い）場合は，`languages` の `Rust` と `lsp` の `rust-analyzer` を削る．
- biome がある場合は，基準に次を足す．`config_path` には見つけた設定ファイルの相対パスを入れる．ルート直下の設定であれば Zed が自動で見つけるので，`config_path` は書かない．

```jsonc
"languages": {
  "TypeScript": {
    "language_servers": ["biome", "vtsls"],
    "formatter": { "language_server": { "name": "biome" } },
  },
  "JavaScript": {
    "language_servers": ["biome", "vtsls"],
    "formatter": { "language_server": { "name": "biome" } },
  },
},
"lsp": {
  "biome": {
    "settings": {
      "config_path": "docs/biome.jsonc",
      "require_config_file": true,
    },
  },
},
```

Zed の設定は JSONC なので，コメントと末尾のカンマを許容する．上流に合わせ，末尾のカンマは残す．

## 3. 配置する

- 配置先は `.zed/settings.json`．`.zed/` が無ければ作る．
- 既に `.zed/settings.json` がある場合は上書きしない．差分を示し，どうするか（残す・置換・マージ）を確認する．
- 最後に，配置したファイルと，検出に基づいて入れた / 入れなかったブロックを報告する．commit / push はこの skill では行わない．
