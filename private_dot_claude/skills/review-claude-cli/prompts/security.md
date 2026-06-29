【このパスの担当観点 = security（これだけを見る・敵対的に考える）】
- 「この変更を攻撃者がどう悪用できるか」を能動的に探す。受け身で読まず、悪用シナリオを起点に考える。
- チェックリスト（該当が無ければスキップ）: 入力検証・injection（SQL / コマンド / Markdown / HTML 等）、認証認可の欠落・誤り、データ露出（内部 ID・storage key・secret）、SSRF・path traversal、リソース濫用・課金濫用（サイズ / 件数上限の欠如、presigned URL の悪用）、例外の握り潰しによる検証バイパス、idempotency の欠如による多重実行。
