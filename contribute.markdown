# 幫助 POS 系統

大家好！很開心有人想幫助 POS 系統，你的幫忙會讓這應用程式更好的！

本 POS 系統是一個開源的專案，並且由各方貢獻者一點一點把這產品建構起來。我們很高興有你的加入。無論你有多少時間和能力，你的付出我們都給予高度感謝。有很多種貢獻方式：

- 改善文件
- 回報程式害蟲
- 提出新功能或改善功能
- 透過留言回應其他人的 issue
- 直接撰寫程式碼改善 POS 系統

遵守以下的準則，會加速整個系統開發的流程和進度。當然，我們也會相應的提供幫助，確認 issue 的定位、確認改善和幫助你完成最終的 PR。

> 什麼是 [PR](https://gitbook.tw/chapters/github/pull-request.html)？

## 如何改善文件

## 如何回報程式害蟲

Think you found a bug? Please check the list of open issues to see if your bug has already been reported. If it hasn't please submit a new issue.

Here are a few tips for writing great bug reports:

Describe the specific problem (e.g., "widget doesn't turn clockwise" versus "getting an error")
Include the steps to reproduce the bug, what you expected to happen, and what happened instead
Check that you are using the latest version of the project and its dependencies
Include what version of the project your using, as well as any relevant dependencies
Only include one bug per issue. If you have discovered two bugs, please file two issues
Even if you don't know how to fix the bug, including a failing test may help others track it down
If you find a security vulnerability, do not open an issue. Please email security@github.com instead.

## 提出新功能或改善功能

If you find yourself wishing for a feature that doesn't exist in the Cayman theme, you are probably not alone. There are bound to be others out there with similar needs. Many of the features that the Cayman theme has today have been added because our users saw the need.

Feature requests are welcome. But take a moment to find out whether your idea fits with the scope and goals of the project. It's up to you to make a strong case to convince the project's developers of the merits of this feature. Please provide as much detail and context as possible, including describing the problem you're trying to solve.

Open an issue which describes the feature you would like to see, why you want it, how it should work, etc.

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
