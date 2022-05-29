# 如何部署

分為三個環境：

- `internal`：內部測試用。
- `beta`：對外的測試，同樣的檔案會推展到 `promote_to_production`。
- `promote_to_production`：把 `beta` 的版本推到線上。

分別的部署方式如下：

- `internal`：本地端打 tag（例如：`v1.0.0-rc1`），並推到 GitHub 就會進行一系列的 CI/CD 流程。
- `beta`：在 GitHub 上執行 `Add Artifacts for Release` 的 workflow，並輸入上相應版本，例如：`v1.0.0`。
- `promote_to_production`：把 GitHub 的 [draft release](https://github.com/evan361425/flutter-pos-system/releases) publish 即可。
