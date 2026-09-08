---
name: ccc-lns-condensed-slide-deck
description: "Local project skill for the CCC-LNS site (C:\\Users\\ccchiang\\Projects\\CCC-LNS). Use when a finished, self-contained condensed HTML slide deck needs to be added to a chapter of the site as \"精簡版投影片\" and linked from the site's index.html."
scope: project
project_root: "C:\\Users\\ccchiang\\Projects\\CCC-LNS"
---

# CCC-LNS 精簡版投影片上架技能

這是一個**專案層級**的本地技能，只適用於 `C:\Users\ccchiang\Projects\CCC-LNS` 這個網站專案（GitHub Pages，remote 為 `https://github.com/ndhuccc/CCC-LNS.git`）。用途：把一份已經做好的「精簡版」單檔 HTML 投影片（例如某堂課整週內容濃縮成一份可捲動瀏覽的投影片，通常是像 `idl115-w1-dl-intro-history.html` 這種檔案）放進正確的章節子目錄，並在網站首頁 `index.html` 加上「精簡版投影片」連結。

不處理：逐字稿產生、逐頁投影片產生、AI 生圖（那些是其他技能的工作）。這個技能只負責「上架」最後完成的單一 HTML 檔案。

## 觸發時機

使用者說類似「把這份投影片放到 CCC-LNS 的某一章」「幫我把精簡版投影片加到網站」「複製投影片到 CCC-LNS 並更新 index」時使用。

## 先決條件

- 已透過裝置橋接（`mcp__remote-devices__*`）連接到 `C:\Users\ccchiang\Projects\CCC-LNS`（`get_device_info` 的 `connectedFolders` 應包含這個路徑；若沒有，先請使用者連接這個資料夾）。
- 有一份已經做完、可獨立開啟的單檔 HTML 投影片（本機容器路徑或使用者上傳的檔案）。

## Step 0 — 一定要先問使用者要放在第幾章

**這是這個技能最重要的規則，不可省略、不可自己猜。** 執行任何複製或修改動作之前，必須：

1. 判斷要放進哪個課程資料夾：`IDL_115`（深度學習導論）還是 `PR_115`（樣式識別 Pattern Recognition）。若投影片檔名有明顯前綴（如 `idl115-...` → `IDL_115`；`pr115-...` 或 `pr-...` → `PR_115`）可以先預判，但仍要在問題中列出來讓使用者確認，不要直接假設。
2. 用 `device_list_dir` 列出該課程資料夾底下實際存在的章節子目錄（例如 `Ch01-introduction-history`、`Ch02-perceptron-mlp` ...），然後用 `AskUserQuestion` 把這些章節列成選項，讓使用者選擇要放進第幾章。**選項必須來自實際存在的目錄清單，不要用猜的章節編號或名稱。**
3. 使用者選定章節後才能繼續往下走。

## 工作流程

### 1. 確認來源檔案

確認要上架的 HTML 投影片檔案（路徑或已上傳的檔案），並用 `Read` 或直接檢視內容確認它是一份完整、可獨立開啟的單檔投影片（自包含 CSS/JS/圖片 base64），不是半成品。

### 2. Step 0 的課程與章節選擇（見上）

### 3. 檢查目標章節目錄，避免覆蓋

用 `device_list_dir` 列出目標章節資料夾（例如 `IDL_115/Ch01-introduction-history/`）目前有哪些檔案。**規則：絕不覆蓋任何既有檔案。**

- 若使用者沒有特別指定檔名，直接沿用來源檔案的原始檔名。
- 若目標資料夾已經有同名檔案，**不要覆蓋**——回報給使用者，請他們決定新檔名（例如加上日期或版本後綴），確認後才繼續。

### 4. 複製檔案到裝置

流程（雲端容器 → 使用者電腦）：先確認檔案在容器的 `/mnt/user-data/outputs/` 底下，用 `SendUserFile` 取得 `file_uuid`，再用 `mcp__remote-devices__device_commit_files` 把它寫入 `C:\Users\ccchiang\Projects\CCC-LNS\<課程>\<章節>\<檔名>.html`。

### 5. 更新根目錄 `index.html`

根目錄 `index.html`（`C:\Users\ccchiang\Projects\CCC-LNS\index.html`）裡每個章節是一張 `chapter-card`，內含一個 `chapter-actions` 區塊，長相通常像：

```html
<div class="chapter-actions">
  <a class="action action-notes" href="<課程>/<章節>/index.html">
    <span class="action-label">講義</span><span class="slide-count">Chapter page</span>
  </a>
</div>
```

網站既有 CSS 已經定義了 `.action-slide`（橘色系，代表投影片類型的連結，帶有 ↗ 符號），這正是「精簡版投影片」該用的樣式，不要另外發明新的 class。

**插入規則**：

1. 用該章節「講義」連結的 `href="<課程>/<章節>/index.html"` 當作定位錨點，確認在檔案中只出現一次（`grep -c` 或用 Python 的 `content.count(old)` 驗證，一定要 `== 1` 才進行取代，避免改錯章節）。
2. 若該章節的 `chapter-actions` 裡**還沒有** `action-slide` 連結：在「講義」連結後面插入一個新的：
   ```html
   <a class="action action-slide" href="<課程>/<章節>/<檔名>.html"><span class="action-label">精簡版投影片</span></a>
   ```
