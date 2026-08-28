#!/usr/bin/env bash
# 用途：一個指令完成 commit、push、等待 GitHub Pages 重新部署、驗證沒有 404。
# 用法：scripts/publish.sh "commit 訊息"
set -euo pipefail

MSG="${1:?用法：scripts/publish.sh \"commit 訊息\"}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

git add -A

if git diff --cached --quiet; then
  echo "沒有變更可以 commit"
  exit 0
fi

echo "即將 commit 的變更："
git status --short
echo ""

git commit -m "$MSG"
git push origin main

echo ""
echo "等待 GitHub Pages 重新部署..."
for i in $(seq 1 20); do
  status=$(gh api repos/ndhuccc/CCC-LNS/pages/builds/latest --jq '.status' 2>/dev/null || echo "unknown")
  echo "  [$i] $status"
  if [ "$status" = "built" ]; then
    break
  fi
  if [ "$status" = "errored" ]; then
    echo "部署失敗，去 https://github.com/ndhuccc/CCC-LNS/settings/pages 查看錯誤訊息" >&2
    exit 1
  fi
  sleep 10
done

echo ""
"$REPO_ROOT/scripts/check_links.sh"
