---
title: 架構
---

使用 [Flutter](https://flutter.dev) 去撰寫所有應用程式相關邏輯，他提供很多素材去做學習，包括各種應用程式的完成品，如 [Gallery](https://github.com/flutter/gallery) 和其他[小範例](https://github.com/flutter/samples)。

Flutter 透過 [Skia](https://skia.org) 來做繪圖工具，在所有平台（macOS、Linux、Windows、Website、iOS APP、Android APP）中都利用該套件直接和底層 OS 接觸，減少和各平台的接口接觸，進而達到能在眾平台中統一介面。

當然，在一些特殊情境上，仍需要單獨處理平台的設定。例如，iOS 的通知，便需要在 XCode 和 [AppStoreConnect](http://appstoreconnect.apple.com) 中設定。但整體的商務邏輯和應用程式設計都可以直接透過 Flutter 設定。

Flutter 是一個框架，撰寫其框架的語言是 [Dart](https://dart.dev)，其風格類似於很多物件導向的語言。個人是覺得和其他語言沒什麼差別，主要是覺得他和 IDE 融合得很好，撰寫起來很方便，相關文件也很充足。這有幾個詳細說明的文章，無聊可以讀讀，[10-good-reasons-why-you-should-learn-dart](https://medium.com/hackernoon/10-good-reasons-why-you-should-learn-dart-4b257708a332)、[why-flutter-uses-dart](https://hackernoon.com/why-flutter-uses-dart-dd635a054ebf)。

如果想馬上來試試，可以玩玩看他們的線上 [compiler](https://dartpad.dev/?null_safety=true)。

## POS 系統在 Flutter 之上的架構

主要架構，最後更新於 2021-07-30

```
.
├── assets/         - 各種圖片，未來可能會放字體
├── lang/           - 應用程式內的文字，和各語言的翻譯（實質僅有 zh-TW）
├── lib/            - 主要邏輯
│   ├── builder/    - 用來把 lang 中的 YAML 檔轉成單一的 JSON 檔
│   ├── components/ - 各種 UI 輔助元件
│   ├── constants/  - 各種定死的標準，例如外觀顏色，常用圖標
│   ├── helpers/    - 各地方常用函示，例如 Log
│   ├── models/     - 物件，例如產品、成份等等。會在這裡和 Services 接觸而非 UI 裡面
│   ├── providers/  - 使用者可以調整的設定，例如主題、語言
│   ├── services/   - 和應用程式外部溝通的工具，例如 DB
│   ├── ui/         - 應用程式主要外觀設計
│   ├── main.dart   - 綁定 Providers 和 Models，處理 Firebase 的初始化
│   └── app.dart    - 初始化 Service 和 Providers
└── test/           - 單元和元件測試，架構和 lib/ 一樣
```

### Builder

最後更新於 2021-07-30

```
lib/
└── builder/             - 用來把 lang 中的 YAML 檔轉成單一的 JSON 檔
    ├── language_builder - 把 YAML 檔轉成 JSON 檔
    └── language_saver   - 把 JSON 檔存起來
```

### Components

最後更新於 2021-07-30

```
components/                     - 各種 UI 輔助元件
├── dialog/                     - 對話框
│    ├── confirm_dialog         - 確認通知
│    ├── delete_dialog          - 刪除通知
│    └── single_text_dialog     - 可輸入文字的對話框
├── mixin/                      - 輔助型元件
│    └── item_modal             - 編輯物件（如產品、成分）用的模組
├── scaffold/                   - 框架類元件
│    ├── fade_in_title_scaffold - 往下滑會讓標題消失的框架
│    ├── reorderable_scaffold   - 可以重新排列物件的框架
│    └── search_dialog          - 提供搜尋的框架
├── style/                      - 不會過 test 的元件
│    └── ...                    - 小東西，不列舉
├── bottom_sheet_actions        - 下方選單工具
├── meta_block                  - 多文字間隔符號
├── radio_text                  - 僅有文字的選項按鈕
├── search_bar                  - 搜尋框
├── slidable_item_list          - 可以讓子元件滑動的列表
└── tutorial                    - 提供教學的介面
```

### Constants

最後更新於 2021-07-30

```
constants/     - 各種定死的標準，例如外觀顏色，常用圖標
├── app_themes - 外觀顏色
├── constant   - 數字類的標準，如 padding、margin 的大小
└── icons      - 常用圖標
```

### Helpers

最後更新於 2021-07-30

```
helpers/      - 各地方常用函示，例如 Log
├── logger    - 輸出，包括輸出到 Firebase Analytics
├── util      - 雜項
└── validator - 驗證輸入的工具，例如文字必須為數字且必須大於一
```

### Models

最後更新於 2021-07-30

```
models/                     - 物件，例如產品、成份等等。會在這裡和 Services 接觸而非 UI 裡面
├── menu/                   - 菜單
│    ├── catalog            - 產品種類
│    ├── product_ingredient - 產品得成分
│    ├── product_quantity   - 產品的份量
│    └── product            - 產品
├── objects/                - 用來做 I/O 的物件
│    ├── cashier_object     - 收銀機的物件
│    ├── menu_object        - 菜單的物件
│    ├── order_object       - 訂單的物件
│    └── stock_object       - 庫存的物件
├── order/                  - 訂單
│    ├── order_ingredient   - 訂單的成份設定
│    └── order_product      - 訂單的產品設定
├── repository/             - 物件庫
│    ├── cart               - 訂單的物件庫，購物車
│    ├── cashier            - 收銀機的物件庫
│    ├── menu               - 菜單的物件庫
│    ├── quantities         - 份量的物件庫
│    ├── replenisher        - 補貨的物件庫
│    ├── seller             - 點單的物件庫，賣家，用來處理把訂單丟進 DB
│    └── stock              - 庫存的物件庫，雖然 inventory 這名稱比較適合，但為時已晚
├── stock/                  - 庫存
│    ├── ingredient         - 庫存的成份
│    ├── quantity           - 庫存的成分數量
│    └── replenishment      - 庫存的補貨
├── model_object            - object 的基本物件
├── model                   - model 的基本物件
└── repository              - repository 的基本物件
```

### Providers

最後更新於 2021-07-30

```
providers/            - 使用者可以調整的設定，例如主題、語言
├── currency_provider - 幣種，目前尚無使用，僅是預先做好，未來有需要可以開
├── language_provider - 語言
└── theme_provider    - 主題，目前僅有日光和暗色
```

### Services

最後更新於 2021-07-30

```
services/       - 和應用程式外部溝通的工具，例如 DB
├── migrations/ - database 不同版本時整合的紀錄
│    └── ...    - 各版本，未來也許會開一個頁面來說明？
├── cache       - 記錄使用者的設定和行為，例如是否看過 tutorial
├── database    - 紀錄點單等多筆的資料，Sqlite
└── storage     - 紀錄菜單和庫存等高變種的資料，NoSQL
```

### UI

基本架構為

```
feature/             - 特定功能
├── ...              - 功能下的子功能，若有會列出來
├── widgets          - 功能的輔助物件，不會在下表中列出來
└── feature_screen   - 功能的架構，不會在下表中列出來
└── feature_tutorial - 功能的教學，不會在下表中列出來
```

最後更新於 2021-07-30

```
ui/                    - 應用程式主要外觀設計
├── analysis/          - 分析點單
├── cashier/           - 收銀機
│    └── changer       - 換錢
├── home/              - 主頁
├── menu/              - 菜單
│    ├── catalog/      - 產品種類
│    └── product/      - 產品
├── order/             - 點單
│    ├── cart          - 購物車
│    └── cashier       - 結帳
├── setting/           - 設定
├── splash/            - 過場畫面，目前僅有開始時的過場畫面
└── stock/             - 庫存
     ├── quantity      - 成分數量
     └── replenishment - 補貨
```
