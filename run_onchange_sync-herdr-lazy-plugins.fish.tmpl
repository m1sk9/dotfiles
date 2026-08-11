#!/usr/bin/env fish

# herdr-lazy が plugins.list (dot_config/herdr/plugins/config/herdr-lazy/) を
# source of truth として plugin の導入・pin を一括管理する．
# https://github.com/natori-hrj/herdr-lazy
#
# Why herdr plugin action invoke: herdr-lazy 本体のバイナリパスはインストール毎の
# hash を含み PATH にも乗らないため，直接実行より herdr 経由でのアクション実行が安定する．

if not command -q herdr
    echo "herdr command not found; skipping plugin sync"
    exit 0
end

if not herdr plugin list 2>/dev/null | grep -q "^- herdr-lazy "
    herdr plugin install natori-hrj/herdr-lazy --yes
end

herdr plugin action invoke herdr-lazy.sync
