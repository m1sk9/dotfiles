#!/usr/bin/env bash
# review-claude-cli の素材生成ヘルパー。
# secret(diff/全文) を扱うのは material/context モードだが、出力は stdout のみで
# ディスクには残さない（呼び出し側が claude -p に直結パイプする前提）。
#
# Usage:
#   review-prep.sh files     <scope> <base>   # 変更ファイル名一覧（空なら出力なし）
#   review-prep.sh material  <scope> <base>   # 変更後ファイル全文(行番号つき)+参考diff
#   review-prep.sh difflines <scope> <base>   # path<TAB>line（インラインコメント可能行）
#   review-prep.sh context   <pr>             # PR本文+リンクIssue（pr 空なら要件なし注記）
# scope: merge-base | staged | working
set -euo pipefail

# scope に応じた diff 本体を stdout に出す
emit_diff() {
  case "$1" in
    staged)     git diff --staged ;;
    working)    git diff ;;
    merge-base) git diff "$2...HEAD" ;;
    *) echo "review-prep: unknown scope: $1" >&2; return 2 ;;
  esac
}

# scope に応じた変更ファイル名（追加/変更/リネーム）を stdout に出す
emit_files() {
  case "$1" in
    staged)     git diff --staged --name-only --diff-filter=ACMR ;;
    working)    git diff --name-only --diff-filter=ACMR ;;
    merge-base) git diff "$2...HEAD" --name-only --diff-filter=ACMR ;;
    *) echo "review-prep: unknown scope: $1" >&2; return 2 ;;
  esac
}

mode="${1:-}"
case "$mode" in
  files)
    emit_files "${2:?scope}" "${3:-main}"
    ;;

  material)
    scope="${2:?scope}"; base="${3:-main}"
    files="$(emit_files "$scope" "$base")"
    if [ -z "$files" ]; then echo "__EMPTY__"; exit 0; fi
    echo "# レビュー対象: 変更ファイルの全文（変更後の状態・行番号つき）"
    while IFS= read -r f; do
      [ -f "$f" ] || continue
      printf '\n## FILE: %s\n```\n' "$f"
      cat -n "$f"
      printf '\n```\n'
    done <<< "$files"
    printf '\n---\n# 参考: 変更内容（unified diff）\n'
    printf 'NOTE: 以下は「どこが変わったか」の参考。メタ行(+++/---/@@/index/見出し)はコードではない。\n```diff\n'
    emit_diff "$scope" "$base"
    printf '\n```\n'
    ;;

  difflines)
    emit_diff "${2:?scope}" "${3:-main}" | awk '
      /^\+\+\+ b\// { f=substr($0,7); next }
      /^@@ /        { match($0, /\+[0-9]+/); ln=substr($0,RSTART+1,RLENGTH-1)+0; next }
      /^\+\+\+/ { next } /^---/ { next } /^\\/ { next }
      /^\+/ { print f"\t"ln; ln++; next } /^-/ { next } /^ / { ln++; next }
    '
    ;;

  context)
    pr="${2:-}"
    echo "# PR コンテキスト（満たすべき要件・仕様の参考。コードではなく「何を満たすべきか」の根拠）"
    if [ -z "$pr" ]; then
      echo
      echo "(PR 未指定。明示された要件が無い前提で spec lens を動かし、推測で要件をでっち上げない)"
      exit 0
    fi
    gh pr view "$pr" --json title,body --jq '"## PR: " + .title + "\n\n" + (.body // "(本文なし)")'
    refs="$( { gh pr view "$pr" --json closingIssuesReferences --jq '.closingIssuesReferences[].number' 2>/dev/null || true; \
               gh pr view "$pr" --json body --jq '.body // ""' 2>/dev/null | grep -oE '#[0-9]+' | tr -d '#' || true; } | sort -un || true )"
    for n in $refs; do
      echo
      gh issue view "$n" --json number,title,body \
        --jq '"## Linked Issue #" + (.number|tostring) + ": " + .title + "\n\n" + (.body // "(本文なし)")' 2>/dev/null || true
    done
    ;;

  *)
    echo "usage: review-prep.sh files|material|difflines|context <args...>" >&2
    exit 2
    ;;
esac
