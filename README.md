# CCC-LNS

課程互動式自學講義的公開發布站，供學生瀏覽。

這個 repo 只放**建置完成的講義成品**（每章 `index.html` + `assets/`），不含原始教材、生成腳本、教授祕笈原始 Markdown 等——這些內容維護在另一個私有的生產線 repo（LNS）裡；本 repo 的內容是從那裡的成品目錄複製過來的靜態輸出，用於 GitHub Pages 發布。

## 更新方式

從私有生產線 repo 的 `PR_115/ChNN-xxx/` 複製最新的 `index.html` 與 `assets/` 到本 repo對應目錄，commit + push 即可，GitHub Pages 會自動重新部署。新增課程時，在根目錄開一個新的課程資料夾，並在根目錄 `index.html` 加入對應連結。
