# 部署流程

分為三個環境（或者在 Fastlane 中稱為 `lane`）：

- `internal`：內部測試用。
- `beta`：對外的測試，同樣的檔案會推展到 `promote_to_production`。
- `promote_to_production`：把 `beta` 的版本推到線上。

分別的部署方式如下：

- `internal`：執行 `make bump-dev` 後，可能有兩種輸入：
  1. 如果要使用新的版本，則輸入該版號，例如 `1.2.3`；
  2. 如果要沿用版本號，但是要更新建置號，則輸入空白文字即可。
- `beta`：執行 `make bump`。
- `promote_to_production`：把 GitHub 的
  [draft release](https://github.com/evan361425/flutter-pos-system/releases) publish 出來。
