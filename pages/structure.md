---
layout: page
title: 架構
---

使用 [Flutter](https://flutter.dev) 去撰寫所有應用程式相關邏輯，他提供很多素材去做學習，包括各種應用程式的完成品，如 [Gallery](https://github.com/flutter/gallery) 和其他[小範例](https://github.com/flutter/samples)。

Flutter 透過 [Skia](https://skia.org) 來做繪圖工具，在所有平台（macOS、Linux、Windows、Website、iOS APP、Android APP）中都利用該套件直接和底層 OS 接觸，減少和各平台的接口接觸，進而達到能在眾平台中統一介面。

當然，在一些特殊情境上，仍需要單獨處理平台的設定。例如，iOS 的通知，便需要在 XCode 和 [AppStoreConnect](http://appstoreconnect.apple.com) 中設定。但整體的商務邏輯和應用程式設計都可以直接透過 Flutter 設定。

Flutter 是一個框架，撰寫其框架的語言是 [Dart](https://dart.dev)，其風格類似於很多物件導向的語言。個人是覺得和其他語言沒什麼差別，主要是覺得他和 IDE 融合得很好，撰寫起來很方便，相關文件也很充足。這有幾個詳細說明 的文章，無聊可以讀讀，[10-good-reasons-why-you-should-learn-dart](https://medium.com/hackernoon/10-good-reasons-why-you-should-learn-dart-4b257708a332)、[why-flutter-uses-dart](https://hackernoon.com/why-flutter-uses-dart-dd635a054ebf)。

如果想馬上來試試，可以玩玩看他們的線上 [compiler](https://dartpad.dev/?null_safety=true)。

## POS 系統在 Flutter 之上的架構

主要架構

```
.
├── assets/         - 各種圖片，未來可能會放字體
├── lang/           - 應用程式內的文字，和各語言的翻譯（實質僅有 zh-TW）
├── lib/            - 主要邏輯/
│   ├── main.dart   - 綁定 Providers（含 Models） 和 Firebase 的初始化
│   ├── app.dart    - 初始化 Service 和 Providers
│   ├── builder/    - 用來把 lang 中的 YAML 檔轉成單一的 JSON 檔
│   ├── components/ - 各種 UI 輔助元件
│   ├── constants/  - 各種定死的標準，例如外觀顏色，常用圖標
│   ├── helpers/    - 各地方常用函示，例如 Log
│   ├── models/     - 物件，例如產品、成份等等。會在這裡和 Services 接觸而非 UI 裡面
│   ├── providers/  - 使用者可以調整的設定，例如主題、語言
│   ├── services/   - 和應用程式外部溝通的工具，例如 DB
│   └── ui/         - 應用程式主要外觀設計
└── test/           - 單元和元件測試，架構和 lib/ 一樣
```

### Builder

```
lib/
└── builder/    - 用來把 lang 中的 YAML 檔轉成單一的 JSON 檔/
    ├── language_builder - 把 YAML 檔轉成 JSON 檔
    └── language_saver   - 把 JSON 檔存起來
```

### Components

```
lib/
└── components/ - 各種 UI 輔助元件/
    ├── dialog/
    ├── mixin/
    ├── sacffold/
    ├── style/
    └── bottom_sheet_actions
```

### Constants

### Helpers

### Models

### Providers

### Services

### UI
