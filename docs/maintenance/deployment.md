# 部署流程

分為三個環境：

- `internal`：內部測試用。
- `beta`：對外的測試，同樣的檔案會推展到 `promote_to_production`。
- `promote_to_production`：把 `beta` 的版本推到線上。

分別的部署方式如下：

- `internal`
  1. 執行 `make bump` 後，根據想要更新的版本輸入。
- `beta`
  1. 執行 `make bump-beta`。
- `promote_to_production`
  1. 把 GitHub 的 [draft release](https://github.com/evan361425/flutter-pos-system/releases) publish 出來。
  2. 確認都沒問題後，可以把舊的 tag 清掉：`make clean-version`
