# 幫助 POS 系統

大家好！很開心有人想幫助 POS 系統，你的幫忙會讓這應用程式更好的！

本 POS 系統是一個開源的專案，並且由各方貢獻者一點一點把這產品建構起來。我們很高興有你的加入。無論你有多少時間和能力，你的付出我們都給予高度感謝。有很多種貢獻方式：

-   [改善文件](#改善文件)
-   [回報程式害蟲](#如何回報程式害蟲)
-   [提出新功能或改善功能](#提出新功能或改善功能)
-   [設計外觀和整體架構](#調整使用者介面)
-   透過留言回應其他人的 [issue]({{ site.github.repository_url }}/issues)
-   [直接撰寫程式碼改善 POS 系統](#怎麼提出程式碼上的異動)

遵守以下的準則，會加速整個系統開發的流程和進度。當然，我們也會提供相應的幫助，如：確認 issue 的定位、確認改善和幫助完成最終的 PR。

> 什麼是 [PR](https://gitbook.tw/chapters/github/pull-request.html)？

## 你需要任何幫助嗎？

若你有任何不知道怎麼處理的事情並未涵蓋進本文章，歡迎[來信](mailto:{{ site.social-network-links.email }})。或者你也可以直接[開一個 issue]({{ site.github.repository_url }}/issues/new) 來詢問，也許大家也有和你一樣的問題，我們一起來解決吧 😬。

## 改善文件

也許你在閱讀文件時，覺得語意怪怪的，或唸起來卡卡的，這代表這段落可能不是那麼完美。你可以先看看有沒有[類似的 issue]({{ site.github.repository_url }}/labels/document)。如果沒有，請[提交相關的 issue]({{ site.github.repository_url }}/issues/new?assignees=&labels=&template=document.md&title=)。

除此之外，在某些情況你可能也需要改善文件：

-   有錯字。
-   需要增加一些圖，來幫助理解。
-   補充文件或外站連結。
-   當你添加新的功能時，也請記得補上相關的文件。
-   當你想要找某些資訊時，卻沒辦法在第一個尋找的地方找到，那我們就應該在那個地方補上這類文件資訊。

在進行[程式異動](#怎麼提出程式碼上的異動)時要注意，在執行 `git checkout -b my-branch-name` 之前，應將主分支先切到 `gh-pages`，請執行 `git checkout gh-pages` 後在執行上述指令。並且，當你完成程式異動時，請記得在合併時同樣選擇 `gh-pages` 作為要求合併的分支。

## 如何回報程式害蟲

哇哩咧，被你找到 bug 了！請先看看你找到的害蟲是否[已經被回報了]({{ site.github.repository_url }}/labels/bug)。如果還沒有類似的害蟲，請[提交相關的 issue]({{ site.github.repository_url }}/issues/new?assignees=&labels=&template=bug_report.md&title=)。

這裡有幾個小技巧幫助你撰寫出一個好的害蟲通報文件：

-   說明明確的問題（例如，「出現錯誤」和「製作產品菜單時，若設定相同名字仍可以建立成功」）。
-   你怎麼產生這個問題的？
-   你預期應該要有什麼結果卻得到什麼結果。
-   確保你已經使用最新版本的應用程式。
-   說明你使用的手機型號和版本。
-   一隻害蟲一個 issue，若你發現兩個問題，請發兩個 issue。
-   就算你不知道該怎麼解決這些問題，幫助其他人重現問題可以加速問題的發現。
-   若你發現任何安全性的問題，請不要發 issue，相對的，請發信到 <evanlu361425@gmail.com>，會有人來專門處理。

## 提出新功能或改善功能

如果你發現任何希望要有的功能而本 POS 系統並沒有，那你可能並不孤單，很多人都想要有該功能。很多現有的功能都是透過使用者的回饋才慢慢增加的。

我們非常歡迎提出新功能，但是思考一下是否該功能和 POS 系統是有關係的，你可以提出想法大家一起來討論看看本功能實作的價值。請提出足夠的細節和可行性，並且說明一下該功能試圖解決的問題。

再次感謝你提出想法幫助本產品更好，開始[建立相關的 issue]({{ site.github.repository_url }}/issues/new?assignees=&labels=&template=feature_request.md&title=) 吧！

## 調整使用者介面

一個好的應用程式必須要有好的使用者介面，這包括應外觀設計和使用者操作順暢度。若你認為某區塊的顏色應該配上新的色彩，那我們就來試試看吧！請發出[相關的 issue]({{ site.github.repository_url }}/issues/new?assignees=&labels=&template=design.md&title=)。

這裡也提供幾點應注意的事項：

-   由於外觀和顏色是較為主觀的東西，每次調整，可能都會需要部分使用者的支持，例如按讚，才會考慮。
-   請提供前後變更的相關截圖，幫助 PR 流程的進展。
-   調整顏色應設定於定值，而非在特定元件上的變數。

## 第一次嘗試貢獻

我們很開心你願意貢獻本專案。若你不確定如何開始做任何幫忙，建議你可以看看關於[good first issue]({{ site.github.repository_url }}/issues?q=is%3Aissue+label%3A%22good+first+issue%22)，來看看什麼是好的 issue。除此之外[help wanted]({{ site.github.repository_url }}/issues?q=is%3Aissue+label%3A%22help+wanted%22)也是一個對於不知如何幫忙的人下手的好地方。

-   Good first issues - 應該只會包含少數幾行程式碼的修正和一組單元測試。
-   Help wanted issues - 可能會需要一些能力和經驗，但卻是一個特別需要大家幫忙的地方。

> 歡迎你透過 issue 或信箱提出任何問題，大家都是從初學者開始的唷 😺

## 怎麼提出程式碼上的異動

如要提出程式碼上的異動這裡有幾個建議方針去執行。

-   若你是製作外觀上的改變，請提供截圖說明改善前後的差異。
-   遵循 Flutter 程式碼[指南](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)。
-   若你是改動使用者會接觸到的功能，請記得更新相關的文件。
-   每個 PR 應該執行一個功能或處理一個害蟲。若你有多個功能或害蟲，請提交多個 PR。
-   不要改變和你要做的事情沒關的檔案。
-   [撰寫好的 commit 訊息](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)。

以下是執行程式碼改動的順序。

-   [Fork]({{ site.github.repository_url }}/fork) 並且複製本專案。
-   安裝必要檔案：`flutter pub get`。
-   安裝輔助工具：`flutter run build_runner build`。
-   確保你本地端可以正確執行：`flutter test`。
-   建立新的分支：`git checkout -b my-branch-name`
-   改動你要改的地方，並建立測試。
-   推到你 fork 的專案後提交 PR：`git push -u origin my-branch-name`
-   你可以休息一下了 😆，會有人來處理你的 PR 並把他合併進主要分支。

等不及想試試看提交你的第一個 PR 了嗎？你可以閱讀 GitHub 官方文件關於[如何貢獻 Open Source](https://egghead.io/series/how-to-contribute-to-an-open-source-project-on-github)。

## 如何準備本地端環境

詳見[本地端開發](../maintenance/development.md)。

## 如何進行測試

詳見[本地端開發](../maintenance/development.md)。

## Code of conduct

This project is governed by [the Contributor Covenant Code of Conduct](../CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## 其他有用資源

-   [Contributing to Open Source on GitHub](https://guides.github.com/activities/contributing-to-open-source/)
-   [Using Pull Requests](https://help.github.com/articles/using-pull-requests/)
-   [GitHub Help](https://help.github.com)
