#!/usr/bin/env bash
# 用途：在根目錄 index.html 對應課程區塊裡，加入一張章節連結卡片。
# 用法：scripts/add_link.sh <課程資料夾> <章節資料夾> <badge文字> <標題文字>
# 範例：scripts/add_link.sh PR_115 Ch17-new-chapter Ch17 "新章節標題"
set -euo pipefail

COURSE="${1:?用法：scripts/add_link.sh <課程資料夾> <章節資料夾> <badge> <標題>}"
CHAPTER="${2:?用法：scripts/add_link.sh <課程資料夾> <章節資料夾> <badge> <標題>}"
BADGE="${3:?用法：scripts/add_link.sh <課程資料夾> <章節資料夾> <badge> <標題>}"
TITLE="${4:?用法：scripts/add_link.sh <課程資料夾> <章節資料夾> <badge> <標題>}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INDEX="$REPO_ROOT/index.html"

if [ ! -f "$REPO_ROOT/$COURSE/$CHAPTER/index.html" ]; then
  echo "警告：$COURSE/$CHAPTER/index.html 還不存在——建議先跑 scripts/sync_chapter.sh 把檔案放進去" >&2
fi

if command -v py >/dev/null 2>&1; then
  PY=(py -3)
elif command -v python3 >/dev/null 2>&1; then
  PY=(python3)
else
  PY=(python)
fi

PYTHONIOENCODING=utf-8 "${PY[@]}" - "$INDEX" "$COURSE" "$CHAPTER" "$BADGE" "$TITLE" <<'PYEOF'
import sys
path, course, chapter, badge, title = sys.argv[1:6]
marker = f"<!-- COURSE:{course} -->"

with open(path, encoding="utf-8") as f:
    content = f.read()

if marker not in content:
    sys.exit(f"錯誤：找不到課程標記 {marker}，先用 scripts/new_course.sh 建立課程區塊")

idx = content.index(marker)
close_pattern = "\n    </div>\n  </section>"
try:
    close_idx = content.index(close_pattern, idx)
except ValueError:
    sys.exit("錯誤：在這個課程區塊裡找不到預期的收尾格式（4 空白縮排的 </div> + 2 空白縮排的 </section>）——"
              "可能根目錄 index.html 的格式被手動改過，改用手動編輯比較安全")

link = f'      <a class="card" href="{course}/{chapter}/index.html"><span class="badge">{badge}</span><div class="title">{title}</div></a>'
content = content[:close_idx] + "\n" + link + content[close_idx:]

with open(path, "w", encoding="utf-8") as f:
    f.write(content)
PYEOF

echo "已加入連結：$COURSE/$CHAPTER -> badge=$BADGE, title=$TITLE"