3. 若該章節**已經有** `action-slide` 連結（代表之前上架過一次）：只更新它的 `href`，不要重複插入第二個連結——先問使用者是否要覆蓋既有連結（因為這代表可能已經有一份精簡版投影片存在，要確認是否為改版取代）。
4. 修改前後都用 `device_bash` 的 `sed -n` 或 Python 讀取修改處附近幾行，肉眼確認插入位置與內容正確。

實際操作用 `device_bash` 執行一段 Python（`content.replace(old, new)`，並在替換前 `assert content.count(old) == 1`），而不是用 `sed -i` 直接改，因為連結字串含有特殊字元，Python 字串比對比較不會出錯。

### 6. Git 操作（僅提交這次真正動到的檔案）

**規則：只 `git add` 這次任務實際新增/修改的兩個檔案（新的投影片 HTML + 根目錄 `index.html`），絕對不要用 `git add -A` 或 `git add .`。** 這個 repo 過去曾經有大量既存但未提交的改動（例如整檔案的換行符差異），跟這次任務無關，不應該被一起提交進去。

**已知的鎖檔案問題（重要，務必照做）**：這個裝置橋接的 `device_bash` 在使用者機器上的沙盒環境裡，**沒有刪除檔案的權限**（`rm`/`unlink` 會回傳 `Operation not permitted`）。Git 在每次操作後會建立 `.git/index.lock`（有時還有 `.git/HEAD.lock`、`.git/objects/maintenance.lock`）並在結束時嘗試刪除它——但因為沒有刪除權限，這些鎖檔案會殘留下來，導致下一個 git 指令失敗並回報 `fatal: Unable to create '.../index.lock': File exists.`。

**解法**：`mv`（重新命名）不需要刪除權限，可以正常運作。所以每次要跑會寫入的 git 指令（`add`、`commit`、`push`）之前，先把可能殘留的鎖檔案「搬走」（改名），例如：

```bash
cd "$HOME/mnt/CCC-LNS" && \
for f in .git/index.lock .git/HEAD.lock .git/objects/maintenance.lock; do \
  [ -f "$f" ] && mv "$f" "$f.bak.$(date +%s)"; \
done
```

搬移完鎖檔案之後，緊接著執行實際的 git 指令（`git add`、`git commit`、`git push`）。指令執行時仍可能出現一堆 `warning: unable to unlink '.git/objects/xx/tmp_obj_...'` 或類似警告——這些只是暫存物件清不掉的無害警告，不影響 commit/push 是否成功，可以忽略，但仍要檢查指令的最終結果（exit code、`git status`）確認真的成功。

完整順序：

```bash
cd "$HOME/mnt/CCC-LNS"

# 1) 清鎖檔
for f in .git/index.lock .git/HEAD.lock .git/objects/maintenance.lock; do
  [ -f "$f" ] && mv "$f" "$f.bak.$(date +%s)"
done

# 2) 只加這兩個檔案
git add "<課程>/<章節>/<檔名>.html" "index.html"

# 3) 再清一次鎖檔（add 可能又留下新的）
for f in .git/index.lock .git/HEAD.lock .git/objects/maintenance.lock; do
  [ -f "$f" ] && mv "$f" "$f.bak.$(date +%s)"
done

# 4) commit
git commit -m "Add condensed slide deck for <章節標題> as 精簡版投影片"

# 5) 再清一次鎖檔
for f in .git/index.lock .git/HEAD.lock .git/objects/maintenance.lock; do
  [ -f "$f" ] && mv "$f" "$f.bak.$(date +%s)"
done

# 6) push
git push origin main
```

### 7. Push 可能會失敗——這是預期中的限制，不要嘗試繞過

這個裝置沙盒環境看不到使用者 Windows 上儲存的 GitHub 憑證（Credential Manager），所以 `git push` 常會失敗，錯誤訊息類似：

```
fatal: could not read Username for 'https://github.com': No such device or address
```

**遇到這個錯誤時**：不要嘗試輸入帳號密碼、不要嘗試建立 credential helper、不要嘗試繞過認證。直接告訴使用者 commit 已經在本機完成，請他們自己在自己的電腦上（GitHub Desktop、VS Code、或平常用的終端機）執行 `git push origin main`，因為那邊才有已快取好的憑證。

若 push 剛好成功（表示這台裝置環境當下有可用的憑證快取），就正常回報推送成功與 commit hash。

### 8. 回報結果

跟使用者說清楚：
- 投影片複製到了哪個完整路徑
- `index.html` 裡加了什麼連結、指向哪個章節
- commit hash 是什麼
- push 是成功了、還是需要使用者自己補推

## 這個技能的假設（如果網站結構改變，這裡要跟著更新）

- 每個章節資料夾底下有 `index.html`（講義）、`slides/`（逐頁投影片）、`assets/`（圖片等），這個技能新增的精簡版投影片直接放在章節資料夾**根目錄**下（不進 `slides/` 子目錄），因為它是「整章濃縮成一份」的性質，跟 `slides/` 底下的逐頁教學投影片是不同東西。
- 根目錄 `index.html` 每個章節用 `chapter-card` → `chapter-actions` 的結構，且已經定義好 `.action-notes`（講義）與 `.action-slide`（投影片，橘色系 + ↗ 符號）兩種既有樣式可以直接複用。
- Repo 只有一個遠端 `origin`，分支固定用 `main`。
