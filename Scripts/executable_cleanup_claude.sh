#!/usr/bin/env bash
# Claude Code 残留データ クリーンアップスクリプト
# 用途:
#   - 一部ディレクトリ: 3日以内のファイルは保持，それ以外を削除
#   - その他: ディレクトリ or ファイルをまるごと削除

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
DRY_RUN=false

# --dry-run オプションのサポート
for arg in "$@"; do
    if [[ "$arg" == "--dry-run" ]]; then
        DRY_RUN=true
    fi
done

if $DRY_RUN; then
    echo "=== DRY RUN モード（実際には削除しません）==="
fi

# ─────────────────────────────────────────────
# ユーティリティ関数
# ─────────────────────────────────────────────

log_info()  { echo -e "\033[36m[INFO]\033[0m $*"; }
log_ok()    { echo -e "\033[32m[ OK ]\033[0m $*"; }
log_skip()  { echo -e "\033[33m[SKIP]\033[0m $*"; }
log_error() { echo -e "\033[31m[ERR ]\033[0m $*"; }

# ─────────────────────────────────────────────
# 3日以上前のファイル/ディレクトリを削除する関数
# 引数: ディレクトリパス
# ─────────────────────────────────────────────
delete_old_entries() {
    local dir="$1"

    if [[ ! -d "$dir" ]]; then
        log_skip "$dir が存在しないためスキップ"
        return
    fi

    local deleted_count=0

    # find で3日以上前の直下エントリを取得（-maxdepth 1）
    # macOS 互換: -mtime +3 を使用（-newermt は GNU find 専用）
    while IFS= read -r -d '' entry; do
        if $DRY_RUN; then
            echo "  [DRY] 削除対象: $entry"
            ((deleted_count++))
        else
            if rm -rf "$entry"; then
                ((deleted_count++))
            else
                log_error "削除失敗: $entry"
            fi
        fi
    done < <(find "$dir" -maxdepth 1 -mindepth 1 -mtime +3 -print0 2>/dev/null)

    # 3日以内のエントリを数える（ログ用）
    local kept_count
    kept_count=$(find "$dir" -maxdepth 1 -mindepth 1 -not -mtime +3 2>/dev/null | wc -l | tr -d ' ')

    if $DRY_RUN; then
        log_ok "$dir: 削除対象 $deleted_count 件 / 保持 $kept_count 件（DRY RUN）"
    else
        log_ok "$dir: $deleted_count 件削除，$kept_count 件保持（3日以内）"
    fi
}

# ─────────────────────────────────────────────
# ディレクトリ/ファイルをまるごと削除する関数
# 引数: パス
# ─────────────────────────────────────────────
delete_all() {
    local target="$1"

    if [[ ! -e "$target" ]]; then
        log_skip "$target が存在しないためスキップ"
        return
    fi

    if $DRY_RUN; then
        echo "  [DRY] 全削除対象: $target"
        log_ok "$target: 全削除（DRY RUN）"
    else
        if rm -rf "$target"; then
            log_ok "$target: 全削除完了"
        else
            log_error "$target: 削除失敗"
        fi
    fi
}

# ─────────────────────────────────────────────
# メイン処理
# ─────────────────────────────────────────────

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║      Claude Code 残留データ クリーンアップ           ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "対象ディレクトリ: $CLAUDE_DIR"
echo ""

# ── 3日以内を保持 ──────────────────────────
log_info "【3日以上前のみ削除】"
delete_old_entries "$CLAUDE_DIR/backups"
delete_old_entries "$CLAUDE_DIR/file-history"
delete_old_entries "$CLAUDE_DIR/paste-cache"
delete_old_entries "$CLAUDE_DIR/plans"
delete_old_entries "$CLAUDE_DIR/session-env"
delete_old_entries "$CLAUDE_DIR/sessions"
delete_old_entries "$CLAUDE_DIR/shell-snapshots"
delete_old_entries "$CLAUDE_DIR/tasks"
delete_old_entries "$CLAUDE_DIR/todos"

echo ""

# ── 全削除 ─────────────────────────────────
log_info "【全削除】"
delete_all "$CLAUDE_DIR/debug"
delete_all "$CLAUDE_DIR/telemetry"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "クリーンアップ完了"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
