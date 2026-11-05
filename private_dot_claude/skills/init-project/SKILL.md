---
description: 新しいプロジェクトを preset に沿って初期化する（CI・リリース・Renovate などの設定一式を配置する）．「プロジェクトを初期化」「新しいリポジトリの CI をセットアップ」「init-project」と言われたとき，または新規リポジトリに babyrite / Pythia / chime と同じ構成を入れたいときに使う．
argument-hint: [rust]
---

カレントディレクトリのプロジェクトを，preset に沿って初期化する．preset ごとの手順とテンプレートは `references/` と `assets/` に分けてあり，このファイルは preset の選択だけを担う．

引数: $ARGUMENTS

## 1. preset を決める

- 引数が下表のいずれかに一致すれば，その preset を使う．
- 引数が無い，または一致しない場合は，`AskUserQuestion` で「どういうプロジェクトを初期化するか」を 1 問だけ聞く．選択肢は下表の preset と「その他（自由記述）」．
- 「その他」が選ばれた場合は preset が無いことを伝え，聞き取った内容をもとに通常の作業として進めてよいか確認する．勝手に preset を作らない．

| 引数 | 対象 | 手順 |
| --- | --- | --- |
| `rust` | Rust クレート．babyrite / Pythia / chime の CI・リリース構成 | `references/rust.md` |
| `zed` | Zed のプロジェクト設定（`.zed/settings.json`）．babyrite / Pythia の構成 | `references/zed.md` |

## 2. 手順を読んで実行する

選んだ preset の reference を読み，その手順に従う．テンプレートは `assets/<preset>/` にある．

## preset の追加

`references/<name>.md` と `assets/<name>/` を足し，上表に 1 行加える．chezmoi はドット始まりのソースを展開しないため，アセットは `ci.yaml` のようにドット無しのファイル名で置き，配置先との対応は reference に書くこと．`.tmpl` は使わない（`${{ secrets.* }}` が Go テンプレートとして解釈されるため）．
