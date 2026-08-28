#!/usr/bin/env bash
# 用途：在根目錄 index.html 新增一個空的課程區塊，並建立對應資料夾。
# 課程代號（如 PR 115）會自動從 <課程資料夾> 參數轉換顯示（底線變空白），標題只需放課程全名，不用重複寫代號。
# 用法：scripts/new_course.sh <課程資料夾> "<課程顯示標題>"
# 範例：scripts/new_course.sh NLP_115 "自然語言處理"
set -euo pipefail

COURSE="${1:?用法：scripts/new_course.sh <課程資料夾> \"<課程顯示標題>\"}"
TITLE="${2:?用法：scripts/new_course.sh <課程資料夾> \"<課程顯示標題>\"}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INDEX="$REPO_ROOT/index.html"
MARKER="<!-- COURSE:${COURSE} -->"

if grep -qF "$MARKER" "$INDEX"; then
  echo "錯誤：課程 $COURSE 已經存在（找到 $MARKER）" >&2
  exit 1
fi

mkdir -p "$REPO_ROOT/$COURSE"

if command -v py >/dev/null 2>&1; then
  PY=(py -3)
elif command -v python3 >/dev/null 2>&1; then
  PY=(python3)
else
  PY=(python)
fi

PYTHONIOENCODING=utf-8 "${PY[@]}" - "$INDEX" "$COURSE" "$TITLE" <<'PYEOF'
import sys
path, course, title = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path, encoding="utf-8") as f:
    content = f.read()

course_code = course.replace("_", " ")
block = (
    f'  <!-- COURSE:{course} -->\n'
    f'  <section class="course">\n'
    f'    <p class="course-code">{course_code}</p>\n'
    f'    <h2>{title}</h2>\n'
    f'    <div class="grid">\n'
    f'    </div>\n'
    f'  </section>\n'
)

marker_end = "</main>"
if marker_end not in content:
    sys.exit("錯誤：index.html 裡找不到 </main>，格式可能被改過")

content = content.replace(marker_end, block + marker_end, 1)
with open(path, "w", encoding="utf-8") as f:
    f.write(content)
PYEOF

echo "已建立課程區塊：$COURSE"
echo "資料夾已建立：$REPO_ROOT/$COURSE"
echo "接下來對每一章跑：scripts/sync_chapter.sh <來源> $COURSE/<章節> 然後 scripts/add_link.sh $COURSE <章節> <badge> <標題>"
