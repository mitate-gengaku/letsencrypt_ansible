#!/bin/bash
set -euo pipefail

echo "===== 鎖国設定のリセットを開始します ====="

# [1] publicゾーンのtargetをdefaultに戻す(全遮断モードを先に解除しておく)
echo "[1/3] publicゾーンのtargetをdefaultに戻す..."
firewall-cmd --permanent --zone=public --set-target=default

# [2] rich-ruleを4つ削除
echo "[2/3] rich-ruleを削除中..."

firewall-cmd --permanent --zone=public --remove-rich-rule='rule family="ipv4" source ipset="jp" service name="http" accept' || true
firewall-cmd --permanent --zone=public --remove-rich-rule='rule family="ipv4" source ipset="jp" service name="https" accept' || true
firewall-cmd --permanent --zone=public --remove-rich-rule='rule family="ipv4" source ipset="jp" service name="ssh" accept' || true
firewall-cmd --permanent --zone=public --remove-rich-rule='rule family="ipv4" source ipset="jp" port port="8080" protocol="tcp" accept' || true

# [3] ipset(jp)を削除
echo "[3/3] ipset(jp)を削除中..."
if firewall-cmd --permanent --get-ipsets | grep -qw "jp"; then
    firewall-cmd --permanent --delete-ipset=jp
else
    echo "  -> ipset 'jp' は存在しません(スキップ)"
fi

# ===== 反映 =====
echo ""
echo "firewalldをリロード中..."
firewall-cmd --reload

# ===== ダウンロード済みファイルの後片付け(強制削除・非対話) =====
echo ""
echo "ダウンロード済みファイルを削除中..."
rm -f delegated-apnic-latest jp_ipv4.txt
echo "  -> 削除しました"

echo ""
echo "===== リセット完了 ====="
firewall-cmd --zone=public --list-all