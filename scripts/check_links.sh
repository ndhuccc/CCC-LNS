#!/usr/bin/env bash
# 用途：檢查上線的網站有沒有 404——每個課程/章節頁本身，以及頁內引用的每張圖片。
# 用法：scripts/check_links.sh [課程資料夾]   （不給參數就檢查全部課程）
set -euo pipefail
shopt -s nullglob

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE_URL="https://ndhuccc.github.io/CCC-LNS"
SCOPE="${1:-}"
cd "$REPO_ROOT"

fail=0
checked=0

check() {
  local url="$1"
  checked=$((checked+1))
  local code
  code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  if [ "$code" != "200" ]; then
    echo "FAIL $code  $url"
    fail=$((fail+1))
  fi
}

check "$BASE_URL/"

for course_dir in */ ; do
  course="${course_dir%/}"
  [ "$course" = "scripts" ] && continue
  [ "$course" = ".git" ] && continue
  if [ -n "$SCOPE" ] && [ "$course" != "$SCOPE" ]; then
    continue
  fi
  for chapter_dir in "$course_dir"*/ ; do
    [ -f "${chapter_dir}index.html" ] || continue
    chapter="$(basename "$chapter_dir")"
    check "$BASE_URL/$course/$chapter/index.html"
    while IFS= read -r rel; do
      [ -z "$rel" ] && continue
      check "$BASE_URL/$course/$chapter/$rel"
    done < <(grep -oE 'src="assets/[^"]+"' "${chapter_dir}index.html" 2>/dev/null | sed -E 's/src="([^"]+)"/\1/')
  done
done

echo ""
echo "共檢查 $checked 個連結"
if [ "$fail" -eq 0 ]; then
  echo "全部通過，沒有 404"
else
  echo "共 $fail 個失敗"
  exit 1
fi
