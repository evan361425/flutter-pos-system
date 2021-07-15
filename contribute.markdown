# 幫助 POS 系統

大家好！很開心有人想幫助 POS 系統，你的幫忙會讓這應用程式更好的！

本 POS 系統是一個開源的專案，並且由各方貢獻者一點一點把這產品建構起來。我們很高興有你的加入。無論你有多少時間和能力，你的付出我們都給予高度感謝。有很多種貢獻方式：

- 改善文件
- 回報程式害蟲
- 提出新功能或改善功能
- 設計外觀和整體架構
- 透過留言回應其他人的 issue
- 直接撰寫程式碼改善 POS 系統

遵守以下的準則，會加速整個系統開發的流程和進度。當然，我們也會提供相應的幫助，如：確認 issue 的定位、確認改善和幫助完成最終的 PR。

> 什麼是 [PR](https://gitbook.tw/chapters/github/pull-request.html)？

## 你需要任何幫助嗎？

## 如何回報程式害蟲

哇哩咧，被你找到 bug 了！請先看看你找到的害蟲是否[已經被回報了]({{ site.github.repository_url }}/labels/bug)。如果還沒有類似的害蟲，請[提交相關的 issue]({{ site.github.repository_url }}/issues/new?assignees=&labels=&template=bug_report.md&title=)。

這裡有幾個小技巧幫助你撰寫出一個好的害蟲通報文件：

- 說明明確的問題（例如，「出現錯誤」和「製作產品菜單時，若設定相同名字仍可以建立成功」）。
- 你怎麼產生這個問題的？
- 你預期應該要有什麼結果卻得到什麼結果。
- 確保你已經使用最新版本的應用程式。
- 說明你使用的手機型號和版本。
- 一隻害蟲一個 issue，若你發現兩個問題，請發兩個 issue。
- 就算你不知道該怎麼解決這些問題，幫助其他人重現問題可以加速問題的發現。
- 若你發現任何安全性的問題，請不要發 issue，相對的，請發信到 evanlu361425@gmail.com，會有人來專門處理。

## 提出新功能或改善功能

如果你發現任何希望要有的功能而本 POS 系統並沒有，那你可能並不孤單，很多人都想要有該功能。很多現有的功能都是透過使用者的回饋才慢慢增加的。

我們非常歡迎提出新功能，但是思考一下是否該功能和 POS 系統是有關係的，你可以提出想法大家一起來討論看看本功能實作的價值。請提出足夠的細節和可行性，並且說明一下該功能試圖解決的問題。

再次感謝你提出想法幫助本產品更好，開始[建立相關的 issue]({{ site.github.repository_url }}/issues/new?assignees=&labels=&template=feature_report.md&title=) 吧！

## 你的第一個貢獻

We'd love for you to contribute to the project. Unsure where to begin contributing to the Cayman theme? You can start by looking through these "good first issue" and "help wanted" issues:

Good first issues - issues which should only require a few lines of code and a test or two
Help wanted issues - issues which may be a bit more involved, but are specifically seeking community contributions
p.s. Feel free to ask for help; everyone is a beginner at first 😺

## 怎麼提出改善

Here's a few general guidelines for proposing changes:

If you are making visual changes, include a screenshot of what the affected element looks like, both before and after.
Follow the Jekyll style guide.
If you are changing any user-facing functionality, please be sure to update the documentation
Each pull request should implement one feature or bug fix. If you want to add or fix more than one thing, submit more than one pull request
Do not commit changes to files that are irrelevant to your feature or bug fix
Don't bump the version number in your pull request (it will be bumped prior to release)
Write a good commit message
At a high level, the process for proposing changes is:

Fork and clone the project
Configure and install the dependencies: script/bootstrap
Make sure the tests pass on your machine: script/cibuild
Create a new branch: git checkout -b my-branch-name
Make your change, add tests, and make sure the tests still pass
Push to your fork and submit a pull request
Pat your self on the back and wait for your pull request to be reviewed and merged
Interesting in submitting your first Pull Request? It's easy! You can learn how from this free series How to Contribute to an Open Source Project on GitHub
