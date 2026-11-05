# Rust preset

babyrite / Pythia / chime の CI・リリース構成を新しい Rust クレートに入れる．

出典: `m1sk9/babyrite@35a7c4c`（2026-11-05 時点の main）．chime は `-D warnings` と build matrix の違いだけ取り込み，他は babyrite / Pythia 側（ピンが新しく，4 ターゲット）を基準にした．上流が更新されたら，この SHA と `assets/rust/` を再同期すること．

## 1. 前提を確認する

- カレントに `Cargo.toml` が必要．無ければ `cargo init` はせず，「先に `cargo init` するか，クレートのあるディレクトリで実行してください」と伝えて終了する．
- git リポジトリであること．そうでなければ，その旨を伝えて続行してよいか確認する．
- ワークスペース（`[workspace]` のみで `[package]` が無い）の場合は，`name` が取れないのでユーザーに聞く．

## 2. 置換値を決める

| プレースホルダ | 値 |
| --- | --- |
| `__PROJECT_NAME__` | `Cargo.toml` の `package.name` |
| `__PROJECT_SLUG__` | 同じ名前を小文字にしたもの．cache の `prefix-key` と `ghcr.io/m1sk9/<slug>` に使う（リポジトリ名が大文字でもイメージ名は小文字でなければならない） |
| `__DOCKERFILE_PATH__` | `./Dockerfile` か `./docker/Dockerfile` の存在する方．両方無ければ手順 3 の分岐へ |
| `__VERSION__` | `Cargo.toml` の `package.version`（`version.workspace = true` なら workspace 側） |

## 3. 選択項目を決める

次の項目は，ユーザーが引数や会話で指定していなければ，既定値を採ったうえで報告に明記する．質問は Dockerfile が無い場合だけ行う．

- **Dockerfile が無い**: `release.yaml` の `build` / `merge` ジョブ（release-please 以降）を外すか聞く．外す場合は release-please ジョブだけ残す．
- **clippy を `-D warnings` にするか**（既定: しない）: chime の流儀．警告を CI で落としたい場合に `ci.yaml` の clippy 行へ `-- -D warnings` を足す．
- **build ターゲット**（既定: 4 ターゲット）: chime のように Linux だけで足りる場合は，matrix から macOS / Windows を削り，`use-cross` と `Install cross` ステップも外す．
- **coverage の toolchain**（既定: nightly）: `#[cfg_attr(coverage_nightly, coverage(off))]` を使わないなら stable で足りる．その場合は `ci.yaml` の coverage ジョブで `@nightly` を `@stable` に，`cargo +nightly llvm-cov` を `cargo llvm-cov` に，`components: llvm-tools-preview` を削除する．

## 4. ファイルを配置する

`assets/rust/` はドット始まりを避けてフラットに置いてある．次の対応で配置し，プレースホルダを置換する．

| アセット | 配置先 | 置換 |
| --- | --- | --- |
| `ci.yaml` | `.github/workflows/ci.yaml` | slug |
| `release.yaml` | `.github/workflows/release.yaml` | name / slug / Dockerfile |
| `renovate.json` | `.github/renovate.json` | なし |
| `rust-toolchain.toml` | `rust-toolchain.toml` | なし |
| `codecov.yml` | `codecov.yml` | なし |
| `release-please-config.json` | `release-please-config.json` | なし |
| `release-please-manifest.json` | `.release-please-manifest.json` | version |

- 配置先に同名ファイルが既にある場合は上書きしない．差分を示し，どうするか確認する．
- 置換後に `grep -rn '__[A-Z_]*__' .github rust-toolchain.toml codecov.yml release-please-config.json .release-please-manifest.json` で取り残しが無いことを確認する．
- `codecov.yml` の `ignore` は `src/main.rs` だけにしてある．ランタイムのグルーコード（ネットワーク接続を要するモジュールなど）がある場合は，ユーザーに追加するか聞く．
- `release-please-config.json` に `last-release-sha` は入れない（既存プロジェクトの移行時にだけ要る値）．

## 5. 完了後にユーザーが行う設定を伝える

リポジトリの中身からは分からず，漏れると CI / release が初回から落ちる項目なので，必ず出力する．

- Secrets（Settings → Secrets and variables → Actions）:
  - `CLIENT_ID` / `PRIVATE_KEY`: release-please が使う GitHub App（`actions/create-github-app-token`）の認証情報．
  - `CODECOV_TOKEN`: Codecov のアップロードトークン．`fail_ci_if_error: true` なので無いと CI が落ちる．
- Codecov 側でこのリポジトリを有効化する．
- Renovate 側で，このリポジトリを `m1sk9/renovate-config` の対象にする．

最後に，配置したファイル一覧・採った選択項目・上記チェックリストを報告する．commit / push はこの skill では行わない．
