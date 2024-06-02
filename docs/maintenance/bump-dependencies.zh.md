# 更新相依套件

分三種：

- dependencies，直接依賴的套件
- dev_dependencies，開發環境依賴的套件
- transitive，依賴套件的依賴套件

## 如何查找哪些套件需要更新

```bash
$ make outdated
Showing outdated packages.
[*] indicates versions that are not the latest available.

Package Name   Current   Upgradable  Resolvable  Latest

direct dependencies:
some_package   *3.2.0    *3.2.0      *3.2.0      4.0.0

dev_dependencies:
dev_package    *1.0.0    *1.0.0      *1.1.0      1.1.0
```

但要注意幾件事：

- `Current` 代表現在的版本
- `Upgradable` 代表依據[版本限制](https://dart.dev/tools/pub/dependencies#version-constraints)所能升級的最高版本
- `Resolvable` 代表在和現有環境（主要是 dart/flutter 版本）不衝突的情況下可升級的最高版本
- `Latest` 代表這個套件目前最新的版本

## 如何升級

根據上面得到想要升級的版本後

    flutter pub upgrade some_package

這樣的方式可以同時升級 Transitive 的套件。

## 更新之後

請記得重新跑一次 Mock，因為新版本的套件可能會有新的 API：

    make mock
