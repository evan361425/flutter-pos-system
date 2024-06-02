# 架構

使用 [Flutter](https://flutter.dev) 去撰寫所有應用程式相關邏輯，
他提供很多素材去做學習，包括各種應用程式的完成品，
如 [Gallery](https://github.com/flutter/gallery) 和其他[小範例](https://github.com/flutter/samples)。

Flutter 透過 [Skia](https://skia.org) 來做繪圖工具，
在所有平台（macOS、Linux、Windows、Website、iOS APP、Android APP）中都利用該套件直接和底層 OS 接觸，
減少和各平台的接口接觸，進而達到能在眾平台中統一介面。

當然，在一些特殊情境上，仍需要單獨處理平台的設定。
例如，iOS 的通知，便需要在 XCode 和 [AppStoreConnect](http://appstoreconnect.apple.com) 中設定。
但整體的商務邏輯和應用程式設計都可以直接使用 Flutter 撰寫。

Flutter 是一個框架，撰寫其框架的語言是 [Dart](https://dart.dev)，
其風格類似於很多物件導向的語言。個人是覺得和其他語言沒什麼差別，主要是覺得他和 IDE 融合得很好，撰寫起來很方便，相關文件也很充足。
這有幾個詳細說明的文章，無聊可以讀讀，
[10-good-reasons-why-you-should-learn-dart](https://medium.com/hackernoon/10-good-reasons-why-you-should-learn-dart-4b257708a332)、
[why-flutter-uses-dart](https://hackernoon.com/why-flutter-uses-dart-dd635a054ebf)。

如果想馬上來試試，可以玩玩看他們的線上 [compiler](https://dartpad.dev/?null_safety=true)。

## POS 系統在 Flutter 之上的架構

這裡嘗試讓初入的人了解應用程式架構。

### 主要架構

```text
.
├── assets/             - 各種圖片，未來可能會放字體
├── lib/                - 主要邏輯
│   ├── components/     - 各種 UI 輔助元件
│   ├── constants/      - 各種定死的標準，例如外觀顏色，常用圖標
│   ├── helpers/        - 各地方常用函示，例如 Log
│   ├── l10n/           - 應用程式內的文字，和各語言的翻譯（實質僅有 zh-TW）
│   ├── models/         - 物件，例如產品、成份等等。會在這裡和 Services 接觸而非 UI 裡面
│   ├── services/       - 和應用程式外部溝通的工具，例如 DB
│   ├── settings/       - 使用者可以調整的設定，例如主題、語言和外觀
│   ├── ui/             - 應用程式主要外觀設計
│   ├── main.dart       - 處理 Services、Models 和 Firebase 的初始化
│   ├── my_app.dart     - 建置主體 APP 位置
│   ├── routes.dart     - 放置應用程式路徑位置
│   └── translator.dart - 讓應用程式不需要每次都呼叫很長的翻譯物件
└── test/               - 單元和元件測試，架構和 lib/ 一樣
```

### Components

```text
components/                     - 各種 UI 輔助元件
├── dialog/                     - 對話框
│    ├── confirm_dialog         - 確認通知
│    ├── delete_dialog          - 刪除通知
│    ├── single_text_dialog     - 可輸入文字的對話框
│    └── slider_text_dialog     - 滑動有數字屬性的對話框
├── mixin/                      - 輔助型元件
│    └── item_modal             - 編輯物件（如產品、成分）用的模組
├── models/                     - 和物件有關的 UI 元件
├── scaffold/                   - 框架類元件
│    ├── item_list_scaffold     - 目前僅有設定時會用到，未來可能會直接搬到 setting_screen
│    └── reorderable_scaffold   - 可以重新排列物件的框架
└── style/                      - 不會過 test 的元件
     └── ...                    - 小東西，不列舉
```

### Constants

```text
constants/     - 各種定死的標準，例如外觀顏色，常用圖標
├── app_themes - 外觀顏色
├── constant   - 數字類的標準，如 padding、margin 的大小
└── icons      - 常用圖標
```

### Helpers

```text
helpers/          - 各地方常用函示，例如 Log
├── exporter/     - 包裝匯出資料的 API
├── formater/     - 格式化資料
├── launcher      - 包裝「點擊連結會跳出瀏覽器」
├── logger        - 輸出，包括輸出到 Firebase Analytics
├── util          - 雜項
└── validator     - 驗證輸入的工具，例如文字必須為數字且必須大於一
```

### Models

```text
models/                          - 物件，例如產品、成份等等。會在這裡和 Services 接觸而非 UI 裡面
├── constumer/                   - 菜單
│    ├── customer_setting_option - 顧客設定的選項
│    └── customer_setting        - 顧客設定
├── menu/                        - 菜單
│    ├── catalog                 - 產品種類
│    ├── product_ingredient      - 產品的成分
│    ├── product_quantity        - 產品的份量
│    └── product                 - 產品
├── objects/                     - 用來做 I/O 的物件
│    ├── cashier_object          - 收銀機的物件
│    ├── customer_object         - 顧客設定的物件
│    ├── menu_object             - 菜單的物件
│    ├── order_attributeobject   - 訂單屬性（上面的顧客設定）
│    ├── order_object            - 訂單的物件
│    └── stock_object            - 庫存的物件
├── order/                       - 訂單
│    └── order_product           - 訂單的產品設定
├── repository/                  - 物件庫
│    ├── cart_ingredients        - 訂單時，產品的成份管理
│    ├── cart                    - 訂單的物件庫，購物車
│    ├── cashier                 - 收銀機的物件庫
│    ├── customer_settings       - 顧客設定的物件庫
│    ├── menu                    - 菜單的物件庫
│    ├── quantities              - 份量的物件庫
│    ├── replenisher             - 補貨的物件庫
│    ├── seller                  - 點單的物件庫，賣家，用來處理把訂單丟進 DB
│    └── stock                   - 庫存的物件庫，雖然 inventory 這名稱比較適合，但為時已晚
├── stock/                       - 庫存
│    ├── ingredient              - 庫存的成份
│    ├── quantity                - 庫存的成分數量
│    └── replenishment           - 庫存的補貨
├── model_object                 - object 的基本物件
├── model                        - model 的基本物件
├── repository                   - repository 的基本物件
└── xfile                        - 包裝檔案系統的 API
```

### Services

```text
services/               - 和應用程式外部溝通的工具，例如 DB
├── auth                - 驗證邏輯，使用者的登入等等
├── cache               - 記錄使用者的設定和行為，例如是否看過 tutorial
├── database            - 紀錄點單等多筆的資料，Sqlite
├── database_migrations - database 不同版本時整合的紀錄
├── image_dumper        - 管理 image 的存取
└── storage             - 紀錄菜單和庫存等高變種的資料，NoSQL
```

### Settings

```text
settings/                    - 使用者可以調整的設定，例如主題、語言
├── cashier_warning          - 收銀機的告警設定
├── collect_event            - 收集使用者錯誤訊息設定
├── currency                 - 幣種，目前尚無使用，僅是預先做好，未來有需要可以開
├── language                 - 語言
├── order_awakening          - 點餐時是否關閉螢幕的設定
├── order_outlook            - 點餐時的外觀設定
├── order_product_axis_count - 點餐時的外觀設定
├── theme                    - 主題，目前僅有日光和暗色
├── setting                  - 設定的介面
└── settings_provier         - 管理所有設定的介面
```

### UI

基本的框架為：

```text
feature/             - 特定功能
├── ...              - 功能下的子功能，若有會列出來
├── widgets/         - 功能的輔助物件，不會在下表中列出來
└── feature_screen   - 功能的架構，不會在下表中列出來
```

各介面：

```text
ui/                    - 應用程式主要外觀設計
├── analysis/          - 分析點單
├── cashier/           - 收銀機
│    └── changer       - 換錢
├── customer/          - 顧客設定
├── home/              - 主頁
├── menu/              - 菜單
│    ├── catalog/      - 產品種類
│    └── product/      - 產品
├── order/             - 點單
│    ├── cart          - 購物車
│    └── cashier       - 結帳
├── setting/           - 設定
└── stock/             - 庫存
     ├── quantity      - 成分數量
     └── replenishment - 補貨
```
