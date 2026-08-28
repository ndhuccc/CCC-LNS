#!/usr/bin/env bash
# 用途：從生產線 repo 複製單一章節，只取 index.html + assets/，其餘生產檔案一律不帶。
# 用法：scripts/sync_chapter.sh <來源章節資料夾> <課程資料夾>/<章節資料夾>
# 範例：scripts/sync_chapter.sh ~/projects/LNS/PR_115/Ch03-linear-classifiers PR_115/Ch03-linear-classifiers
set -euo pipefail

SRC="${1:?用法：scripts/sync_chapter.sh <來源章節資料夾> <課程資料夾>/<章節資料夾>}"
DEST="${2:?用法：scripts/sync_chapter.sh <來源章節資料夾> <課程資料夾>/<章節資料夾>}"

if [ ! -f "$SRC/index.html" ]; then
  echo "錯誤：$SRC/index.html 不存在" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_PATH="$REPO_ROOT/$DEST"

mkdir -p "$DEST_PATH"
cp "$SRC/index.html" "$DEST_PATH/index.html"

if [ -d "$SRC/assets" ]; then
  mkdir -p "$DEST_PATH/assets"
  cp -r "$SRC/assets/." "$DEST_PATH/assets/"
fi

echo "已同步：$DEST_PATH"
echo "  index.html: $(du -h "$DEST_PATH/index.html" | cut -f1)"
[ -d "$DEST_PATH/assets" ] && echo "  assets/:    $(du -sh "$DEST_PATH/assets" | cut -f1)"
echo ""
echo "確認乾淨（下面應該只看到 index.html 與 assets/）："
ls "$DEST_PATH"
echo ""
echo "這是新章節的話，記得再跑：scripts/add_link.sh <課程資料夾> <章節資料夾> <badge> <標題>"
