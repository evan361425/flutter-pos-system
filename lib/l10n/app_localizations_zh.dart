// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get settingTab => '設定';

  @override
  String settingVersion(String version) {
    return '版本：$version';
  }

  @override
  String settingWelcome(String name) {
    return 'HI，$name';
  }

  @override
  String get settingLogoutBtn => '登出';

  @override
  String get settingElfTitle => '建議';

  @override
  String get settingElfDescription => '使用 Google 表單提供回饋';

  @override
  String get settingElfContent =>
      '覺得這裡還少了什麼嗎？\n歡迎[提供建議](https://forms.gle/R1vZDk9ztQLScUdb9)。\n也可以來看看[排程中的功能](https://github.com/evan361425/flutter-pos-system/milestones)。';

  @override
  String get settingFeatureTitle => '其他設定';

  @override
  String get settingFeatureDescription => '外觀、語言、提示';

  @override
  String get settingThemeTitle => '調色盤';

  @override
  String settingThemeName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'dark': '暗色模式',
        'light': '日光模式',
        'system': '跟隨系統',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get settingLanguageTitle => '語言';

  @override
  String get settingCheckoutWarningTitle => '收銀機提示';

  @override
  String settingCheckoutWarningName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'showAll': '全部顯示',
        'onlyNotEnough': '僅不夠時顯示',
        'hideAll': '全部隱藏',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String settingCheckoutWarningTip(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'showAll': '若使用小錢去找，顯示提示。\n例如 5 塊錢不夠了，開始用 5 個 1 塊去找錢',
        'onlyNotEnough': '當零錢不夠找的時候，顯示提示。',
        'hideAll': '當點餐時，收銀機不會顯示任何提示',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get settingOrderAwakeningTitle => '點餐時不關閉螢幕';

  @override
  String get settingOrderAwakeningDescription => '若取消，則會根據系統設定時間關閉螢幕';

  @override
  String get settingReportTitle => '收集錯誤訊息和事件';

  @override
  String get settingReportDescription => '當應用程式發生錯誤時，寄送錯誤訊息，以幫助應用程式成長';

  @override
  String get stockTab => '庫存';

  @override
  String stockUpdatedAt(DateTime updatedAt) {
    final intl.DateFormat updatedAtDateFormat =
        intl.DateFormat.MMMEd(localeName);
    final String updatedAtString = updatedAtDateFormat.format(updatedAt);

    return '上次補貨時間：$updatedAtString';
  }

  @override
  String get stockIngredientEmptyBody => '新增成份後，就可以開始追蹤這些成份的庫存囉！';

  @override
  String get stockIngredientTitleCreate => '新增成分';

  @override
  String get stockIngredientTitleUpdate => '編輯成分';

  @override
  String get stockIngredientTitleUpdateAmount => '編輯庫存';

  @override
  String get stockIngredientTutorialTitle => '新增成分';

  @override
  String get stockIngredientTutorialContent =>
      '成份可以幫助我們確認產品的庫存。\n你可以在「產品」中設定成分，然後在這裡設定庫存。';

  @override
  String stockIngredientDialogDeletionContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '將會一同刪除掉 $count 個產品的成分',
      zero: '目前無任何產品有本成分',
    );
    return '$_temp0';
  }

  @override
  String stockIngredientProductsCount(int count) {
    return '共有 $count 個產品使用此成分';
  }

  @override
  String get stockIngredientNameLabel => '成分名稱';

  @override
  String get stockIngredientNameHint => '例如：起司';

  @override
  String get stockIngredientNameErrorRepeat => '成分名稱重複';

  @override
  String get stockIngredientAmountLabel => '現有庫存';

  @override
  String get stockIngredientAmountMaxLabel => '最大庫存';

  @override
  String get stockIngredientAmountMaxHelper =>
      '設定這個值可以幫助你一眼看出用了多少成分。\n填空或不填寫則每次增加庫存，都會自動設定這值，';

  @override
  String get stockIngredientRestockTitle =>
      '每次補貨可以補貨多少成分。\n例如，每 30 份起司要價 100 元，「補貨單位」就填寫 30，「補貨單價」就填寫 100。\n\n這可以幫助你透過價錢快速補貨。';

  @override
  String get stockIngredientRestockPriceLabel => '補貨單價';

  @override
  String get stockIngredientRestockQuantityLabel => '補貨單位';

  @override
  String stockIngredientRestockDialogTitle(String quantity, String price) {
    return '目前每$quantity個要價$price元';
  }

  @override
  String get stockIngredientRestockDialogSubtitle => '請輸入購買價格';

  @override
  String get stockIngredientRestockDialogQuantityTab => '數量';

  @override
  String get stockIngredientRestockDialogQuantityBtn => '使用數量';

  @override
  String get stockIngredientRestockDialogQuantityLabel => '現有庫存';

  @override
  String get stockIngredientRestockDialogQuantityHelper =>
      '若沒有設定最大庫存量，增加本值會重設最大庫存量。';

  @override
  String get stockIngredientRestockDialogPriceTab => '價格';

  @override
  String get stockIngredientRestockDialogPriceBtn => '使用價錢';

  @override
  String get stockIngredientRestockDialogPriceLabel => '補貨價格';

  @override
  String get stockIngredientRestockDialogPriceEmptyBody =>
      '趕緊設定單價，讓你可以利用補貨的金額直接算出補貨的量。';

  @override
  String get stockIngredientRestockDialogPriceOldAmount => '原始庫存';

  @override
  String get stockReplenishmentButton => '採購';

  @override
  String get stockReplenishmentEmptyBody => '採購可以幫你快速調整成分的庫存';

  @override
  String get stockReplenishmentTitleList => '採購列表';

  @override
  String get stockReplenishmentTitleCreate => '新增採購';

  @override
  String get stockReplenishmentTitleUpdate => '編輯採購';

  @override
  String stockReplenishmentMetaAffect(int count) {
    return '會影響 $count 項成分';
  }

  @override
  String get stockReplenishmentNever => '尚未補貨過';

  @override
  String get stockReplenishmentApplyPreview => '預覽';

  @override
  String get stockReplenishmentApplyConfirmButton => '套用';

  @override
  String get stockReplenishmentApplyConfirmTitle => '套用採購？';

  @override
  String stockReplenishmentApplyConfirmColumn(String value) {
    String _temp0 = intl.Intl.selectLogic(
      value,
      {
        'name': '名稱',
        'amount': '數量',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get stockReplenishmentApplyConfirmHint => '選擇套用後，將會影響以下成分的庫存';

  @override
  String get stockReplenishmentTutorialTitle => '成份採購';

  @override
  String get stockReplenishmentTutorialContent =>
      '透過採購，你不再需要一個一個去設定成分的庫存。\n馬上設定採購，一次調整多個成份吧！';

  @override
  String get stockReplenishmentNameLabel => '採購名稱';

  @override
  String get stockReplenishmentNameHint => '例如：Costco 採購';

  @override
  String get stockReplenishmentNameErrorRepeat => '採購名稱重複';

  @override
  String get stockReplenishmentIngredientsDivider => '成分';

  @override
  String get stockReplenishmentIngredientsHelper => '點選以設定不同成分欲採購的量';

  @override
  String get stockReplenishmentIngredientAmountHint => '設定增加／減少的量';

  @override
  String get stockQuantityTitle => '份量';

  @override
  String get stockQuantityDescription => '半糖、微糖等';

  @override
  String get stockQuantityTitleCreate => '新增份量';

  @override
  String get stockQuantityTitleUpdate => '編輯份量';

  @override
  String get stockQuantityEmptyBody => '份量可以快速調整成分的量，例如：\n半糖、微糖。';

  @override
  String stockQuantityMetaProportion(num proportion) {
    final intl.NumberFormat proportionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String proportionString = proportionNumberFormat.format(proportion);

    return '預設比例：$proportionString';
  }

  @override
  String stockQuantityDialogDeletionContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '將會一同刪除掉 $count 個產品成分的份量\'',
      zero: '目前無任何產品成分有本份量',
    );
    return '$_temp0';
  }

  @override
  String get stockQuantityNameLabel => '份量名稱';

  @override
  String get stockQuantityNameHint => '例如：少量或多量';

  @override
  String get stockQuantityNameErrorRepeat => '份量名稱重複';

  @override
  String get stockQuantityProportionLabel => '預設比例';

  @override
  String get stockQuantityProportionHelper =>
      '當產品成分使用此份量時，預設替該成分增加的比例。\n\n例如：此份量為「多量」預設份量為「1.5」，\n今有一產品「起司漢堡」的成分「起司」，每份漢堡會使用「2」單位的起司，\n當增加此份量時，則會自動替「起司」設定為「3」（2 * 1.5）的份量。\n\n若設為「1」則無任何影響。\n\n若設為「0」則代表將不會使用此成分';

  @override
  String get printerTitle => '出單機管理';

  @override
  String get printerDescription => '藍牙連線、出單設定';

  @override
  String get printerHeaderInfo => '出單機';

  @override
  String get printerTitleCreate => '新增出單機';

  @override
  String get printerTitleUpdate => '編輯出單機';

  @override
  String get printerTitleSettings => '設定格式';

  @override
  String get printerBtnConnect => '建立連線';

  @override
  String get printerBtnDisconnect => '中斷連線';

  @override
  String get printerBtnTestPrint => '列印測試';

  @override
  String get printerBtnRetry => '重新連線';

  @override
  String get printerBtnPrint => '列印';

  @override
  String get printerStatusSuccess => '成功連結出單機';

  @override
  String get printerStatusConnecting => '連線中';

  @override
  String get printerStatusStandby => '尚未進行連線';

  @override
  String get printerStatusPrinted => '列印完成';

  @override
  String printerStatusName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'good': '正常',
        'writeFailed': '上次列印失敗',
        'paperNotFound': '缺紙',
        'tooHot': '出單機過熱',
        'lowBattery': '電量不足',
        'printing': '列印中',
        'unknown': '未知',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String printerSignalName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'good': '良好',
        'normal': '一般',
        'weak': '微弱',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get printerScanIng => '搜尋藍牙設備中...';

  @override
  String printerScanCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '搜尋到 $countString 個裝置';
  }

  @override
  String get printerScanRetry => '重新搜尋';

  @override
  String get printerScanNotFound => '找不到裝置？';

  @override
  String get printerErrorNotSelect => '尚未選擇裝置';

  @override
  String get printerErrorNotSupportTitle => '裝置不相容';

  @override
  String get printerErrorNotSupportContent =>
      '目前尚未支援此裝置，你可以[聯絡我們](mailto:evanlu361425@gmail.com)以取得協助。';

  @override
  String get printerErrorBluetoothOff => '藍牙未開啟';

  @override
  String get printerErrorDisconnected => '出單機已斷線';

  @override
  String get printerErrorTimeout => '出單機連線逾時';

  @override
  String get printerErrorCanceled => '出單機連線請求被中斷';

  @override
  String get printerErrorTimeoutMore =>
      '可以嘗試以下操作：\n• 確認裝置是否開啟（通常裝置會閃爍）\n• 確認裝置是否在範圍內\n• 重新開啟藍牙';

  @override
  String get printerNameLabel => '出單機名稱';

  @override
  String get printerNameHint => '例如：廚房的出單機';

  @override
  String printerNameHelper(String address) {
    return '位置：$address';
  }

  @override
  String get printerAutoConnLabel => '自動連線';

  @override
  String get printerAutoConnHelper => '當進入訂單頁時自動連線';

  @override
  String get printerMetaConnected => '已連線';

  @override
  String get printerMetaExist => '已建立，無法新增';

  @override
  String get printerMetaHelper => '打開藍牙並確保出單機就在你旁邊';

  @override
  String get printerSettingsTitle => '設定出單機格式';

  @override
  String get printerSettingsPaddingLabel => '窄間距';

  @override
  String get printerSettingsPaddingHelper => '單子跟單子之間的空白會變少，較省紙張，但是撕紙時要小心';

  @override
  String get printerSettingsMore => '其他更多設定，敬請期待！';

  @override
  String get printerReceiptTitle => '交易明細';

  @override
  String get printerReceiptColumnName => '品項';

  @override
  String get printerReceiptColumnPrice => '單價';

  @override
  String get printerReceiptColumnCount => '數量';

  @override
  String get printerReceiptColumnTotal => '小計';

  @override
  String get printerReceiptColumnTime => '時間';

  @override
  String get printerReceiptDiscountLabel => '折扣';

  @override
  String get printerReceiptDiscountOrigin => '原單價';

  @override
  String get printerReceiptAddOnsLabel => '附加';

  @override
  String get printerReceiptAddOnsAdjustment => '調整金額';

  @override
  String get printerReceiptTotal => '總價';

  @override
  String get printerReceiptPaid => '付額';

  @override
  String get printerReceiptPrice => '總價';

  @override
  String get printerReceiptChange => '找錢';

  @override
  String get printerInfoTitle => '出單機資訊';

  @override
  String get printerInfoName => '名稱';

  @override
  String get printerInfoAddress => '位置';

  @override
  String get printerInfoSignal => '訊號強度';

  @override
  String get printerInfoStatus => '狀態';

  @override
  String get transitTitle => '資料轉移';

  @override
  String get transitDescription => '匯入、匯出店家資訊和訂單';

  @override
  String get transitDescriptionCsv => '用逗號分隔的列表，輕量級的匯出和匯入資料，幾乎兼容所有軟體。';

  @override
  String get transitDescriptionExcel =>
      'Excel 可以離線匯出和匯入，容易與 Google 試算表和 Microsoft Excel 整合。';

  @override
  String get transitDescriptionGoogleSheet =>
      'Google 試算表是一個強大的小型資料庫，匯出之後可以做很多客制化的分析！';

  @override
  String get transitDescriptionPlainText => '快速檢查、快速分享。';

  @override
  String get transitMethodTitle => '請選擇欲轉移的方式';

  @override
  String transitMethodName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'googleSheet': 'Google 試算表',
        'plainText': '純文字',
        'excel': 'Excel 檔案',
        'csv': 'CSV 檔案',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String transitCatalogTitle(Object name) {
    return '用 $name 做什麼？';
  }

  @override
  String transitCatalogName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'exportOrder': '匯出訂單記錄',
        'exportModel': '匯出店家資訊',
        'importModel': '匯入店家資訊',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String transitCatalogHelper(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'exportOrder': '訂單資訊可以讓你匯出到第三方位置後做更細緻的統計分析。',
        'exportModel': '商家資訊是用來把菜單、庫存等資訊備份到第三方位置。',
        'importModel': '同步資訊到此設備。',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String transitModelName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'menu': '菜單',
        'stock': '庫存',
        'quantities': '份量',
        'replenisher': '補貨',
        'orderAttr': '顧客設定',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String transitOrderName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'basic': '訂單',
        'attr': '顧客細項',
        'product': '產品細項',
        'ingredient': '成分細項',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get transitOrderSettingTitle => '訂單匯出設定';

  @override
  String transitOrderSettingMetaOverwrite(String value) {
    String _temp0 = intl.Intl.selectLogic(
      value,
      {
        'true': '會覆寫',
        'false': '不會覆寫',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String transitOrderSettingMetaTitlePrefix(String value) {
    String _temp0 = intl.Intl.selectLogic(
      value,
      {
        'true': '有日期前綴',
        'false': '無日期前綴',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get transitOrderSettingOverwriteLabel => '是否覆寫表單';

  @override
  String get transitOrderSettingOverwriteHint => '覆寫表單之後，將會從第一行開始匯出';

  @override
  String get transitOrderSettingTitlePrefixLabel => '加上日期前綴';

  @override
  String get transitOrderSettingTitlePrefixHint =>
      '表單名稱前面加上日期前綴，例如：「0101 - 0131 訂單資料」';

  @override
  String get transitOrderSettingRecommendCombination =>
      '不覆寫而改用附加的時候，建議表單名稱「不要」加上日期前綴';

  @override
  String transitOrderMetaRange(String range) {
    return '$range 的訂單';
  }

  @override
  String transitOrderMetaRangeDays(int days) {
    return '$days 天的資料';
  }

  @override
  String transitOrderCapacityTitle(Object size) {
    return '預估容量為：$size';
  }

  @override
  String get transitOrderCapacityContent => '過高的容量可能會讓執行錯誤，建議分次執行，不要一次匯出太多筆。';

  @override
  String get transitOrderCapacityOk => '容量剛好';

  @override
  String get transitOrderCapacityWarn => '容量警告';

  @override
  String get transitOrderCapacityDanger => '容量危險';

  @override
  String transitOrderItemTitle(DateTime date) {
    final intl.DateFormat dateDateFormat =
        intl.DateFormat('MMM d HH:mm:ss', localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String transitOrderItemMetaProductCount(int count) {
    return '餐點數：$count';
  }

  @override
  String transitOrderItemMetaPrice(String price) {
    return '總價：$price';
  }

  @override
  String get transitOrderItemDialogTitle => '訂單細節';

  @override
  String get transitExportTab => '匯出';

  @override
  String get transitExportFileDialogTitle => '選擇匯出的位置';

  @override
  String get transitExportBasicBtnCsv => '匯出成 CSV 檔';

  @override
  String get transitExportBasicBtnExcel => '匯出成 Excel 檔';

  @override
  String get transitExportBasicBtnGoogleSheet => '匯出至 Google 試算表';

  @override
  String get transitExportBasicBtnPlainText => '純文字拷貝';

  @override
  String get transitExportBasicFileName => 'POS 系統資料';

  @override
  String get transitExportBasicSuccessCsv => '匯出成功';

  @override
  String get transitExportBasicSuccessExcel => '匯出成功';

  @override
  String get transitExportBasicSuccessGoogleSheet => '上傳成功';

  @override
  String get transitExportBasicSuccessPlainText => '拷貝成功';

  @override
  String get transitExportBasicSuccessActionGoogleSheet => '開啟表單';

  @override
  String get transitExportOrderTitleCsv => '匯出成 CSV 檔';

  @override
  String get transitExportOrderTitleExcel => '匯出成 Excel 檔';

  @override
  String get transitExportOrderTitleGoogleSheet => '匯出至 Google 試算表';

  @override
  String get transitExportOrderTitlePlainText => '純文字拷貝';

  @override
  String get transitExportOrderSubtitleCsv => '會有多個檔案，每個檔案包含不同的資料';

  @override
  String get transitExportOrderSubtitleExcel => '單一檔案內含工作表，每個工作表包含不同的資料';

  @override
  String get transitExportOrderSubtitleGoogleSheet =>
      '上傳需要網路連線，且請求可能會被 Google 限制。\n若上傳失敗，請稍後再試或使用其他方式匯出。\n';

  @override
  String get transitExportOrderSubtitlePlainText => '適合用來簡單的分享或檢查資料';

  @override
  String get transitExportOrderFileName => '訂單資料';

  @override
  String get transitExportOrderProgressGoogleSheetOverwrite => '資料覆寫中';

  @override
  String get transitExportOrderProgressGoogleSheetAppend => '資料附加進既有資料中';

  @override
  String get transitExportOrderWarningMemoryGoogleSheet =>
      '這裡的容量代表網路傳輸所消耗的量，實際佔用的雲端記憶體可能是此值的百分之一而已。\n詳細容量限制說明可以參考[本文件](https://developers.google.com/sheets/api/limits#quota)。\n';

  @override
  String get transitExportOrderSuccessCsv => '匯出成功';

  @override
  String get transitExportOrderSuccessExcel => '匯出成功';

  @override
  String get transitExportOrderSuccessGoogleSheet => '上傳成功';

  @override
  String get transitExportOrderSuccessPlainText => '拷貝成功';

  @override
  String get transitExportOrderSuccessActionGoogleSheet => '開啟表單';

  @override
  String get transitImportTab => '匯入';

  @override
  String get transitImportBtnCsv => '選擇 .csv 檔';

  @override
  String get transitImportBtnExcel => '選擇 .xlsx 檔';

  @override
  String get transitImportBtnGoogleSheet => '選擇 Google 試算表';

  @override
  String get transitImportBtnPlainTextAction => '點選以貼上文字';

  @override
  String get transitImportBtnPlainTextHint => '貼上複製而來的文字';

  @override
  String get transitImportBtnPlainTextHelper =>
      '貼上文字後，會分析文字並決定匯入的是什麼種類的資訊。\n複製過大的文字可能會造成系統的崩潰。\n';

  @override
  String get transitImportModelSelectionLabel => '資料類型';

  @override
  String get transitImportModelSelectionAll => '全部';

  @override
  String get transitImportModelSelectionHint => '請先選擇資料類型來進行匯入';

  @override
  String get transitImportModelSelectionPlainTextHint => '請先輸入文字來進行匯入';

  @override
  String get transitImportProgressGoogleSheetStart => '拉取試算表資料中';

  @override
  String get transitImportProgressGoogleSheetPrepare => '取得試算表資訊中';

  @override
  String transitImportErrorBasicColumnCount(int columns) {
    return '資料量不足，需要 $columns 個欄位';
  }

  @override
  String get transitImportErrorBasicDuplicate => '將忽略本行，相同的項目已於前面出現';

  @override
  String get transitImportErrorCsvPickFile => '選擇檔案失敗';

  @override
  String get transitImportErrorExcelPickFile => '選擇檔案失敗';

  @override
  String get transitImportErrorGoogleSheetFetchDataTitle => '無法拉取試算表資料';

  @override
  String get transitImportErrorGoogleSheetFetchDataHelper =>
      '別擔心，通常都可以簡單解決！\n可能的原因有：\n• 網路狀況不穩；\n• 尚未授權 POS 系統進行表單的讀取；\n• 試算表 ID 打錯了，請嘗試複製整個網址後貼上；\n• 該試算表被刪除了。';

  @override
  String transitImportErrorGoogleSheetMissingTitle(Object name) {
    return '找不到表單 $name 的資料';
  }

  @override
  String get transitImportErrorGoogleSheetMissingHelper =>
      '別擔心，通常都可以簡單解決！\n可能的原因有：\n• 該試算表沒有我們想要的表單；\n• 網路狀況不穩；\n• 尚未授權 POS 系統進行表單的讀取；\n• 試算表 ID 打錯了，請嘗試複製整個網址後貼上；\n• 該試算表被刪除了。';

  @override
  String transitImportErrorPreviewNotFound(Object name) {
    return '找不到「$name」的資料';
  }

  @override
  String get transitImportErrorPlainTextNotFound =>
      '這段文字無法匹配相應的服務，請參考匯出時的文字內容。';

  @override
  String get transitImportSuccess => '匯入成功';

  @override
  String get transitImportPreviewConfirmTitle => '確定匯入？';

  @override
  String get transitImportPreviewConfirmContent => '注意：匯入後將會把沒列到的資料移除，請確認是否執行！';

  @override
  String get transitImportPreviewConfirmBtn => '匯入資料';

  @override
  String get transitImportPreviewConfirmVerify => '確認資料';

  @override
  String transitImportPreviewConfirmHint(int count) {
    return '還差 $count 種資料未確認。\n請確認資料是否正確，若有錯誤請取消操作並修正後重新匯入。\n';
  }

  @override
  String transitImportPreviewIngredientMetaAmount(num amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '庫存：$amountString';
  }

  @override
  String transitImportPreviewIngredientMetaMaxAmount(int exist, num value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    String _temp0 = intl.Intl.pluralLogic(
      exist,
      locale: localeName,
      other: '最大值：$valueString',
      zero: '未設定',
    );
    return '$_temp0';
  }

  @override
  String get transitImportPreviewIngredientConfirm =>
      '注意：匯入後，為了避免影響「菜單」的狀況，並不會把沒列出的成分移除。';

  @override
  String get transitImportPreviewQuantityConfirm =>
      '注意：匯入後，為了避免影響「菜單」的狀況，並不會把沒列出的份量移除。';

  @override
  String transitImportColumnStatus(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'normal': '（一般）',
        'staged': '（新增）',
        'stagedIng': '（新的成分）',
        'stagedQua': '（新的份量）',
        'updated': '（異動）',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get transitFormatFieldProductIngredientTitle => '成分資訊';

  @override
  String get transitFormatFieldProductIngredientNote =>
      '產品全部成分的資訊，格式如下：\n- 成分1,預設使用量\n  + 份量a,額外使用量,額外價格,額外成本\n  + 份量b,額外使用量,額外價格,額外成本\n- 成分2,預設使用量';

  @override
  String get transitFormatFieldReplenishmentTitle => '補貨量';

  @override
  String get transitFormatFieldReplenishmentNote =>
      '每次補貨時特定成分的量，格式如下：\n- 成分1,補貨量\n- 成分2,補貨量';

  @override
  String get transitFormatFieldAttributeOptionTitle => '顧客設定選項';

  @override
  String get transitFormatFieldAttributeOptionNote =>
      '「選項值」會根據顧客設定種類不同而有不同意義，格式如下：\n- 選項1,是否為預設,選項值\n- 選項2,是否為預設,選項值';

  @override
  String get transitFormatFieldOrderTs => '時間戳記';

  @override
  String get transitFormatFieldOrderTime => '時間';

  @override
  String get transitFormatFieldOrderPrice => '總價';

  @override
  String get transitFormatFieldOrderProductPrice => '產品總價';

  @override
  String get transitFormatFieldOrderPaid => '付額';

  @override
  String get transitFormatFieldOrderCost => '成本';

  @override
  String get transitFormatFieldOrderProfit => '收入';

  @override
  String get transitFormatFieldOrderItemCount => '產品份數';

  @override
  String get transitFormatFieldOrderTypeCount => '產品類數';

  @override
  String get transitFormatFieldOrderAttributeTitle => '訂單顧客設定';

  @override
  String get transitFormatFieldOrderAttributeHeaderTs => '時間戳記';

  @override
  String get transitFormatFieldOrderAttributeHeaderName => '設定類別';

  @override
  String get transitFormatFieldOrderAttributeHeaderOption => '選項';

  @override
  String get transitFormatFieldOrderProductTitle => '訂單產品細項';

  @override
  String get transitFormatFieldOrderProductHeaderTs => '時間戳記';

  @override
  String get transitFormatFieldOrderProductHeaderName => '產品';

  @override
  String get transitFormatFieldOrderProductHeaderCatalog => '種類';

  @override
  String get transitFormatFieldOrderProductHeaderCount => '數量';

  @override
  String get transitFormatFieldOrderProductHeaderPrice => '單一售價';

  @override
  String get transitFormatFieldOrderProductHeaderCost => '單一成本';

  @override
  String get transitFormatFieldOrderProductHeaderOrigin => '單一原價';

  @override
  String get transitFormatFieldOrderIngredientTitle => '訂單成分細項';

  @override
  String get transitFormatFieldOrderIngredientHeaderTs => '時間戳記';

  @override
  String get transitFormatFieldOrderIngredientHeaderName => '成分';

  @override
  String get transitFormatFieldOrderIngredientHeaderQuantity => '份量';

  @override
  String get transitFormatFieldOrderIngredientHeaderAmount => '數量';

  @override
  String get transitFormatFieldOrderExpandableHint => '詳見下欄';

  @override
  String transitFormatTextOrderPrice(
      int hasProducts, String price, String productsPrice) {
    String _temp0 = intl.Intl.pluralLogic(
      hasProducts,
      locale: localeName,
      other: '共 $price 元，其中的 $productsPrice 元是產品價錢。',
      zero: '共 $price 元。',
    );
    return '$_temp0';
  }

  @override
  String transitFormatTextOrderMoney(String paid, String cost) {
    return '付額 $paid 元、成分 $cost 元。';
  }

  @override
  String transitFormatTextOrderProductCount(
      int count, int setCount, String products) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '餐點有 $count 份（$setCount 種組合）包括：\n$products。',
      one: '餐點有 $count 份，內容為：\n$products。',
      zero: '沒有任何餐點。',
    );
    return '$_temp0';
  }

  @override
  String transitFormatTextOrderProduct(int hasIngredient, String product,
      String catalog, int count, String price, String ingredients) {
    String _temp0 = intl.Intl.pluralLogic(
      hasIngredient,
      locale: localeName,
      other: '$product（$catalog）$count 份共 $price 元，成份包括 $ingredients',
      zero: '$product（$catalog）$count 份共 $price 元，沒有設定成分',
    );
    return '$_temp0';
  }

  @override
  String transitFormatTextOrderIngredient(
      num amount, String ingredient, String quantity) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: '$ingredient（$quantity），使用 $amountString 個',
      zero: '$ingredient（$quantity）',
    );
    return '$_temp0';
  }

  @override
  String get transitFormatTextOrderNoQuantity => '預設份量';

  @override
  String transitFormatTextOrderOrderAttribute(String options) {
    return '顧客的 $options';
  }

  @override
  String transitFormatTextOrderOrderAttributeItem(String name, String option) {
    return '$name 為 $option';
  }

  @override
  String transitFormatTextMenuHeader(int catalogs, int products) {
    return '本菜單共有 $catalogs 個產品種類、$products 個產品。';
  }

  @override
  String get transitFormatTextMenuHeaderPrefix => '本菜單';

  @override
  String transitFormatTextMenuCatalog(
      String index, String catalog, String details) {
    return '第$index個種類叫做 $catalog，$details。';
  }

  @override
  String transitFormatTextMenuCatalogDetails(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '共有 $count 個產品',
      zero: '沒有設定產品',
    );
    return '$_temp0';
  }

  @override
  String transitFormatTextMenuProduct(
      String index, String name, String price, String cost, String details) {
    return '第$index個產品叫做 $name，其售價為 $price 元，成本為 $cost 元，$details';
  }

  @override
  String transitFormatTextMenuProductDetails(
      int count, String names, String details) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '它的成份有 $count 種：$names。\n每份產品預設需要使用 $details。',
      zero: '它沒有設定任何成份。',
    );
    return '$_temp0';
  }

  @override
  String transitFormatTextMenuIngredient(
      String amount, String name, String details) {
    return '$amount 個 $name，$details';
  }

  @override
  String transitFormatTextMenuIngredientDetails(int count, String quantities) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '它還有 $count 個不同份量 $quantities',
      zero: '無法做份量調整',
    );
    return '$_temp0';
  }

  @override
  String transitFormatTextMenuQuantity(
      String amount, String price, String cost) {
    return '每份產品改成使用 $amount 個並調整產品售價 $price 元和成本 $cost 元';
  }

  @override
  String transitFormatTextStockHeader(int count) {
    return '本庫存共有 $count 種成分。';
  }

  @override
  String get transitFormatTextStockHeaderPrefix => '本庫存';

  @override
  String transitFormatTextStockIngredient(
      String index, String name, String amount, String details) {
    return '第$index個成分叫做 $name，庫存現有 $amount 個$details。';
  }

  @override
  String transitFormatTextStockIngredientMaxAmount(int exist, String max) {
    String _temp0 = intl.Intl.pluralLogic(
      exist,
      locale: localeName,
      other: '，最大量有 $max 個',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String transitFormatTextStockIngredientRestockPrice(
      int exist, String quantity, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      exist,
      locale: localeName,
      other: '且每 $quantity 個成本要價 $price 元',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String transitFormatTextQuantitiesHeader(int count) {
    return '共設定 $count 種份量。';
  }

  @override
  String get transitFormatTextQuantitiesHeaderSuffix => '種份量。';

  @override
  String transitFormatTextQuantitiesQuantity(
      String index, String name, String prop) {
    return '第$index種份量叫做 $name，預設會讓成分的份量乘以 $prop 倍。';
  }

  @override
  String transitFormatTextReplenisherHeader(int count) {
    return '共設定 $count 種補貨方式。';
  }

  @override
  String get transitFormatTextReplenisherHeaderSuffix => '種補貨方式。';

  @override
  String transitFormatTextReplenisherReplenishment(
      String index, String name, String details) {
    return '第$index個成分叫做 $name，$details。';
  }

  @override
  String transitFormatTextReplenisherReplenishmentDetails(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '它會調整$count種成份的庫存',
      zero: '它並不會調整庫存',
    );
    return '$_temp0';
  }

  @override
  String transitFormatTextOaHeader(int count) {
    return '共設定 $count 種顧客屬性。';
  }

  @override
  String get transitFormatTextOaHeaderSuffix => '種顧客屬性。';

  @override
  String transitFormatTextOaOa(
      String index, String name, String mode, String details) {
    return '第$index種屬性叫做 $name，屬於 $mode 類型，$details。';
  }

  @override
  String transitFormatTextOaOaDetails(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '它有 $count 個選項',
      zero: '它並沒有設定選項',
    );
    return '$_temp0';
  }

  @override
  String get transitFormatTextOaDefaultOption => '預設';

  @override
  String transitFormatTextOaModeValue(num value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '選項的值為 $valueString';
  }

  @override
  String get transitGoogleSheetDialogTitle => '提供 Google 試算表';

  @override
  String get transitGoogleSheetDialogCreate => '建立新的試算表';

  @override
  String get transitGoogleSheetDialogSelectExist => '選擇現有的試算表';

  @override
  String get transitGoogleSheetDialogConfirm => '確認';

  @override
  String get transitGoogleSheetDialogIdLabel => '試算表 ID 或網址';

  @override
  String get transitGoogleSheetDialogIdHelper =>
      '試算表的 ID 是網址中的英文、數字、底線和減號的組合。\n例如，\"https://docs.google.com/spreadsheets/d/1a2b3c4d5e6f7g8h9i0j\" 的 ID 是 \"1a2b3c4d5e6f7g8h9i0j\"。\n使用現有的試算表將可能覆蓋選擇的工作表中的數據。';

  @override
  String get transitGoogleSheetProgressCreate => '建立試算表';

  @override
  String get transitGoogleSheetProgressFulfill => '在試算表中建立表單';

  @override
  String get transitGoogleSheetErrorCreateTitle => '無法建立試算表';

  @override
  String get transitGoogleSheetErrorCreateHelper =>
      '別擔心，通常都可以簡單解決！\n可能的原因有：\n• 網路狀況不穩；\n• 尚未授權 POS 系統進行表單的編輯。';

  @override
  String get transitGoogleSheetErrorFulfillTitle => '無法在試算表中建立表單';

  @override
  String get transitGoogleSheetErrorFulfillHelper =>
      '別擔心，通常都可以簡單解決！\n可能的原因有：\n• 網路狀況不穩；\n• 尚未授權 POS 系統進行表單的建立；\n• 試算表 ID 打錯了，請嘗試複製整個網址後貼上；\n• 該試算表被刪除了。';

  @override
  String get transitGoogleSheetErrorIdNotFound => '找不到試算表';

  @override
  String get transitGoogleSheetErrorIdNotFoundHelper =>
      '別擔心，通常都可以簡單解決！\n可能的原因有：\n• 網路狀況不穩；\n• 尚未授權 POS 系統進行表單的讀取；\n• 試算表 ID 打錯了，請嘗試複製整個網址後貼上；\n• 該試算表被刪除了。';

  @override
  String get transitGoogleSheetErrorIdEmpty => 'ID 不能為空';

  @override
  String get transitGoogleSheetErrorIdInvalid =>
      '不合法的 ID，必須包含：\n• /spreadsheets/d/<ID>/\n• 或者直接給 ID（英文+數字+底線+減號的組合）';

  @override
  String get appTitle => 'POS 系統';

  @override
  String get actSuccess => '執行成功';

  @override
  String get actError => '錯誤';

  @override
  String get actMoreInfo => '說明';

  @override
  String get singleChoice => '一次只能選擇一種';

  @override
  String get multiChoices => '可以選擇多種';

  @override
  String totalCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '總共 $countString 項',
    );
    return '$_temp0';
  }

  @override
  String searchCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '搜尋到 $countString 個結果';
  }

  @override
  String title(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'analysis': '分析',
        'stock': '庫存',
        'cashier': '收銀',
        'settings': '設定',
        'menu': '菜單',
        'printers': '出單機',
        'transit': '資料轉移',
        'orderAttributes': '顧客設定',
        'stockQuantities': '份量',
        'elf': '建議',
        'more': '更多',
        'debug': 'Debug',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get dialogDeletionTitle => '刪除確認通知';

  @override
  String dialogDeletionContent(String name, String more) {
    return '確定要刪除「$name」嗎？\n\n$more此動作將無法復原！';
  }

  @override
  String get imageHolderCreate => '點選以新增圖片';

  @override
  String get imageHolderUpdate => '點擊以更新圖片';

  @override
  String get imageBtnCrop => '裁切';

  @override
  String get imageGalleryTitle => '圖片管理';

  @override
  String get imageGalleryEmpty => '點擊開始匯入你的第一張照片！';

  @override
  String get imageGalleryActionCreate => '新增圖片';

  @override
  String get imageGalleryActionDelete => '刪除';

  @override
  String get imageGallerySnackbarDeleteFailed => '有一個或多個圖片沒有刪成功。';

  @override
  String get imageGallerySelectionTitle => '選擇相片';

  @override
  String imageGallerySelectionDeleteConfirm(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '將會刪除 $countString 個圖片\n刪除之後會讓相關產品顯示不到圖片';
  }

  @override
  String get emptyBodyTitle => '哎呀！這裡還是空的';

  @override
  String get emptyBodyAction => '立即設定';

  @override
  String get btnNavTo => '查看';

  @override
  String get btnSignInWithGoogle => '使用 Google 登入';

  @override
  String semanticsPercentileBar(num percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '目前佔總數的 $percentString';
  }

  @override
  String invalidIntegerType(String field) {
    return '$field必須是整數';
  }

  @override
  String invalidNumberType(String field) {
    return '$field必須是數字';
  }

  @override
  String invalidNumberPositive(String field) {
    return '$field不能為負數';
  }

  @override
  String invalidNumberMaximum(String field, num maximum) {
    final intl.NumberFormat maximumNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String maximumString = maximumNumberFormat.format(maximum);

    return '$field不能超過 $maximumString';
  }

  @override
  String invalidNumberMinimum(String field, num minimum) {
    final intl.NumberFormat minimumNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minimumString = minimumNumberFormat.format(minimum);

    return '$field不能低於 $minimumString';
  }

  @override
  String invalidStringEmpty(String field) {
    return '$field不能為空';
  }

  @override
  String invalidStringMaximum(String field, int maximum) {
    return '$field不能超過 $maximum 個字';
  }

  @override
  String get singleMonth => '單月';

  @override
  String get singleWeek => '單週';

  @override
  String get twoWeeks => '雙週';

  @override
  String get orderAttributeTitle => '顧客設定';

  @override
  String get orderAttributeDescription => '內用、外帶等幫助分析的資訊';

  @override
  String get orderAttributeTitleCreate => '新增顧客設定';

  @override
  String get orderAttributeTitleUpdate => '編輯顧客設定';

  @override
  String get orderAttributeTitleReorder => '排序顧客設定';

  @override
  String get orderAttributeEmptyBody =>
      '顧客設定可以幫助我們統計哪些人來消費，例如：\n20-30歲、外帶、上班族。';

  @override
  String get orderAttributeHeaderInfo => '顧客設定';

  @override
  String get orderAttributeTutorialTitle => '建立屬於你的顧客設定';

  @override
  String get orderAttributeTutorialContent =>
      '這裡是用來設定顧客的資訊，例如：內用、外帶、上班族等。\n這些資訊可以幫助我們統計哪些人來消費，進而做出更好的經營策略。';

  @override
  String get orderAttributeTutorialCreateExample => '幫助建立一份範例以供測試。';

  @override
  String get orderAttributeExampleAge => '年齡';

  @override
  String get orderAttributeExampleAgeChild => '小孩';

  @override
  String get orderAttributeExampleAgeAdult => '成人';

  @override
  String get orderAttributeExampleAgeSenior => '長者';

  @override
  String get orderAttributeExamplePlace => '位置';

  @override
  String get orderAttributeExamplePlaceTakeout => '外帶';

  @override
  String get orderAttributeExamplePlaceDineIn => '內用';

  @override
  String get orderAttributeExampleEcoFriendly => '環保';

  @override
  String get orderAttributeExampleEcoFriendlyReusableBottle => '環保杯';

  @override
  String get orderAttributeExampleEcoFriendlyReusableBag => '環保袋';

  @override
  String orderAttributeMetaMode(String name) {
    return '種類：$name';
  }

  @override
  String orderAttributeMetaDefault(String name) {
    return '預設：$name';
  }

  @override
  String get orderAttributeMetaNoDefault => '未設定預設';

  @override
  String get orderAttributeModeDivider => '顧客設定種類';

  @override
  String orderAttributeModeName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'statOnly': '一般',
        'changePrice': '變價',
        'changeDiscount': '折扣',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String orderAttributeModeHelper(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'statOnly': '一般的設定，選取時並不會影響點單價格。',
        'changePrice': '選取設定時，可能會影響價格。\n例如：外送 + 30塊錢、環保杯 - 5塊錢。',
        'changeDiscount': '選取設定時，會根據折扣影響總價。\n例如：內用 + 10% 服務費、親友價 - 10%。',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get orderAttributeNameLabel => '顧客設定名稱';

  @override
  String get orderAttributeNameHint => '例如：顧客年齡';

  @override
  String get orderAttributeNameErrorRepeat => '名稱不能重複';

  @override
  String get orderAttributeOptionTitleCreate => '新增選項';

  @override
  String get orderAttributeOptionTitleUpdate => '編輯選項';

  @override
  String get orderAttributeOptionTitleReorder => '排序選項';

  @override
  String get orderAttributeOptionMetaDefault => '預設';

  @override
  String orderAttributeOptionMetaOptionOf(String name) {
    return '$name的選項';
  }

  @override
  String get orderAttributeOptionNameLabel => '選項名稱';

  @override
  String get orderAttributeOptionNameHelper =>
      '以年齡為例，可能的選項有：\n- ⇣ 20\n- 20 ⇢ 30';

  @override
  String get orderAttributeOptionNameErrorRepeat => '名稱不能重複';

  @override
  String get orderAttributeOptionModeTitle => '選項模式';

  @override
  String orderAttributeOptionModeHelper(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'statOnly': '因為本設定為「一般」故無須設定「折價」或「變價」',
        'changePrice': '訂單時選擇此項會套用此變價',
        'changeDiscount': '訂單時選擇此項會套用此折價',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String orderAttributeOptionModeHint(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'statOnly': '',
        'changePrice': '例如：-30 代表減少三十塊',
        'changeDiscount': '例如：80 代表「八折」',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get orderAttributeOptionToDefaultLabel => '設為預設';

  @override
  String get orderAttributeOptionToDefaultHelper =>
      '設定此選項為預設值，每個訂單預設都會是使用這個選項。';

  @override
  String get orderAttributeOptionToDefaultConfirmChangeTitle => '覆蓋選項預設？';

  @override
  String orderAttributeOptionToDefaultConfirmChangeContent(String name) {
    return '這麼做會讓「$name」變成非預設值';
  }

  @override
  String get orderAttributeValueEmpty => '不影響價錢';

  @override
  String get orderAttributeValueFree => '免費';

  @override
  String get menuTitle => '菜單';

  @override
  String get menuSubtitle => '產品種類、產品';

  @override
  String get menuTutorialTitle => '建立屬於你的菜單';

  @override
  String get menuTutorialContent => '首先我們來開始建立一份菜單吧！';

  @override
  String get menuTutorialCreateExample => '幫助建立一份範例菜單以供測試。';

  @override
  String get menuSearchHint => '搜尋產品、成分、份量';

  @override
  String get menuSearchNotFound => '搜尋不到相關資訊，打錯字了嗎？';

  @override
  String get menuExampleCatalogBurger => '漢堡';

  @override
  String get menuExampleCatalogDrink => '飲品';

  @override
  String get menuExampleCatalogSide => '點心';

  @override
  String get menuExampleCatalogOther => '其他';

  @override
  String get menuExampleProductCheeseBurger => '起司漢堡';

  @override
  String get menuExampleProductVeggieBurger => '蔬菜漢堡';

  @override
  String get menuExampleProductHamBurger => '火腿漢堡';

  @override
  String get menuExampleProductCola => '可樂';

  @override
  String get menuExampleProductCoffee => '咖啡';

  @override
  String get menuExampleProductFries => '薯條';

  @override
  String get menuExampleProductStraw => '吸管';

  @override
  String get menuExampleProductPlasticBag => '塑膠袋';

  @override
  String get menuExampleIngredientCheese => '起司';

  @override
  String get menuExampleIngredientLettuce => '萵苣';

  @override
  String get menuExampleIngredientTomato => '番茄';

  @override
  String get menuExampleIngredientBun => '麵包';

  @override
  String get menuExampleIngredientChili => '辣醬';

  @override
  String get menuExampleIngredientHam => '火腿';

  @override
  String get menuExampleIngredientCola => '可樂';

  @override
  String get menuExampleIngredientCoffee => '濾掛咖啡包';

  @override
  String get menuExampleIngredientFries => '薯條';

  @override
  String get menuExampleIngredientStraw => '吸管';

  @override
  String get menuExampleIngredientPlasticBag => '塑膠袋';

  @override
  String get menuExampleQuantitySmall => '少量';

  @override
  String get menuExampleQuantityLarge => '增量';

  @override
  String get menuExampleQuantityNone => '無';

  @override
  String get menuCatalogEmptyBody =>
      '我們會把相似「產品」放在「產品種類」中，\n到時候點餐會比較方便，例如：\n• 「起司漢堡」、「蔬菜漢堡」整合進「漢堡」\n• 「塑膠袋」、「環保杯」整合進「其他」';

  @override
  String get menuCatalogTitleCreate => '新增產品種類';

  @override
  String get menuCatalogTitleUpdate => '編輯產品種類';

  @override
  String get menuCatalogTitleReorder => '排序產品種類';

  @override
  String menuCatalogDialogDeletionContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '將會一同刪除掉 $count 個產品',
      zero: '其內無任何產品',
    );
    return '$_temp0';
  }

  @override
  String get menuCatalogNameLabel => '產品種類名稱';

  @override
  String get menuCatalogNameHint => '例如：漢堡';

  @override
  String get menuCatalogNameErrorRepeat => '名稱重複了，請改個名字吧！';

  @override
  String get menuCatalogEmptyProducts => '尚未設定產品';

  @override
  String get menuProductHeaderInfo => '產品';

  @override
  String get menuProductEmptyBody => '「產品」是菜單裡的基本單位，例如：\n「起司漢堡」、「可樂」';

  @override
  String get menuProductNotSelected => '請先選擇產品種類';

  @override
  String get menuProductTitleCreate => '新增產品';

  @override
  String get menuProductTitleUpdate => '編輯產品';

  @override
  String get menuProductTitleReorder => '排序產品';

  @override
  String get menuProductTitleUpdateImage => '更新照片';

  @override
  String get menuProductMetaTitle => '產品';

  @override
  String menuProductMetaPrice(num price) {
    final intl.NumberFormat priceNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String priceString = priceNumberFormat.format(price);

    return '價格：$priceString';
  }

  @override
  String menuProductMetaCost(num cost) {
    final intl.NumberFormat costNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String costString = costNumberFormat.format(cost);

    return '成本：$costString';
  }

  @override
  String get menuProductMetaEmpty => '尚未設定成分';

  @override
  String get menuProductNameLabel => '產品名稱';

  @override
  String get menuProductNameHint => '例如：起司漢堡';

  @override
  String get menuProductNameErrorRepeat => '產品名稱重複';

  @override
  String get menuProductPriceLabel => '產品價格';

  @override
  String get menuProductPriceHelper => '訂單頁面會呈現的價錢';

  @override
  String get menuProductCostLabel => '產品成本';

  @override
  String get menuProductCostHelper => '用來算出利潤，理應小於價錢';

  @override
  String get menuProductEmptyIngredients => '尚未設定成分';

  @override
  String get menuIngredientEmptyBody =>
      '你可以在產品中設定成分等資訊，例如：\n「起司漢堡」有「起司」、「麵包」等成分';

  @override
  String get menuIngredientTitleCreate => '新增成分';

  @override
  String get menuIngredientTitleUpdate => '編輯成分';

  @override
  String get menuIngredientTitleReorder => '排序成分';

  @override
  String menuIngredientMetaAmount(num amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '使用量：$amountString';
  }

  @override
  String get menuIngredientSearchLabel => '搜尋成分';

  @override
  String get menuIngredientSearchHelper => '新增成分後，可至「庫存」設定相關資訊。';

  @override
  String get menuIngredientSearchHint => '例如：起司';

  @override
  String menuIngredientSearchAdd(String name) {
    return '新增成分「$name」';
  }

  @override
  String get menuIngredientSearchErrorEmpty => '必須設定成分，請點選以設定。';

  @override
  String get menuIngredientSearchErrorRepeat => '產品已經有相同的成分了，不能重複選取。';

  @override
  String get menuIngredientAmountLabel => '使用量';

  @override
  String get menuIngredientAmountHelper =>
      '預設的使用量，若餐點可以調整該成分的使用量，請於成分的「份量」中設定。';

  @override
  String get menuQuantityTitleCreate => '新增份量';

  @override
  String get menuQuantityTitleUpdate => '編輯';

  @override
  String menuQuantityMetaAmount(num amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '使用量：$amountString';
  }

  @override
  String menuQuantityMetaAdditionalPrice(String price) {
    return '額外售價：$price';
  }

  @override
  String menuQuantityMetaAdditionalCost(String cost) {
    return '額外成本：$cost';
  }

  @override
  String get menuQuantitySearchLabel => '搜尋份量';

  @override
  String get menuQuantitySearchHelper => '新增成分份量後，可至「份量」設定相關資訊。';

  @override
  String get menuQuantitySearchHint => '例如：多量、少量';

  @override
  String menuQuantitySearchAdd(String name) {
    return '新增份量「$name」';
  }

  @override
  String get menuQuantitySearchErrorEmpty => '必須設定份量，請點選以設定。';

  @override
  String get menuQuantitySearchErrorRepeat => '產品已經有相同的份量了，不能重複選取。';

  @override
  String get menuQuantityAmountLabel => '使用量';

  @override
  String get menuQuantityAdditionalPriceLabel => '額外售價';

  @override
  String get menuQuantityAdditionalPriceHelper => '設為 0 則代表加量（減量）不加價。';

  @override
  String get menuQuantityAdditionalCostLabel => '額外成本';

  @override
  String get menuQuantityAdditionalCostHelper =>
      '預額外成本可以為負數，如「少量」會減少成分的使用，相對成本降低。';

  @override
  String get cashierTab => '收銀';

  @override
  String cashierUnitLabel(String unit) {
    return '幣值：$unit';
  }

  @override
  String get cashierCounterLabel => '數量';

  @override
  String get cashierToDefaultTitle => '設為預設';

  @override
  String get cashierToDefaultTutorialTitle => '收銀機預設狀態';

  @override
  String get cashierToDefaultTutorialContent =>
      '在下面設定完收銀機各幣值的數量後，\n按這裡設定預設狀態！\n設定好的數量就會是各個幣值狀態條的「最大值」。';

  @override
  String get cashierToDefaultDialogTitle => '調整收銀臺預設？';

  @override
  String get cashierToDefaultDialogContent =>
      '這將會把目前的收銀機狀態設定為預設狀態。\n此動作將會覆蓋掉先前的設定。';

  @override
  String get cashierChangerTitle => '換錢';

  @override
  String get cashierChangerButton => '套用';

  @override
  String get cashierChangerTutorialTitle => '收銀機換錢';

  @override
  String get cashierChangerTutorialContent => '一百塊換成 10 個十塊之類。\n幫助快速調整收銀機狀態。';

  @override
  String get cashierChangerErrorNoSelection => '請選擇要套用的組合';

  @override
  String cashierChangerErrorNotEnough(String unit) {
    return '$unit 元不夠換';
  }

  @override
  String cashierChangerErrorInvalidHead(int count, String unit) {
    return '$count 個 $unit 元沒辦法換';
  }

  @override
  String cashierChangerErrorInvalidBody(int count, String unit) {
    return '$count 個 $unit 元';
  }

  @override
  String get cashierChangerFavoriteTab => '常用';

  @override
  String get cashierChangerFavoriteHint => '選完後請點選「套用」來使用該組合';

  @override
  String get cashierChangerFavoriteEmptyBody => '這裡可以幫助你快速轉換不同幣值';

  @override
  String cashierChangerFavoriteItemFrom(int count, String unit) {
    return '用 $count 個 $unit 元換';
  }

  @override
  String cashierChangerFavoriteItemTo(int count, String unit) {
    return '$count 個 $unit 元';
  }

  @override
  String get cashierChangerCustomTab => '自訂';

  @override
  String get cashierChangerCustomAddBtn => '新增常用';

  @override
  String get cashierChangerCustomCountLabel => '數量';

  @override
  String get cashierChangerCustomUnitLabel => '幣值';

  @override
  String get cashierChangerCustomUnitAddBtn => '新增幣種';

  @override
  String get cashierChangerCustomDividerFrom => '拿';

  @override
  String get cashierChangerCustomDividerTo => '換';

  @override
  String get cashierSurplusTitle => '結餘';

  @override
  String get cashierSurplusButton => '結餘';

  @override
  String get cashierSurplusTutorialTitle => '每日結餘';

  @override
  String get cashierSurplusTutorialContent =>
      '結餘可以幫助我們在每天打烊時，\n計算現有金額和預設金額的差異。';

  @override
  String get cashierSurplusErrorEmptyDefault => '尚未設定預設狀態';

  @override
  String get cashierSurplusTableHint => '若你確認收銀機的金錢都沒問題之後就可以完成結餘囉！';

  @override
  String cashierSurplusColumnName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'unit': '單位',
        'currentCount': '現有',
        'diffCount': '差異',
        'defaultCount': '預設',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String cashierSurplusCounterLabel(String unit) {
    return '幣值$unit的數量';
  }

  @override
  String get cashierSurplusCounterShortLabel => '數量';

  @override
  String get cashierSurplusCurrentTotalLabel => '現有總額';

  @override
  String get cashierSurplusCurrentTotalHelper =>
      '現在收銀機應該要有的總額。\n若你發現現金和這值對不上，想一想今天有沒有用收銀機的錢買東西？';

  @override
  String get cashierSurplusDiffTotalLabel => '差額';

  @override
  String get cashierSurplusDiffTotalHelper =>
      '和收銀機最一開始的總額的差額。\n這可以快速幫你了解今天收銀機多了多少錢唷。';

  @override
  String get orderTitle => '點餐';

  @override
  String get orderBtn => '點餐';

  @override
  String get orderTutorialTitle => '開始點餐！';

  @override
  String get orderTutorialContent => '一旦設定好菜單，就可以開始點餐囉\n讓我們趕緊進去看看有什麼吧！\n';

  @override
  String get orderTutorialPrinterBtnTitle => '出單機異動';

  @override
  String get orderTutorialPrinterBtnContent => '出單機狀態出現異動，請查看。';

  @override
  String orderSnackbarPrinterConnected(String names) {
    return '出單機連線成功：$names';
  }

  @override
  String orderSnackbarPrinterDisconnected(String name) {
    return '出單機「$name」斷線';
  }

  @override
  String get orderSnackbarCashierNotEnough => '收銀機錢不夠找囉！';

  @override
  String get orderSnackbarCashierUsingSmallMoney => '收銀機使用小錢去找零';

  @override
  String orderSnackbarCashierUsingSmallMoneyHelper(String link) {
    return '找錢給顧客時，收銀機無法使用最適合的錢，就會顯示這個訊息。\n\n例如，售價「65」，消費者支付「100」，此時應找「35」\n如果收銀機只有兩個十元，且有三個以上的五元，就會顯示本訊息。\n\n怎麼避免本提示：\n• 到換錢頁面把各幣值補足。\n• 到[設定頁]($link)關閉收銀機的相關提示。';
  }

  @override
  String get orderActionCheckout => '結帳';

  @override
  String get orderActionExchange => '換錢';

  @override
  String get orderActionStash => '暫存本次點餐';

  @override
  String get orderActionReview => '訂單記錄';

  @override
  String orderLoaderMetaTotalRevenue(String revenue) {
    return '總營收：$revenue';
  }

  @override
  String orderLoaderMetaTotalCost(String cost) {
    return '總成本：$cost';
  }

  @override
  String orderLoaderMetaTotalCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '總數：$countString';
  }

  @override
  String get orderLoaderEmpty => '查無點餐紀錄';

  @override
  String get orderCatalogListEmpty => '尚未設定產品種類';

  @override
  String orderProductListViewHelper(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'grid': '圖片',
        'list': '列表',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get orderProductListNoIngredient => '無設定成分';

  @override
  String get orderPrinterEmpty => '尚未設定出單機';

  @override
  String get orderPrinterDividerUnused => '未使用';

  @override
  String get orderPrinterDividerConnecting => '連線中';

  @override
  String get orderPrinterDividerConnected => '已連線';

  @override
  String get orderPrinterErrorCreateReceipt => '無法產生出單資料';

  @override
  String get orderCartActionBulk => '批量操作';

  @override
  String get orderCartActionToggle => '反選';

  @override
  String get orderCartActionSelectAll => '全選';

  @override
  String get orderCartActionDiscount => '打折';

  @override
  String get orderCartActionDiscountLabel => '折扣';

  @override
  String get orderCartActionDiscountHint => '例如：50，代表打五折（半價）';

  @override
  String get orderCartActionDiscountHelper =>
      '這裡的數字代表「折」，即，85 代表 85 折，總價乘 0.85。若需要準確的價錢請用「變價」。';

  @override
  String get orderCartActionDiscountSuffix => '折';

  @override
  String get orderCartActionChangePrice => '變價';

  @override
  String get orderCartActionChangePriceLabel => '價錢';

  @override
  String get orderCartActionChangePriceHint => '每項產品的價錢';

  @override
  String get orderCartActionChangePricePrefix => '';

  @override
  String get orderCartActionChangePriceSuffix => '元';

  @override
  String get orderCartActionChangeCount => '變更數量';

  @override
  String get orderCartActionChangeCountLabel => '數量';

  @override
  String get orderCartActionChangeCountHint => '產品數量';

  @override
  String get orderCartActionChangeCountSuffix => '個';

  @override
  String get orderCartActionFree => '招待';

  @override
  String get orderCartActionDelete => '刪除';

  @override
  String get orderCartSnapshotEmpty => '尚未點餐';

  @override
  String orderCartMetaTotalPrice(String price) {
    return '總價：$price';
  }

  @override
  String orderCartMetaTotalCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '總數：$countString';
  }

  @override
  String orderCartProductPrice(String price) {
    String _temp0 = intl.Intl.selectLogic(
      price,
      {
        '0': '免費',
        'other': '$price元',
      },
    );
    return '$_temp0';
  }

  @override
  String get orderCartProductIncrease => '數量加一';

  @override
  String get orderCartProductDefaultQuantity => '預設份量';

  @override
  String orderCartProductIngredient(String name, String quantity) {
    return '$name（$quantity）';
  }

  @override
  String orderCartIngredientStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(
      status,
      {
        'emptyCart': '請選擇產品來設定其成分',
        'differentProducts': '請選擇相同的產品來設定其成分',
        'noNeedIngredient': '這個產品沒有可以設定的成分',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get orderCartQuantityNotAble => '請選擇成分來設定份量';

  @override
  String orderCartQuantityLabel(String name, num amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '$name（$amountString）';
  }

  @override
  String orderCartQuantityDefaultLabel(num amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '預設值（$amountString）';
  }

  @override
  String get orderCheckoutEmptyCart => '請先進行點單。';

  @override
  String get orderCheckoutActionStash => '暫存';

  @override
  String get orderCheckoutActionConfirm => '確認';

  @override
  String get orderCheckoutStashTab => '暫存';

  @override
  String get orderCheckoutStashEmpty => '目前無任何暫存餐點。';

  @override
  String get orderCheckoutStashNoProducts => '沒有任何產品';

  @override
  String get orderCheckoutStashActionCheckout => '結帳';

  @override
  String get orderCheckoutStashActionRestore => '還原';

  @override
  String get orderCheckoutStashDialogCalculator => '結帳計算機';

  @override
  String get orderCheckoutStashDialogRestoreTitle => '還原暫存訂單';

  @override
  String get orderCheckoutStashDialogRestoreContent => '此動作將會覆蓋掉現在購物車內的訂單。';

  @override
  String get orderCheckoutStashDialogDeleteName => '訂單';

  @override
  String get orderCheckoutAttributeTab => '顧客設定';

  @override
  String get orderCheckoutAttributeNoteTitle => '備註';

  @override
  String get orderCheckoutAttributeNoteHint => '一些關於此訂單的說明';

  @override
  String get orderCheckoutDetailsTab => '訂單細項';

  @override
  String get orderCheckoutDetailsCalculatorLabelPaid => '付額';

  @override
  String get orderCheckoutDetailsCalculatorLabelChange => '找錢';

  @override
  String orderCheckoutDetailsSnapshotLabelChange(String change) {
    return '找錢：$change';
  }

  @override
  String get orderCheckoutSnackbarPaidFailed => '付額小於訂單總價，無法結帳。';

  @override
  String get orderObjectViewEmpty => '查無點餐紀錄';

  @override
  String get orderObjectViewChange => '找錢';

  @override
  String orderObjectViewPriceTotal(String price) {
    return '訂單總價：$price';
  }

  @override
  String get orderObjectViewPriceProducts => '產品總價';

  @override
  String get orderObjectViewPriceAttributes => '顧客設定總價';

  @override
  String get orderObjectViewCost => '成本';

  @override
  String get orderObjectViewProfit => '淨利';

  @override
  String get orderObjectViewPaid => '付額';

  @override
  String get orderObjectViewNote => '備註';

  @override
  String get orderObjectViewDividerAttribute => '顧客設定';

  @override
  String get orderObjectViewDividerProduct => '產品資訊';

  @override
  String get orderObjectViewProductPrice => '總價';

  @override
  String get orderObjectViewProductCost => '總成本';

  @override
  String get orderObjectViewProductCount => '總數';

  @override
  String get orderObjectViewProductSinglePrice => '單價';

  @override
  String get orderObjectViewProductOriginalPrice => '折扣前單價';

  @override
  String get orderObjectViewProductCatalog => '產品種類';

  @override
  String get orderObjectViewProductIngredient => '成分';

  @override
  String get orderObjectViewProductDefaultQuantity => '預設';

  @override
  String get analysisTab => '統計';

  @override
  String get analysisHistoryBtn => '紀錄';

  @override
  String get analysisHistoryTitle => '訂單記錄';

  @override
  String get analysisHistoryTitleEmpty => '查無點餐紀錄';

  @override
  String get analysisHistoryCalendarTutorialTitle => '日曆';

  @override
  String get analysisHistoryCalendarTutorialContent =>
      '上下滑動可以調整週期單位，如月或週。\n左右滑動可以調整日期起訖。';

  @override
  String get analysisHistoryExportBtn => '匯出';

  @override
  String get analysisHistoryExportTutorialTitle => '訂單資料匯出';

  @override
  String get analysisHistoryExportTutorialContent =>
      '把訂單匯出到外部，讓你可以做進一步分析或保存。\n你可以到「資料轉移」去匯出多日訂單。';

  @override
  String analysisHistoryOrderListMetaId(String id) {
    return '編號：$id';
  }

  @override
  String analysisHistoryOrderListMetaPrice(num price) {
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.compactCurrency(locale: localeName, symbol: '\$');
    final String priceString = priceNumberFormat.format(price);

    return '售價：$priceString';
  }

  @override
  String analysisHistoryOrderListMetaPaid(num paid) {
    final intl.NumberFormat paidNumberFormat =
        intl.NumberFormat.compactCurrency(locale: localeName, symbol: '\$');
    final String paidString = paidNumberFormat.format(paid);

    return '付額：$paidString';
  }

  @override
  String analysisHistoryOrderListMetaProfit(num profit) {
    final intl.NumberFormat profitNumberFormat =
        intl.NumberFormat.compactCurrency(locale: localeName, symbol: '\$');
    final String profitString = profitNumberFormat.format(profit);

    return '淨利：$profitString';
  }

  @override
  String analysisHistoryOrderTitle(String id) {
    return '編號：$id';
  }

  @override
  String get analysisHistoryOrderNotFound => '找不到相關訂單';

  @override
  String analysisHistoryOrderDeleteDialog(String name) {
    return '確定要刪除 $name 的訂單嗎？\n將不會復原收銀機和庫存資料。\n此動作無法復原。';
  }

  @override
  String get analysisGoalsTitle => '本日總結';

  @override
  String get analysisGoalsCountTitle => '訂單數';

  @override
  String get analysisGoalsCountDescription =>
      '訂單數反映了產品對顧客的吸引力。\n它代表了市場對你產品的需求程度，能幫助你了解何種產品或時段最受歡迎。\n高訂單數可能意味著你的定價策略或行銷活動取得成功，是商業模型有效性的指標之一。\n但要注意，單純追求高訂單數可能會忽略盈利能力。';

  @override
  String get analysisGoalsRevenueTitle => '營收';

  @override
  String get analysisGoalsRevenueDescription =>
      '營收代表總銷售額，是業務規模的指標。\n高營收可能顯示了你的產品受歡迎且銷售良好，但營收無法反映出業務的可持續性和盈利能力。\n有時候，為了提高營收，公司可能會採取降價等策略，這可能會對公司的盈利能力造成影響。';

  @override
  String get analysisGoalsProfitTitle => '淨利';

  @override
  String get analysisGoalsProfitDescription =>
      '淨利是營業收入減去營業成本後的餘額，是公司能否持續經營的關鍵。\n盈利直接反映了營運效率和成本管理能力。\n不同於營收，盈利考慮了生意的開支，包括原料成本、人力、租金等，\n這是一個更實際的指標，能幫助你評估經營是否有效且可持續。';

  @override
  String get analysisGoalsCostTitle => '成本';

  @override
  String analysisGoalsAchievedRate(String rate) {
    return '利潤達成\n$rate';
  }

  @override
  String get analysisChartTitle => '圖表分析';

  @override
  String get analysisChartTitleCreate => '新增圖表';

  @override
  String get analysisChartTitleUpdate => '編輯圖表';

  @override
  String get analysisChartTitleReorder => '排序圖表';

  @override
  String get analysisChartTutorialTitle => '圖表分析';

  @override
  String get analysisChartTutorialContent =>
      '透過圖表，你可以更直觀地看到數據變化。\n現在就開始設計圖表追蹤你的銷售狀況吧！。';

  @override
  String get analysisChartCardEmptyData => '沒有資料';

  @override
  String get analysisChartCardTitleUpdate => '編輯圖表';

  @override
  String analysisChartMetricName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'revenue': '營收',
        'cost': '成本',
        'profit': '淨利',
        'count': '數量',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String analysisChartTargetName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'order': '訂單',
        'catalog': '產品種類',
        'product': '產品',
        'ingredient': '成分',
        'attribute': '顧客屬性',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get analysisChartRangeYesterday => '昨天';

  @override
  String get analysisChartRangeToday => '今天';

  @override
  String get analysisChartRangeLastWeek => '上週';

  @override
  String get analysisChartRangeThisWeek => '本週';

  @override
  String get analysisChartRangeLast7Days => '最近7日';

  @override
  String get analysisChartRangeLastMonth => '上月';

  @override
  String get analysisChartRangeThisMonth => '本月';

  @override
  String get analysisChartRangeLast30Days => '最近30日';

  @override
  String analysisChartRangeTabName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'day': '日期',
        'week': '週',
        'month': '月',
        'custom': '自訂',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get analysisChartModalNameLabel => '圖表名稱';

  @override
  String get analysisChartModalNameHint => '例如：每日營收';

  @override
  String get analysisChartModalIgnoreEmptyLabel => '忽略空資料';

  @override
  String get analysisChartModalIgnoreEmptyHelper => '某商品或指標在該時段沒有資料，則不顯示。';

  @override
  String get analysisChartModalDivider => '資料設定';

  @override
  String get analysisChartModalTypeLabel => '圖表類型';

  @override
  String analysisChartModalTypeName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'cartesian': '時序圖',
        'circular': '圓餅圖',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get analysisChartModalMetricLabel => '觀看指標';

  @override
  String get analysisChartModalMetricHelper => '根據不同目的，選擇不同指標類型。';

  @override
  String get analysisChartModalTargetLabel => '項目種類';

  @override
  String get analysisChartModalTargetHelper => '選擇圖表中要針對哪些資訊做分析。';

  @override
  String get analysisChartModalTargetErrorEmpty => '請選擇一個項目種類';

  @override
  String get analysisChartModalTargetItemLabel => '項目選擇';

  @override
  String get analysisChartModalTargetItemHelper => '你想要觀察哪些項目的變化，例如區間內某商品的數量。';

  @override
  String get analysisChartModalTargetItemSelectAll => '全選';
}
