# 部署流程

分為三個環境：

-   `internal`：內部測試用。
-   `beta`：對外的測試，同樣的檔案會推展到 `promote_to_production`。
-   `promote_to_production`：把 `beta` 的版本推到線上。

分別的部署方式如下：

-   `internal`
    1. 修改 [pubspec.yaml](https://github.com/evan361425/flutter-pos-system/blob/master/pubspec.yaml) 的版本資訊
    2. 在本地端打 tag，例如：`v1.0.0-rc1`
    3. 推到 GitHub 就會進行一系列的 CI/CD 流程。
-   `beta`
    1. 修改 [pubspec.yaml](https://github.com/evan361425/flutter-pos-system/blob/master/pubspec.yaml) 的版本資訊
    2. 在本地端打 tag，例如：`v1.0.0-beta`
    3. 推到 GitHub 就會進行一系列的 CI/CD 流程。
-   `promote_to_production`
    1. 把 GitHub 的 [draft release](https://github.com/evan361425/flutter-pos-system/releases) publish 出來。

確認都沒問題後，可以把舊的 tag 清掉：

```shell
git tag | grep 'v1.0.0-' | xargs git push --delete origin
git tag | grep 'v1.0.0-' | xargs git tag -d
```
