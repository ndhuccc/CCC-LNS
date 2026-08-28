# CCC-LNS

課程互動式自學講義的**公開發布站**，給學生直接瀏覽用。線上網址：

```
https://ndhuccc.github.io/CCC-LNS/
```

---

## 1. 這個 repo 是什麼、不是什麼

**是**：GitHub Pages 的靜態發布站。每個課程一個頂層資料夾，每章一個子資料夾，子資料夾裡只有兩樣東西——`index.html`（唯一播放檔，單檔內嵌 CSS/JS/SVG）與 `assets/`（該章引用的圖片）。根目錄 `index.html` 是導覽首頁，列出「課程 → 章節」的連結。

**不是**：講義的生產線。原始教材、抽取的 Markdown、逐知識點的組裝腳本（`build_phaseA.py`）、圖解產生腳本（`gen_diagram*.py`）、demo 原始碼、教授祕笈的原始 Markdown（`guides/*.md`）、`agent.md` 交接文件、`__pycache__`——這些全部留在**私有的生產線 repo** 裡（例如 PR 115 對應的是 `LNS` repo），**絕對不進這個 repo**。原因：

1. **版權**：生產線 repo 通常會保存教科書 PDF 原檔，一旦這個 repo 公開，教科書內容也會跟著公開。
2. **保持乾淨**：學生只需要能開啟的 HTML，不需要看到組裝腳本或內部除錯紀錄。
3. **每章只需要 `index.html` + `assets/` 就能完整運作**——所有 demo 邏輯、圖解 SVG、教授祕笈逐字稿在生產階段就已經被組裝腳本內嵌進 `index.html` 了，執行期不會再去讀 `guides/`、`parts/`、`demos/` 這些資料夾。

## 2. 目錄結構

```
CCC-LNS/
├─ README.md                        ← 本文件
├─ index.html                       ← 根目錄導覽首頁（課程 → 章節連結）
├─ PR_115/                          ← 課程：Pattern Recognition（來源 repo：LNS）
│   └─ ChNN-xxx/
│       ├─ index.html
│       └─ assets/
└─ IDL_115/                         ← 課程：Elements of Deep Learning
    └─ ChNN-xxx/
        ├─ index.html
        └─ assets/
```

課程資料夾命名慣例：`<課程代號>_<學年度>`（如 `PR_115`、`IDL_115`）；章節資料夾沿用生產線 repo 的命名（如 `Ch01-introduction`）。

## 3. 常見操作

### 3.1 更新既有章節的內容

生產線那邊重新生成或修好某一章之後：

```bash
# 以 PR_115 Ch03 為例，SRC 是對應的私有生產線 repo
cp <SRC>/PR_115/Ch03-linear-classifiers/index.html   PR_115/Ch03-linear-classifiers/index.html
cp -r <SRC>/PR_115/Ch03-linear-classifiers/assets/.  PR_115/Ch03-linear-classifiers/assets/
git add PR_115/Ch03-linear-classifiers
git commit -m "Update PR_115 Ch03"
git push
```

不需要改根目錄 `index.html`（連結沒變）。push 後 GitHub Pages 會自動重新部署，通常 1–2 分鐘內生效。

### 3.2 幫既有課程新增一章

1. 從生產線 repo 複製整章，**只取 `index.html` 與 `assets/`**，其餘檔案（`agent.md`、`*.py`、`guides/*.md`、`parts/`、`demos/`、`diagrams/`、`__pycache__`、`PHASE_*_SPEC.md`……）一律不複製。
2. 貼到 `<課程資料夾>/<章節資料夾>/` 底下。
3. 打開根目錄 `index.html`，在對應課程的 `<div class="grid">` 區塊裡加一張 `<a class="card">` 連結卡片（照抄同一區塊裡其他章節的格式，換掉 `href`、`badge`、`title` 即可）。
4. `git add -A && git commit -m "..." && git push`。

### 3.3 新增一門全新課程

1. 在根目錄開一個新資料夾，命名為 `<課程代號>_<學年度>`。
2. 依 3.2 的方式放入各章的 `index.html` + `assets/`。
3. 在根目錄 `index.html` 的 `<main>` 裡新增一個 `<section class="course">` 區塊（照抄既有課程的區塊格式），標題放課程全名，底下列出各章連結卡片。
4. commit + push。

### 3.4 收工前務必檢查

**清乾淨檢查**：複製新章節進來後，`ls` 一下該章資料夾，確認裡面只有 `index.html` 和 `assets/` 兩樣東西，沒有夾帶 `.py`、`.md`（`README.md` 除外）、`__pycache__` 等生產線檔案。

**沒有 404 檢查**：push 後等 GitHub Pages 重新部署完成（可用 `gh api repos/ndhuccc/CCC-LNS/pages/builds/latest --jq '.status'` 查，變成 `built` 才算完成），再逐一檢查：

```bash
# 章節頁本身
curl -s -o /dev/null -w "%{http_code}\n" https://ndhuccc.github.io/CCC-LNS/<課程>/<章節>/index.html

# 該章引用的每張圖片（從 index.html 裡的 src="assets/..." 抓出來逐一檢查)
grep -oE 'src="assets/[^"]+"' <章節資料夾>/index.html
```

不要只信任「push 成功」就等於「網站正常」——曾經發生路徑大小寫或斜線打錯，push 沒報錯但學生點進去是 404。

## 4. 技術細節

- 沒有建置流程，GitHub Pages 直接從 `main` branch 根目錄原樣發布，push 即部署。
- 唯一需要連網的地方是 KaTeX 公式排版走 CDN（`cdn.jsdelivr.net`），其餘（圖片、demo、祕笈彈窗）都已內嵌在 `index.html` 裡，不需要額外資源。
- repo 是 Public（GitHub Pages 免費方案的必要條件），git 歷史從建立以來就只放這些成品檔案，從未進過任何教科書 PDF 或其他版權材料——新增內容時務必維持這個原則。
