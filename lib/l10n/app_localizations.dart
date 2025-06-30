import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart' deferred as app_localizations_en;
import 'app_localizations_zh.dart' deferred as app_localizations_zh;

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @settingTab.
  ///
  /// In zh, this message translates to:
  /// **'設定'**
  String get settingTab;

  /// Display the app version
  ///
  /// In zh, this message translates to:
  /// **'版本：{version}'**
  String settingVersion(String version);

  /// Display user's name
  ///
  /// In zh, this message translates to:
  /// **'HI，{name}'**
  String settingWelcome(String name);

  /// No description provided for @settingLogoutBtn.
  ///
  /// In zh, this message translates to:
  /// **'登出'**
  String get settingLogoutBtn;

  /// No description provided for @settingElfTitle.
  ///
  /// In zh, this message translates to:
  /// **'建議'**
  String get settingElfTitle;

  /// No description provided for @settingElfDescription.
  ///
  /// In zh, this message translates to:
  /// **'使用 Google 表單提供回饋'**
  String get settingElfDescription;

  /// No description provided for @settingElfContent.
  ///
  /// In zh, this message translates to:
  /// **'覺得這裡還少了什麼嗎？\n歡迎[提供建議](https://forms.gle/R1vZDk9ztQLScUdb9)。\n也可以來看看[排程中的功能](https://github.com/evan361425/flutter-pos-system/milestones)。'**
  String get settingElfContent;

  /// No description provided for @settingFeatureTitle.
  ///
  /// In zh, this message translates to:
  /// **'其他設定'**
  String get settingFeatureTitle;

  /// No description provided for @settingFeatureDescription.
  ///
  /// In zh, this message translates to:
  /// **'外觀、語言、提示'**
  String get settingFeatureDescription;

  /// No description provided for @settingThemeTitle.
  ///
  /// In zh, this message translates to:
  /// **'調色盤'**
  String get settingThemeTitle;

  /// Appearance of the app
  ///
  /// In zh, this message translates to:
  /// **'{name, select, dark{暗色模式} light{日光模式} system{跟隨系統} other{UNKNOWN}}'**
  String settingThemeName(String name);

  /// No description provided for @settingLanguageTitle.
  ///
  /// In zh, this message translates to:
  /// **'語言'**
  String get settingLanguageTitle;

  /// No description provided for @settingCheckoutWarningTitle.
  ///
  /// In zh, this message translates to:
  /// **'收銀機提示'**
  String get settingCheckoutWarningTitle;

  /// Whether to display cash registry warnings
  ///
  /// In zh, this message translates to:
  /// **'{name, select, showAll{全部顯示} onlyNotEnough{僅不夠時顯示} hideAll{全部隱藏} other{UNKNOWN}}'**
  String settingCheckoutWarningName(String name);

  /// No description provided for @settingCheckoutWarningTip.
  ///
  /// In zh, this message translates to:
  /// **'{name, select, showAll{若使用小錢去找，顯示提示。\n例如 5 塊錢不夠了，開始用 5 個 1 塊去找錢} onlyNotEnough{當零錢不夠找的時候，顯示提示。} hideAll{當點餐時，收銀機不會顯示任何提示} other{UNKNOWN}}'**
  String settingCheckoutWarningTip(String name);

  /// Keep the screen on during ordering, even when idle
  ///
  /// In zh, this message translates to:
  /// **'點餐時不關閉螢幕'**
  String get settingOrderAwakeningTitle;

  /// No description provided for @settingOrderAwakeningDescription.
  ///
  /// In zh, this message translates to:
  /// **'若取消，則會根據系統設定時間關閉螢幕'**
  String get settingOrderAwakeningDescription;

  /// No description provided for @settingReportTitle.
  ///
  /// In zh, this message translates to:
  /// **'收集錯誤訊息和事件'**
  String get settingReportTitle;

  /// No description provided for @settingReportDescription.
  ///
  /// In zh, this message translates to:
  /// **'當應用程式發生錯誤時，寄送錯誤訊息，以幫助應用程式成長'**
  String get settingReportDescription;

  /// No description provided for @stockTab.
  ///
  /// In zh, this message translates to:
  /// **'庫存'**
  String get stockTab;

  /// No description provided for @stockUpdatedAt.
  ///
  /// In zh, this message translates to:
  /// **'上次補貨時間：{updatedAt}'**
  String stockUpdatedAt(DateTime updatedAt);

  /// No description provided for @stockIngredientEmptyBody.
  ///
  /// In zh, this message translates to:
  /// **'新增成份後，就可以開始追蹤這些成份的庫存囉！'**
  String get stockIngredientEmptyBody;

  /// No description provided for @stockIngredientTitleCreate.
  ///
  /// In zh, this message translates to:
  /// **'新增成分'**
  String get stockIngredientTitleCreate;

  /// No description provided for @stockIngredientTitleUpdate.
  ///
  /// In zh, this message translates to:
  /// **'編輯成分'**
  String get stockIngredientTitleUpdate;

  /// No description provided for @stockIngredientTitleUpdateAmount.
  ///
  /// In zh, this message translates to:
  /// **'編輯庫存'**
  String get stockIngredientTitleUpdateAmount;

  /// No description provided for @stockIngredientTutorialTitle.
  ///
  /// In zh, this message translates to:
  /// **'新增成分'**
  String get stockIngredientTutorialTitle;

  /// No description provided for @stockIngredientTutorialContent.
  ///
  /// In zh, this message translates to:
  /// **'成份可以幫助我們確認產品的庫存。\n你可以在「產品」中設定成分，然後在這裡設定庫存。'**
  String get stockIngredientTutorialContent;

  /// Indicates how many products will be affected when deleting the ingredient
  ///
  /// In zh, this message translates to:
  /// **'{count, plural, =0{目前無任何產品有本成分} other{將會一同刪除掉 {count} 個產品的成分}}'**
  String stockIngredientDialogDeletionContent(int count);

  /// When editing an ingredient, it indicates how many products are using it and allows for navigation to the product page
  ///
  /// In zh, this message translates to:
  /// **'共有 {count} 個產品使用此成分'**
  String stockIngredientProductsCount(int count);

  /// No description provided for @stockIngredientNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'成分名稱'**
  String get stockIngredientNameLabel;

  /// No description provided for @stockIngredientNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：起司'**
  String get stockIngredientNameHint;

  /// No description provided for @stockIngredientNameErrorRepeat.
  ///
  /// In zh, this message translates to:
  /// **'成分名稱重複'**
  String get stockIngredientNameErrorRepeat;

  /// No description provided for @stockIngredientAmountLabel.
  ///
  /// In zh, this message translates to:
  /// **'現有庫存'**
  String get stockIngredientAmountLabel;

  /// No description provided for @stockIngredientAmountMaxLabel.
  ///
  /// In zh, this message translates to:
  /// **'最大庫存'**
  String get stockIngredientAmountMaxLabel;

  /// No description provided for @stockIngredientAmountMaxHelper.
  ///
  /// In zh, this message translates to:
  /// **'設定這個值可以幫助你一眼看出用了多少成分。\n填空或不填寫則每次增加庫存，都會自動設定這值，'**
  String get stockIngredientAmountMaxHelper;

  /// No description provided for @stockIngredientRestockTitle.
  ///
  /// In zh, this message translates to:
  /// **'每次補貨可以補貨多少成分。\n例如，每 30 份起司要價 100 元，「補貨單位」就填寫 30，「補貨單價」就填寫 100。\n\n這可以幫助你透過價錢快速補貨。'**
  String get stockIngredientRestockTitle;

  /// No description provided for @stockIngredientRestockPriceLabel.
  ///
  /// In zh, this message translates to:
  /// **'補貨單價'**
  String get stockIngredientRestockPriceLabel;

  /// No description provided for @stockIngredientRestockQuantityLabel.
  ///
  /// In zh, this message translates to:
  /// **'補貨單位'**
  String get stockIngredientRestockQuantityLabel;

  /// Headline of the dialog for setting the restock price
  ///
  /// In zh, this message translates to:
  /// **'目前每{quantity}個要價{price}元'**
  String stockIngredientRestockDialogTitle(String quantity, String price);

  /// Helper text to remind users to enter the purchase price
  ///
  /// In zh, this message translates to:
  /// **'請輸入購買價格'**
  String get stockIngredientRestockDialogSubtitle;

  /// No description provided for @stockIngredientRestockDialogQuantityTab.
  ///
  /// In zh, this message translates to:
  /// **'數量'**
  String get stockIngredientRestockDialogQuantityTab;

  /// No description provided for @stockIngredientRestockDialogQuantityBtn.
  ///
  /// In zh, this message translates to:
  /// **'使用數量'**
  String get stockIngredientRestockDialogQuantityBtn;

  /// No description provided for @stockIngredientRestockDialogQuantityLabel.
  ///
  /// In zh, this message translates to:
  /// **'現有庫存'**
  String get stockIngredientRestockDialogQuantityLabel;

  /// Auxiliary text used for quickly increasing inventory
  ///
  /// In zh, this message translates to:
  /// **'若沒有設定最大庫存量，增加本值會重設最大庫存量。'**
  String get stockIngredientRestockDialogQuantityHelper;

  /// No description provided for @stockIngredientRestockDialogPriceTab.
  ///
  /// In zh, this message translates to:
  /// **'價格'**
  String get stockIngredientRestockDialogPriceTab;

  /// No description provided for @stockIngredientRestockDialogPriceBtn.
  ///
  /// In zh, this message translates to:
  /// **'使用價錢'**
  String get stockIngredientRestockDialogPriceBtn;

  /// No description provided for @stockIngredientRestockDialogPriceLabel.
  ///
  /// In zh, this message translates to:
  /// **'補貨價格'**
  String get stockIngredientRestockDialogPriceLabel;

  /// No description provided for @stockIngredientRestockDialogPriceEmptyBody.
  ///
  /// In zh, this message translates to:
  /// **'趕緊設定單價，讓你可以利用補貨的金額直接算出補貨的量。'**
  String get stockIngredientRestockDialogPriceEmptyBody;

  /// The original amount before the restock
  ///
  /// In zh, this message translates to:
  /// **'原始庫存'**
  String get stockIngredientRestockDialogPriceOldAmount;

  /// No description provided for @stockReplenishmentButton.
  ///
  /// In zh, this message translates to:
  /// **'採購'**
  String get stockReplenishmentButton;

  /// No description provided for @stockReplenishmentEmptyBody.
  ///
  /// In zh, this message translates to:
  /// **'採購可以幫你快速調整成分的庫存'**
  String get stockReplenishmentEmptyBody;

  /// No description provided for @stockReplenishmentTitleList.
  ///
  /// In zh, this message translates to:
  /// **'採購列表'**
  String get stockReplenishmentTitleList;

  /// No description provided for @stockReplenishmentTitleCreate.
  ///
  /// In zh, this message translates to:
  /// **'新增採購'**
  String get stockReplenishmentTitleCreate;

  /// No description provided for @stockReplenishmentTitleUpdate.
  ///
  /// In zh, this message translates to:
  /// **'編輯採購'**
  String get stockReplenishmentTitleUpdate;

  /// Indicates in the replenishment list how many ingredients are affected
  ///
  /// In zh, this message translates to:
  /// **'會影響 {count} 項成分'**
  String stockReplenishmentMetaAffect(int count);

  /// The stock page displays the last replenishment time; if never replenished, this text is set
  ///
  /// In zh, this message translates to:
  /// **'尚未補貨過'**
  String get stockReplenishmentNever;

  /// No description provided for @stockReplenishmentApplyPreview.
  ///
  /// In zh, this message translates to:
  /// **'預覽'**
  String get stockReplenishmentApplyPreview;

  /// No description provided for @stockReplenishmentApplyConfirmButton.
  ///
  /// In zh, this message translates to:
  /// **'套用'**
  String get stockReplenishmentApplyConfirmButton;

  /// No description provided for @stockReplenishmentApplyConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'套用採購？'**
  String get stockReplenishmentApplyConfirmTitle;

  /// No description provided for @stockReplenishmentApplyConfirmColumn.
  ///
  /// In zh, this message translates to:
  /// **'{value, select, name{名稱} amount{數量} other{UNKNOWN}}'**
  String stockReplenishmentApplyConfirmColumn(String value);

  /// No description provided for @stockReplenishmentApplyConfirmHint.
  ///
  /// In zh, this message translates to:
  /// **'選擇套用後，將會影響以下成分的庫存'**
  String get stockReplenishmentApplyConfirmHint;

  /// No description provided for @stockReplenishmentTutorialTitle.
  ///
  /// In zh, this message translates to:
  /// **'成份採購'**
  String get stockReplenishmentTutorialTitle;

  /// No description provided for @stockReplenishmentTutorialContent.
  ///
  /// In zh, this message translates to:
  /// **'透過採購，你不再需要一個一個去設定成分的庫存。\n馬上設定採購，一次調整多個成份吧！'**
  String get stockReplenishmentTutorialContent;

  /// No description provided for @stockReplenishmentNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'採購名稱'**
  String get stockReplenishmentNameLabel;

  /// No description provided for @stockReplenishmentNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：Costco 採購'**
  String get stockReplenishmentNameHint;

  /// No description provided for @stockReplenishmentNameErrorRepeat.
  ///
  /// In zh, this message translates to:
  /// **'採購名稱重複'**
  String get stockReplenishmentNameErrorRepeat;

  /// No description provided for @stockReplenishmentIngredientsDivider.
  ///
  /// In zh, this message translates to:
  /// **'成分'**
  String get stockReplenishmentIngredientsDivider;

  /// No description provided for @stockReplenishmentIngredientsHelper.
  ///
  /// In zh, this message translates to:
  /// **'點選以設定不同成分欲採購的量'**
  String get stockReplenishmentIngredientsHelper;

  /// No description provided for @stockReplenishmentIngredientAmountHint.
  ///
  /// In zh, this message translates to:
  /// **'設定增加／減少的量'**
  String get stockReplenishmentIngredientAmountHint;

  /// No description provided for @stockQuantityTitle.
  ///
  /// In zh, this message translates to:
  /// **'份量'**
  String get stockQuantityTitle;

  /// No description provided for @stockQuantityDescription.
  ///
  /// In zh, this message translates to:
  /// **'半糖、微糖等'**
  String get stockQuantityDescription;

  /// No description provided for @stockQuantityTitleCreate.
  ///
  /// In zh, this message translates to:
  /// **'新增份量'**
  String get stockQuantityTitleCreate;

  /// No description provided for @stockQuantityTitleUpdate.
  ///
  /// In zh, this message translates to:
  /// **'編輯份量'**
  String get stockQuantityTitleUpdate;

  /// No description provided for @stockQuantityEmptyBody.
  ///
  /// In zh, this message translates to:
  /// **'份量可以快速調整成分的量，例如：\n半糖、微糖。'**
  String get stockQuantityEmptyBody;

  /// Text explaining default ratios in subheadings of quantity items
  ///
  /// In zh, this message translates to:
  /// **'預設比例：{proportion}'**
  String stockQuantityMetaProportion(num proportion);

  /// Indicates how many product ingredients will be affected when deleting the quantity
  ///
  /// In zh, this message translates to:
  /// **'{count, plural, =0{目前無任何產品成分有本份量} other{將會一同刪除掉 {count} 個產品成分的份量\'}}'**
  String stockQuantityDialogDeletionContent(int count);

  /// No description provided for @stockQuantityNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'份量名稱'**
  String get stockQuantityNameLabel;

  /// No description provided for @stockQuantityNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：少量或多量'**
  String get stockQuantityNameHint;

  /// No description provided for @stockQuantityNameErrorRepeat.
  ///
  /// In zh, this message translates to:
  /// **'份量名稱重複'**
  String get stockQuantityNameErrorRepeat;

  /// No description provided for @stockQuantityProportionLabel.
  ///
  /// In zh, this message translates to:
  /// **'預設比例'**
  String get stockQuantityProportionLabel;

  /// No description provided for @stockQuantityProportionHelper.
  ///
  /// In zh, this message translates to:
  /// **'當產品成分使用此份量時，預設替該成分增加的比例。\n\n例如：此份量為「多量」預設份量為「1.5」，\n今有一產品「起司漢堡」的成分「起司」，每份漢堡會使用「2」單位的起司，\n當增加此份量時，則會自動替「起司」設定為「3」（2 * 1.5）的份量。\n\n若設為「1」則無任何影響。\n\n若設為「0」則代表將不會使用此成分'**
  String get stockQuantityProportionHelper;

  /// No description provided for @printerTitle.
  ///
  /// In zh, this message translates to:
  /// **'出單機管理'**
  String get printerTitle;

  /// No description provided for @printerDescription.
  ///
  /// In zh, this message translates to:
  /// **'藍牙連線、出單設定'**
  String get printerDescription;

  /// Displayed on the upper in mobile view
  ///
  /// In zh, this message translates to:
  /// **'出單機'**
  String get printerHeaderInfo;

  /// No description provided for @printerTitleCreate.
  ///
  /// In zh, this message translates to:
  /// **'新增出單機'**
  String get printerTitleCreate;

  /// No description provided for @printerTitleUpdate.
  ///
  /// In zh, this message translates to:
  /// **'編輯出單機'**
  String get printerTitleUpdate;

  /// No description provided for @printerTitleSettings.
  ///
  /// In zh, this message translates to:
  /// **'設定格式'**
  String get printerTitleSettings;

  /// No description provided for @printerBtnConnect.
  ///
  /// In zh, this message translates to:
  /// **'建立連線'**
  String get printerBtnConnect;

  /// No description provided for @printerBtnDisconnect.
  ///
  /// In zh, this message translates to:
  /// **'中斷連線'**
  String get printerBtnDisconnect;

  /// No description provided for @printerBtnTestPrint.
  ///
  /// In zh, this message translates to:
  /// **'列印測試'**
  String get printerBtnTestPrint;

  /// No description provided for @printerBtnRetry.
  ///
  /// In zh, this message translates to:
  /// **'重新連線'**
  String get printerBtnRetry;

  /// No description provided for @printerBtnPrint.
  ///
  /// In zh, this message translates to:
  /// **'列印'**
  String get printerBtnPrint;

  /// No description provided for @printerStatusSuccess.
  ///
  /// In zh, this message translates to:
  /// **'成功連結出單機'**
  String get printerStatusSuccess;

  /// No description provided for @printerStatusConnecting.
  ///
  /// In zh, this message translates to:
  /// **'連線中'**
  String get printerStatusConnecting;

  /// No description provided for @printerStatusStandby.
  ///
  /// In zh, this message translates to:
  /// **'尚未進行連線'**
  String get printerStatusStandby;

  /// No description provided for @printerStatusPrinted.
  ///
  /// In zh, this message translates to:
  /// **'列印完成'**
  String get printerStatusPrinted;

  /// No description provided for @printerStatusName.
  ///
  /// In zh, this message translates to:
  /// **'{name, select, good{正常} writeFailed{上次列印失敗} paperNotFound{缺紙} tooHot{出單機過熱} lowBattery{電量不足} printing{列印中} unknown{未知} other{UNKNOWN}}'**
  String printerStatusName(String name);

  /// No description provided for @printerSignalName.
  ///
  /// In zh, this message translates to:
  /// **'{name, select, good{良好} normal{一般} weak{微弱} other{UNKNOWN}}'**
  String printerSignalName(String name);

  /// No description provided for @printerScanIng.
  ///
  /// In zh, this message translates to:
  /// **'搜尋藍牙設備中...'**
  String get printerScanIng;

  /// No description provided for @printerScanCount.
  ///
  /// In zh, this message translates to:
  /// **'搜尋到 {count} 個裝置'**
  String printerScanCount(int count);

  /// No description provided for @printerScanRetry.
  ///
  /// In zh, this message translates to:
  /// **'重新搜尋'**
  String get printerScanRetry;

  /// No description provided for @printerScanNotFound.
  ///
  /// In zh, this message translates to:
  /// **'找不到裝置？'**
  String get printerScanNotFound;

  /// No description provided for @printerErrorNotSelect.
  ///
  /// In zh, this message translates to:
  /// **'尚未選擇裝置'**
  String get printerErrorNotSelect;

  /// No description provided for @printerErrorNotSupportTitle.
  ///
  /// In zh, this message translates to:
  /// **'裝置不相容'**
  String get printerErrorNotSupportTitle;

  /// No description provided for @printerErrorNotSupportContent.
  ///
  /// In zh, this message translates to:
  /// **'目前尚未支援此裝置，你可以[聯絡我們](mailto:evanlu361425@gmail.com)以取得協助。'**
  String get printerErrorNotSupportContent;

  /// No description provided for @printerErrorBluetoothOff.
  ///
  /// In zh, this message translates to:
  /// **'藍牙未開啟'**
  String get printerErrorBluetoothOff;

  /// No description provided for @printerErrorDisconnected.
  ///
  /// In zh, this message translates to:
  /// **'出單機已斷線'**
  String get printerErrorDisconnected;

  /// No description provided for @printerErrorTimeout.
  ///
  /// In zh, this message translates to:
  /// **'出單機連線逾時'**
  String get printerErrorTimeout;

  /// No description provided for @printerErrorCanceled.
  ///
  /// In zh, this message translates to:
  /// **'出單機連線請求被中斷'**
  String get printerErrorCanceled;

  /// No description provided for @printerErrorTimeoutMore.
  ///
  /// In zh, this message translates to:
  /// **'可以嘗試以下操作：\n• 確認裝置是否開啟（通常裝置會閃爍）\n• 確認裝置是否在範圍內\n• 重新開啟藍牙'**
  String get printerErrorTimeoutMore;

  /// No description provided for @printerNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'出單機名稱'**
  String get printerNameLabel;

  /// No description provided for @printerNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：廚房的出單機'**
  String get printerNameHint;

  /// No description provided for @printerNameHelper.
  ///
  /// In zh, this message translates to:
  /// **'位置：{address}'**
  String printerNameHelper(String address);

  /// No description provided for @printerAutoConnLabel.
  ///
  /// In zh, this message translates to:
  /// **'自動連線'**
  String get printerAutoConnLabel;

  /// No description provided for @printerAutoConnHelper.
  ///
  /// In zh, this message translates to:
  /// **'當進入訂單頁時自動連線'**
  String get printerAutoConnHelper;

  /// No description provided for @printerMetaConnected.
  ///
  /// In zh, this message translates to:
  /// **'已連線'**
  String get printerMetaConnected;

  /// No description provided for @printerMetaExist.
  ///
  /// In zh, this message translates to:
  /// **'已建立，無法新增'**
  String get printerMetaExist;

  /// No description provided for @printerMetaHelper.
  ///
  /// In zh, this message translates to:
  /// **'打開藍牙並確保出單機就在你旁邊'**
  String get printerMetaHelper;

  /// No description provided for @printerSettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'設定出單機格式'**
  String get printerSettingsTitle;

  /// No description provided for @printerSettingsPaddingLabel.
  ///
  /// In zh, this message translates to:
  /// **'窄間距'**
  String get printerSettingsPaddingLabel;

  /// No description provided for @printerSettingsPaddingHelper.
  ///
  /// In zh, this message translates to:
  /// **'單子跟單子之間的空白會變少，較省紙張，但是撕紙時要小心'**
  String get printerSettingsPaddingHelper;

  /// No description provided for @printerSettingsMore.
  ///
  /// In zh, this message translates to:
  /// **'其他更多設定，敬請期待！'**
  String get printerSettingsMore;

  /// No description provided for @printerReceiptTitle.
  ///
  /// In zh, this message translates to:
  /// **'交易明細'**
  String get printerReceiptTitle;

  /// No description provided for @printerReceiptColumnName.
  ///
  /// In zh, this message translates to:
  /// **'品項'**
  String get printerReceiptColumnName;

  /// No description provided for @printerReceiptColumnPrice.
  ///
  /// In zh, this message translates to:
  /// **'單價'**
  String get printerReceiptColumnPrice;

  /// No description provided for @printerReceiptColumnCount.
  ///
  /// In zh, this message translates to:
  /// **'數量'**
  String get printerReceiptColumnCount;

  /// No description provided for @printerReceiptColumnTotal.
  ///
  /// In zh, this message translates to:
  /// **'小計'**
  String get printerReceiptColumnTotal;

  /// No description provided for @printerReceiptColumnTime.
  ///
  /// In zh, this message translates to:
  /// **'時間'**
  String get printerReceiptColumnTime;

  /// No description provided for @printerReceiptDiscountLabel.
  ///
  /// In zh, this message translates to:
  /// **'折扣'**
  String get printerReceiptDiscountLabel;

  /// No description provided for @printerReceiptDiscountOrigin.
  ///
  /// In zh, this message translates to:
  /// **'原單價'**
  String get printerReceiptDiscountOrigin;

  /// No description provided for @printerReceiptAddOnsLabel.
  ///
  /// In zh, this message translates to:
  /// **'附加'**
  String get printerReceiptAddOnsLabel;

  /// No description provided for @printerReceiptAddOnsAdjustment.
  ///
  /// In zh, this message translates to:
  /// **'調整金額'**
  String get printerReceiptAddOnsAdjustment;

  /// No description provided for @printerReceiptTotal.
  ///
  /// In zh, this message translates to:
  /// **'總價'**
  String get printerReceiptTotal;

  /// No description provided for @printerReceiptPaid.
  ///
  /// In zh, this message translates to:
  /// **'付額'**
  String get printerReceiptPaid;

  /// No description provided for @printerReceiptPrice.
  ///
  /// In zh, this message translates to:
  /// **'總價'**
  String get printerReceiptPrice;

  /// No description provided for @printerReceiptChange.
  ///
  /// In zh, this message translates to:
  /// **'找錢'**
  String get printerReceiptChange;

  /// No description provided for @printerInfoTitle.
  ///
  /// In zh, this message translates to:
  /// **'出單機資訊'**
  String get printerInfoTitle;

  /// No description provided for @printerInfoName.
  ///
  /// In zh, this message translates to:
  /// **'名稱'**
  String get printerInfoName;

  /// No description provided for @printerInfoAddress.
  ///
  /// In zh, this message translates to:
  /// **'位置'**
  String get printerInfoAddress;

  /// No description provided for @printerInfoSignal.
  ///
  /// In zh, this message translates to:
  /// **'訊號強度'**
  String get printerInfoSignal;

  /// No description provided for @printerInfoStatus.
  ///
  /// In zh, this message translates to:
  /// **'狀態'**
  String get printerInfoStatus;

  /// No description provided for @transitTitle.
  ///
  /// In zh, this message translates to:
  /// **'資料轉移'**
  String get transitTitle;

  /// No description provided for @transitDescription.
  ///
  /// In zh, this message translates to:
  /// **'匯入、匯出店家資訊和訂單'**
  String get transitDescription;

  /// No description provided for @transitDescriptionCsv.
  ///
  /// In zh, this message translates to:
  /// **'用逗號分隔的列表，輕量級的匯出和匯入資料，幾乎兼容所有軟體。'**
  String get transitDescriptionCsv;

  /// No description provided for @transitDescriptionExcel.
  ///
  /// In zh, this message translates to:
  /// **'Excel 可以離線匯出和匯入，容易與 Google 試算表和 Microsoft Excel 整合。'**
  String get transitDescriptionExcel;

  /// No description provided for @transitDescriptionGoogleSheet.
  ///
  /// In zh, this message translates to:
  /// **'Google 試算表是一個強大的小型資料庫，匯出之後可以做很多客制化的分析！'**
  String get transitDescriptionGoogleSheet;

  /// No description provided for @transitDescriptionPlainText.
  ///
  /// In zh, this message translates to:
  /// **'快速檢查、快速分享。'**
  String get transitDescriptionPlainText;

  /// No description provided for @transitMethodTitle.
  ///
  /// In zh, this message translates to:
  /// **'請選擇欲轉移的方式'**
  String get transitMethodTitle;

  /// No description provided for @transitMethodName.
  ///
  /// In zh, this message translates to:
  /// **'{name, select, googleSheet{Google 試算表} plainText{純文字} excel{Excel 檔案} csv{CSV 檔案} other{UNKNOWN}}'**
  String transitMethodName(String name);

  /// No description provided for @transitCatalogTitle.
  ///
  /// In zh, this message translates to:
  /// **'用 {name} 做什麼？'**
  String transitCatalogTitle(Object name);

  /// No description provided for @transitCatalogName.
  ///
  /// In zh, this message translates to:
  /// **'{name, select, exportOrder{匯出訂單記錄} exportModel{匯出店家資訊} importModel{匯入店家資訊} other{UNKNOWN}}'**
  String transitCatalogName(String name);

  /// No description provided for @transitCatalogHelper.
  ///
  /// In zh, this message translates to:
  /// **'{name, select, exportOrder{訂單資訊可以讓你匯出到第三方位置後做更細緻的統計分析。} exportModel{商家資訊是用來把菜單、庫存等資訊備份到第三方位置。} importModel{同步資訊到此設備。} other{UNKNOWN}}'**
  String transitCatalogHelper(String name);

  /// No description provided for @transitModelName.
  ///
  /// In zh, this message translates to:
  /// **'{name, select, menu{菜單} stock{庫存} quantities{份量} replenisher{補貨} orderAttr{顧客設定} other{UNKNOWN}}'**
  String transitModelName(String name);

  /// No description provided for @transitOrderName.
  ///
  /// In zh, this message translates to:
  /// **'{name, select, basic{訂單} attr{顧客細項} product{產品細項} ingredient{成分細項} other{UNKNOWN}}'**
  String transitOrderName(String name);

  /// No description provided for @transitOrderSettingTitle.
  ///
  /// In zh, this message translates to:
  /// **'訂單匯出設定'**
  String get transitOrderSettingTitle;

  /// No description provided for @transitOrderSettingMetaOverwrite.
  ///
  /// In zh, this message translates to:
  /// **'{value, select, true{會覆寫} false{不會覆寫} other{UNKNOWN}}'**
  String transitOrderSettingMetaOverwrite(String value);

  /// No description provided for @transitOrderSettingMetaTitlePrefix.
  ///
  /// In zh, this message translates to:
  /// **'{value, select, true{有日期前綴} false{無日期前綴} other{UNKNOWN}}'**
  String transitOrderSettingMetaTitlePrefix(String value);

  /// No description provided for @transitOrderSettingOverwriteLabel.
  ///
  /// In zh, this message translates to:
  /// **'是否覆寫表單'**
  String get transitOrderSettingOverwriteLabel;

  /// No description provided for @transitOrderSettingOverwriteHint.
  ///
  /// In zh, this message translates to:
  /// **'覆寫表單之後，將會從第一行開始匯出'**
  String get transitOrderSettingOverwriteHint;

  /// No description provided for @transitOrderSettingTitlePrefixLabel.
  ///
  /// In zh, this message translates to:
  /// **'加上日期前綴'**
  String get transitOrderSettingTitlePrefixLabel;

  /// No description provided for @transitOrderSettingTitlePrefixHint.
  ///
  /// In zh, this message translates to:
  /// **'表單名稱前面加上日期前綴，例如：「0101 - 0131 訂單資料」'**
  String get transitOrderSettingTitlePrefixHint;

  /// No description provided for @transitOrderSettingRecommendCombination.
  ///
  /// In zh, this message translates to:
  /// **'不覆寫而改用附加的時候，建議表單名稱「不要」加上日期前綴'**
  String get transitOrderSettingRecommendCombination;

  /// No description provided for @transitOrderMetaRange.
  ///
  /// In zh, this message translates to:
  /// **'{range} 的訂單'**
  String transitOrderMetaRange(String range);

  /// No description provided for @transitOrderMetaRangeDays.
  ///
  /// In zh, this message translates to:
  /// **'{days} 天的資料'**
  String transitOrderMetaRangeDays(int days);

  /// No description provided for @transitOrderCapacityTitle.
  ///
  /// In zh, this message translates to:
  /// **'預估容量為：{size}'**
  String transitOrderCapacityTitle(Object size);

  /// No description provided for @transitOrderCapacityContent.
  ///
  /// In zh, this message translates to:
  /// **'過高的容量可能會讓執行錯誤，建議分次執行，不要一次匯出太多筆。'**
  String get transitOrderCapacityContent;

  /// No description provided for @transitOrderCapacityOk.
  ///
  /// In zh, this message translates to:
  /// **'容量剛好'**
  String get transitOrderCapacityOk;

  /// No description provided for @transitOrderCapacityWarn.
  ///
  /// In zh, this message translates to:
  /// **'容量警告'**
  String get transitOrderCapacityWarn;

  /// No description provided for @transitOrderCapacityDanger.
  ///
  /// In zh, this message translates to:
  /// **'容量危險'**
  String get transitOrderCapacityDanger;

  /// No description provided for @transitOrderItemTitle.
  ///
  /// In zh, this message translates to:
  /// **'{date}'**
  String transitOrderItemTitle(DateTime date);

  /// No description provided for @transitOrderItemMetaProductCount.
  ///
  /// In zh, this message translates to:
  /// **'餐點數：{count}'**
  String transitOrderItemMetaProductCount(int count);

  /// No description provided for @transitOrderItemMetaPrice.
  ///
  /// In zh, this message translates to:
  /// **'總價：{price}'**
  String transitOrderItemMetaPrice(String price);

  /// No description provided for @transitOrderItemDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'訂單細節'**
  String get transitOrderItemDialogTitle;

  /// No description provided for @transitExportTab.
  ///
  /// In zh, this message translates to:
  /// **'匯出'**
  String get transitExportTab;

  /// No description provided for @transitExportFileDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'選擇匯出的位置'**
  String get transitExportFileDialogTitle;

  /// No description provided for @transitExportBasicBtnCsv.
  ///
  /// In zh, this message translates to:
  /// **'匯出成 CSV 檔'**
  String get transitExportBasicBtnCsv;

  /// No description provided for @transitExportBasicBtnExcel.
  ///
  /// In zh, this message translates to:
  /// **'匯出成 Excel 檔'**
  String get transitExportBasicBtnExcel;

  /// No description provided for @transitExportBasicBtnGoogleSheet.
  ///
  /// In zh, this message translates to:
  /// **'匯出至 Google 試算表'**
  String get transitExportBasicBtnGoogleSheet;

  /// No description provided for @transitExportBasicBtnPlainText.
  ///
  /// In zh, this message translates to:
  /// **'純文字拷貝'**
  String get transitExportBasicBtnPlainText;

  /// No description provided for @transitExportBasicFileName.
  ///
  /// In zh, this message translates to:
  /// **'POS 系統資料'**
  String get transitExportBasicFileName;

  /// No description provided for @transitExportBasicSuccessCsv.
  ///
  /// In zh, this message translates to:
  /// **'匯出成功'**
  String get transitExportBasicSuccessCsv;

  /// No description provided for @transitExportBasicSuccessExcel.
  ///
  /// In zh, this message translates to:
  /// **'匯出成功'**
  String get transitExportBasicSuccessExcel;

  /// No description provided for @transitExportBasicSuccessGoogleSheet.
  ///
  /// In zh, this message translates to:
  /// **'上傳成功'**
  String get transitExportBasicSuccessGoogleSheet;

  /// No description provided for @transitExportBasicSuccessPlainText.
  ///
  /// In zh, this message translates to:
  /// **'拷貝成功'**
  String get transitExportBasicSuccessPlainText;

  /// No description provided for @transitExportBasicSuccessActionGoogleSheet.
  ///
  /// In zh, this message translates to:
  /// **'開啟表單'**
  String get transitExportBasicSuccessActionGoogleSheet;

  /// No description provided for @transitExportOrderTitleCsv.
  ///
  /// In zh, this message translates to:
  /// **'匯出成 CSV 檔'**
  String get transitExportOrderTitleCsv;

  /// No description provided for @transitExportOrderTitleExcel.
  ///
  /// In zh, this message translates to:
  /// **'匯出成 Excel 檔'**
  String get transitExportOrderTitleExcel;

  /// No description provided for @transitExportOrderTitleGoogleSheet.
  ///
  /// In zh, this message translates to:
  /// **'匯出至 Google 試算表'**
  String get transitExportOrderTitleGoogleSheet;

  /// No description provided for @transitExportOrderTitlePlainText.
  ///
  /// In zh, this message translates to:
  /// **'純文字拷貝'**
  String get transitExportOrderTitlePlainText;

  /// No description provided for @transitExportOrderSubtitleCsv.
  ///
  /// In zh, this message translates to:
  /// **'會有多個檔案，每個檔案包含不同的資料'**
  String get transitExportOrderSubtitleCsv;

  /// No description provided for @transitExportOrderSubtitleExcel.
  ///
  /// In zh, this message translates to:
  /// **'單一檔案內含工作表，每個工作表包含不同的資料'**
  String get transitExportOrderSubtitleExcel;

  /// No description provided for @transitExportOrderSubtitleGoogleSheet.
  ///
  /// In zh, this message translates to:
  /// **'上傳需要網路連線，且請求可能會被 Google 限制。\n若上傳失敗，請稍後再試或使用其他方式匯出。\n'**
  String get transitExportOrderSubtitleGoogleSheet;

  /// No description provided for @transitExportOrderSubtitlePlainText.
  ///
  /// In zh, this message translates to:
  /// **'適合用來簡單的分享或檢查資料'**
  String get transitExportOrderSubtitlePlainText;

  /// No description provided for @transitExportOrderFileName.
  ///
  /// In zh, this message translates to:
  /// **'訂單資料'**
  String get transitExportOrderFileName;

  /// No description provided for @transitExportOrderProgressGoogleSheetOverwrite.
  ///
  /// In zh, this message translates to:
  /// **'資料覆寫中'**
  String get transitExportOrderProgressGoogleSheetOverwrite;

  /// No description provided for @transitExportOrderProgressGoogleSheetAppend.
  ///
  /// In zh, this message translates to:
  /// **'資料附加進既有資料中'**
  String get transitExportOrderProgressGoogleSheetAppend;

  /// No description provided for @transitExportOrderWarningMemoryGoogleSheet.
  ///
  /// In zh, this message translates to:
  /// **'這裡的容量代表網路傳輸所消耗的量，實際佔用的雲端記憶體可能是此值的百分之一而已。\n詳細容量限制說明可以參考[本文件](https://developers.google.com/sheets/api/limits#quota)。\n'**
  String get transitExportOrderWarningMemoryGoogleSheet;

  /// No description provided for @transitExportOrderSuccessCsv.
  ///
  /// In zh, this message translates to:
  /// **'匯出成功'**
  String get transitExportOrderSuccessCsv;

  /// No description provided for @transitExportOrderSuccessExcel.
  ///
  /// In zh, this message translates to:
  /// **'匯出成功'**
  String get transitExportOrderSuccessExcel;

  /// No description provided for @transitExportOrderSuccessGoogleSheet.
  ///
  /// In zh, this message translates to:
  /// **'上傳成功'**
  String get transitExportOrderSuccessGoogleSheet;

  /// No description provided for @transitExportOrderSuccessPlainText.
  ///
  /// In zh, this message translates to:
  /// **'拷貝成功'**
  String get transitExportOrderSuccessPlainText;

  /// No description provided for @transitExportOrderSuccessActionGoogleSheet.
  ///
  /// In zh, this message translates to:
  /// **'開啟表單'**
  String get transitExportOrderSuccessActionGoogleSheet;

  /// No description provided for @transitImportTab.
  ///
  /// In zh, this message translates to:
  /// **'匯入'**
  String get transitImportTab;

  /// No description provided for @transitImportBtnCsv.
  ///
  /// In zh, this message translates to:
  /// **'選擇 .csv 檔'**
  String get transitImportBtnCsv;

  /// No description provided for @transitImportBtnExcel.
  ///
  /// In zh, this message translates to:
  /// **'選擇 .xlsx 檔'**
  String get transitImportBtnExcel;

  /// No description provided for @transitImportBtnGoogleSheet.
  ///
  /// In zh, this message translates to:
  /// **'選擇 Google 試算表'**
  String get transitImportBtnGoogleSheet;

  /// No description provided for @transitImportBtnPlainTextAction.
  ///
  /// In zh, this message translates to:
  /// **'點選以貼上文字'**
  String get transitImportBtnPlainTextAction;

  /// No description provided for @transitImportBtnPlainTextHint.
  ///
  /// In zh, this message translates to:
  /// **'貼上複製而來的文字'**
  String get transitImportBtnPlainTextHint;

  /// No description provided for @transitImportBtnPlainTextHelper.
  ///
  /// In zh, this message translates to:
  /// **'貼上文字後，會分析文字並決定匯入的是什麼種類的資訊。\n複製過大的文字可能會造成系統的崩潰。\n'**
  String get transitImportBtnPlainTextHelper;

  /// No description provided for @transitImportModelSelectionLabel.
  ///
  /// In zh, this message translates to:
  /// **'資料類型'**
  String get transitImportModelSelectionLabel;

  /// No description provided for @transitImportModelSelectionAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get transitImportModelSelectionAll;

  /// No description provided for @transitImportModelSelectionHint.
  ///
  /// In zh, this message translates to:
  /// **'請先選擇資料類型來進行匯入'**
  String get transitImportModelSelectionHint;

  /// No description provided for @transitImportModelSelectionPlainTextHint.
  ///
  /// In zh, this message translates to:
  /// **'請先輸入文字來進行匯入'**
  String get transitImportModelSelectionPlainTextHint;

  /// No description provided for @transitImportProgressGoogleSheetStart.
  ///
  /// In zh, this message translates to:
  /// **'拉取試算表資料中'**
  String get transitImportProgressGoogleSheetStart;

  /// No description provided for @transitImportProgressGoogleSheetPrepare.
  ///
  /// In zh, this message translates to:
  /// **'取得試算表資訊中'**
  String get transitImportProgressGoogleSheetPrepare;

  /// No description provided for @transitImportErrorBasicColumnCount.
  ///
  /// In zh, this message translates to:
  /// **'資料量不足，需要 {columns} 個欄位'**
  String transitImportErrorBasicColumnCount(int columns);

  /// No description provided for @transitImportErrorBasicDuplicate.
  ///
  /// In zh, this message translates to:
  /// **'將忽略本行，相同的項目已於前面出現'**
  String get transitImportErrorBasicDuplicate;

  /// No description provided for @transitImportErrorCsvPickFile.
  ///
  /// In zh, this message translates to:
  /// **'選擇檔案失敗'**
  String get transitImportErrorCsvPickFile;

  /// No description provided for @transitImportErrorExcelPickFile.
  ///
  /// In zh, this message translates to:
  /// **'選擇檔案失敗'**
  String get transitImportErrorExcelPickFile;

  /// No description provided for @transitImportErrorGoogleSheetFetchDataTitle.
  ///
  /// In zh, this message translates to:
  /// **'無法拉取試算表資料'**
  String get transitImportErrorGoogleSheetFetchDataTitle;

  /// No description provided for @transitImportErrorGoogleSheetFetchDataHelper.
  ///
  /// In zh, this message translates to:
  /// **'別擔心，通常都可以簡單解決！\n可能的原因有：\n• 網路狀況不穩；\n• 尚未授權 POS 系統進行表單的讀取；\n• 試算表 ID 打錯了，請嘗試複製整個網址後貼上；\n• 該試算表被刪除了。'**
  String get transitImportErrorGoogleSheetFetchDataHelper;

  /// No description provided for @transitImportErrorGoogleSheetMissingTitle.
  ///
  /// In zh, this message translates to:
  /// **'找不到表單 {name} 的資料'**
  String transitImportErrorGoogleSheetMissingTitle(Object name);

  /// No description provided for @transitImportErrorGoogleSheetMissingHelper.
  ///
  /// In zh, this message translates to:
  /// **'別擔心，通常都可以簡單解決！\n可能的原因有：\n• 該試算表沒有我們想要的表單；\n• 網路狀況不穩；\n• 尚未授權 POS 系統進行表單的讀取；\n• 試算表 ID 打錯了，請嘗試複製整個網址後貼上；\n• 該試算表被刪除了。'**
  String get transitImportErrorGoogleSheetMissingHelper;

  /// No description provided for @transitImportErrorPreviewNotFound.
  ///
  /// In zh, this message translates to:
  /// **'找不到「{name}」的資料'**
  String transitImportErrorPreviewNotFound(Object name);

  /// No description provided for @transitImportErrorPlainTextNotFound.
  ///
  /// In zh, this message translates to:
  /// **'這段文字無法匹配相應的服務，請參考匯出時的文字內容。'**
  String get transitImportErrorPlainTextNotFound;

  /// No description provided for @transitImportSuccess.
  ///
  /// In zh, this message translates to:
  /// **'匯入成功'**
  String get transitImportSuccess;

  /// No description provided for @transitImportPreviewConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'確定匯入？'**
  String get transitImportPreviewConfirmTitle;

  /// No description provided for @transitImportPreviewConfirmContent.
  ///
  /// In zh, this message translates to:
  /// **'注意：匯入後將會把沒列到的資料移除，請確認是否執行！'**
  String get transitImportPreviewConfirmContent;

  /// No description provided for @transitImportPreviewConfirmBtn.
  ///
  /// In zh, this message translates to:
  /// **'匯入資料'**
  String get transitImportPreviewConfirmBtn;

  /// No description provided for @transitImportPreviewConfirmVerify.
  ///
  /// In zh, this message translates to:
  /// **'確認資料'**
  String get transitImportPreviewConfirmVerify;

  /// No description provided for @transitImportPreviewConfirmHint.
  ///
  /// In zh, this message translates to:
  /// **'還差 {count} 種資料未確認。\n請確認資料是否正確，若有錯誤請取消操作並修正後重新匯入。\n'**
  String transitImportPreviewConfirmHint(int count);

  /// No description provided for @transitImportPreviewIngredientMetaAmount.
  ///
  /// In zh, this message translates to:
  /// **'庫存：{amount}'**
  String transitImportPreviewIngredientMetaAmount(num amount);

  /// No description provided for @transitImportPreviewIngredientMetaMaxAmount.
  ///
  /// In zh, this message translates to:
  /// **'{exist, plural, =0{未設定} other{最大值：{value}}}'**
  String transitImportPreviewIngredientMetaMaxAmount(int exist, num value);

  /// No description provided for @transitImportPreviewIngredientConfirm.
  ///
  /// In zh, this message translates to:
  /// **'注意：匯入後，為了避免影響「菜單」的狀況，並不會把沒列出的成分移除。'**
  String get transitImportPreviewIngredientConfirm;

  /// No description provided for @transitImportPreviewQuantityConfirm.
  ///
  /// In zh, this message translates to:
  /// **'注意：匯入後，為了避免影響「菜單」的狀況，並不會把沒列出的份量移除。'**
  String get transitImportPreviewQuantityConfirm;

  /// Additional status of the data displayed
  ///
  /// In zh, this message translates to:
  /// **'{name, select, normal{（一般）} staged{（新增）} stagedIng{（新的成分）} stagedQua{（新的份量）} updated{（異動）} other{UNKNOWN}}'**
  String transitImportColumnStatus(String name);

  /// No description provided for @transitFormatFieldProductIngredientTitle.
  ///
  /// In zh, this message translates to:
  /// **'成分資訊'**
  String get transitFormatFieldProductIngredientTitle;

  /// No description provided for @transitFormatFieldProductIngredientNote.
  ///
  /// In zh, this message translates to:
  /// **'產品全部成分的資訊，格式如下：\n- 成分1,預設使用量\n  + 份量a,額外使用量,額外價格,額外成本\n  + 份量b,額外使用量,額外價格,額外成本\n- 成分2,預設使用量'**
  String get transitFormatFieldProductIngredientNote;

  /// No description provided for @transitFormatFieldReplenishmentTitle.
  ///
  /// In zh, this message translates to:
  /// **'補貨量'**
  String get transitFormatFieldReplenishmentTitle;

  /// No description provided for @transitFormatFieldReplenishmentNote.
  ///
  /// In zh, this message translates to:
  /// **'每次補貨時特定成分的量，格式如下：\n- 成分1,補貨量\n- 成分2,補貨量'**
  String get transitFormatFieldReplenishmentNote;

  /// No description provided for @transitFormatFieldAttributeOptionTitle.
  ///
  /// In zh, this message translates to:
  /// **'顧客設定選項'**
  String get transitFormatFieldAttributeOptionTitle;

  /// No description provided for @transitFormatFieldAttributeOptionNote.
  ///
  /// In zh, this message translates to:
  /// **'「選項值」會根據顧客設定種類不同而有不同意義，格式如下：\n- 選項1,是否為預設,選項值\n- 選項2,是否為預設,選項值'**
  String get transitFormatFieldAttributeOptionNote;

  /// No description provided for @transitFormatFieldOrderTs.
  ///
  /// In zh, this message translates to:
  /// **'時間戳記'**
  String get transitFormatFieldOrderTs;

  /// No description provided for @transitFormatFieldOrderTime.
  ///
  /// In zh, this message translates to:
  /// **'時間'**
  String get transitFormatFieldOrderTime;

  /// No description provided for @transitFormatFieldOrderPrice.
  ///
  /// In zh, this message translates to:
  /// **'總價'**
  String get transitFormatFieldOrderPrice;

  /// No description provided for @transitFormatFieldOrderProductPrice.
  ///
  /// In zh, this message translates to:
  /// **'產品總價'**
  String get transitFormatFieldOrderProductPrice;

  /// No description provided for @transitFormatFieldOrderPaid.
  ///
  /// In zh, this message translates to:
  /// **'付額'**
  String get transitFormatFieldOrderPaid;

  /// No description provided for @transitFormatFieldOrderCost.
  ///
  /// In zh, this message translates to:
  /// **'成本'**
  String get transitFormatFieldOrderCost;

  /// No description provided for @transitFormatFieldOrderProfit.
  ///
  /// In zh, this message translates to:
  /// **'收入'**
  String get transitFormatFieldOrderProfit;

  /// how many items in the order
  ///
  /// In zh, this message translates to:
  /// **'產品份數'**
  String get transitFormatFieldOrderItemCount;

  /// how many types of products in the order
  ///
  /// In zh, this message translates to:
  /// **'產品類數'**
  String get transitFormatFieldOrderTypeCount;

  /// No description provided for @transitFormatFieldOrderAttributeTitle.
  ///
  /// In zh, this message translates to:
  /// **'訂單顧客設定'**
  String get transitFormatFieldOrderAttributeTitle;

  /// No description provided for @transitFormatFieldOrderAttributeHeaderTs.
  ///
  /// In zh, this message translates to:
  /// **'時間戳記'**
  String get transitFormatFieldOrderAttributeHeaderTs;

  /// No description provided for @transitFormatFieldOrderAttributeHeaderName.
  ///
  /// In zh, this message translates to:
  /// **'設定類別'**
  String get transitFormatFieldOrderAttributeHeaderName;

  /// No description provided for @transitFormatFieldOrderAttributeHeaderOption.
  ///
  /// In zh, this message translates to:
  /// **'選項'**
  String get transitFormatFieldOrderAttributeHeaderOption;

  /// No description provided for @transitFormatFieldOrderProductTitle.
  ///
  /// In zh, this message translates to:
  /// **'訂單產品細項'**
  String get transitFormatFieldOrderProductTitle;

  /// No description provided for @transitFormatFieldOrderProductHeaderTs.
  ///
  /// In zh, this message translates to:
  /// **'時間戳記'**
  String get transitFormatFieldOrderProductHeaderTs;

  /// No description provided for @transitFormatFieldOrderProductHeaderName.
  ///
  /// In zh, this message translates to:
  /// **'產品'**
  String get transitFormatFieldOrderProductHeaderName;

  /// No description provided for @transitFormatFieldOrderProductHeaderCatalog.
  ///
  /// In zh, this message translates to:
  /// **'種類'**
  String get transitFormatFieldOrderProductHeaderCatalog;

  /// No description provided for @transitFormatFieldOrderProductHeaderCount.
  ///
  /// In zh, this message translates to:
  /// **'數量'**
  String get transitFormatFieldOrderProductHeaderCount;

  /// No description provided for @transitFormatFieldOrderProductHeaderPrice.
  ///
  /// In zh, this message translates to:
  /// **'單一售價'**
  String get transitFormatFieldOrderProductHeaderPrice;

  /// No description provided for @transitFormatFieldOrderProductHeaderCost.
  ///
  /// In zh, this message translates to:
  /// **'單一成本'**
  String get transitFormatFieldOrderProductHeaderCost;

  /// No description provided for @transitFormatFieldOrderProductHeaderOrigin.
  ///
  /// In zh, this message translates to:
  /// **'單一原價'**
  String get transitFormatFieldOrderProductHeaderOrigin;

  /// No description provided for @transitFormatFieldOrderIngredientTitle.
  ///
  /// In zh, this message translates to:
  /// **'訂單成分細項'**
  String get transitFormatFieldOrderIngredientTitle;

  /// No description provided for @transitFormatFieldOrderIngredientHeaderTs.
  ///
  /// In zh, this message translates to:
  /// **'時間戳記'**
  String get transitFormatFieldOrderIngredientHeaderTs;

  /// No description provided for @transitFormatFieldOrderIngredientHeaderName.
  ///
  /// In zh, this message translates to:
  /// **'成分'**
  String get transitFormatFieldOrderIngredientHeaderName;

  /// No description provided for @transitFormatFieldOrderIngredientHeaderQuantity.
  ///
  /// In zh, this message translates to:
  /// **'份量'**
  String get transitFormatFieldOrderIngredientHeaderQuantity;

  /// No description provided for @transitFormatFieldOrderIngredientHeaderAmount.
  ///
  /// In zh, this message translates to:
  /// **'數量'**
  String get transitFormatFieldOrderIngredientHeaderAmount;

  /// No description provided for @transitFormatFieldOrderExpandableHint.
  ///
  /// In zh, this message translates to:
  /// **'詳見下欄'**
  String get transitFormatFieldOrderExpandableHint;

  /// No description provided for @transitFormatTextOrderPrice.
  ///
  /// In zh, this message translates to:
  /// **'{hasProducts, plural, =0{共 {price} 元。} other{共 {price} 元，其中的 {productsPrice} 元是產品價錢。}}'**
  String transitFormatTextOrderPrice(
      int hasProducts, String price, String productsPrice);

  /// No description provided for @transitFormatTextOrderMoney.
  ///
  /// In zh, this message translates to:
  /// **'付額 {paid} 元、成分 {cost} 元。'**
  String transitFormatTextOrderMoney(String paid, String cost);

  /// No description provided for @transitFormatTextOrderProductCount.
  ///
  /// In zh, this message translates to:
  /// **'{count, plural, =0{沒有任何餐點。} =1{餐點有 {count} 份，內容為：\n{products}。} other{餐點有 {count} 份（{setCount} 種組合）包括：\n{products}。}}'**
  String transitFormatTextOrderProductCount(
      int count, int setCount, String products);

  /// No description provided for @transitFormatTextOrderProduct.
  ///
  /// In zh, this message translates to:
  /// **'{hasIngredient, plural, =0{{product}（{catalog}）{count} 份共 {price} 元，沒有設定成分} other{{product}（{catalog}）{count} 份共 {price} 元，成份包括 {ingredients}}}'**
  String transitFormatTextOrderProduct(int hasIngredient, String product,
      String catalog, int count, String price, String ingredients);

  /// Details of ingredients and quantities for each product in the order list
  ///
  /// In zh, this message translates to:
  /// **'{amount, plural, =0{{ingredient}（{quantity}）} other{{ingredient}（{quantity}），使用 {amount} 個}}'**
  String transitFormatTextOrderIngredient(
      num amount, String ingredient, String quantity);

  /// No description provided for @transitFormatTextOrderNoQuantity.
  ///
  /// In zh, this message translates to:
  /// **'預設份量'**
  String get transitFormatTextOrderNoQuantity;

  /// No description provided for @transitFormatTextOrderOrderAttribute.
  ///
  /// In zh, this message translates to:
  /// **'顧客的 {options}'**
  String transitFormatTextOrderOrderAttribute(String options);

  /// No description provided for @transitFormatTextOrderOrderAttributeItem.
  ///
  /// In zh, this message translates to:
  /// **'{name} 為 {option}'**
  String transitFormatTextOrderOrderAttributeItem(String name, String option);

  /// No description provided for @transitFormatTextMenuHeader.
  ///
  /// In zh, this message translates to:
  /// **'本菜單共有 {catalogs} 個產品種類、{products} 個產品。'**
  String transitFormatTextMenuHeader(int catalogs, int products);

  /// This is used to check if this text is a menu
  ///
  /// In zh, this message translates to:
  /// **'本菜單'**
  String get transitFormatTextMenuHeaderPrefix;

  /// Strings are used so that regex can be inserted here during import to obtain information
  ///
  /// In zh, this message translates to:
  /// **'第{index}個種類叫做 {catalog}，{details}。'**
  String transitFormatTextMenuCatalog(
      String index, String catalog, String details);

  /// No description provided for @transitFormatTextMenuCatalogDetails.
  ///
  /// In zh, this message translates to:
  /// **'{count, plural, =0{沒有設定產品} other{共有 {count} 個產品}}'**
  String transitFormatTextMenuCatalogDetails(int count);

  /// Strings are used so that regex can be inserted here during import to obtain information
  ///
  /// In zh, this message translates to:
  /// **'第{index}個產品叫做 {name}，其售價為 {price} 元，成本為 {cost} 元，{details}'**
  String transitFormatTextMenuProduct(
      String index, String name, String price, String cost, String details);

  /// No description provided for @transitFormatTextMenuProductDetails.
  ///
  /// In zh, this message translates to:
  /// **'{count, plural, =0{它沒有設定任何成份。} other{它的成份有 {count} 種：{names}。\n每份產品預設需要使用 {details}。}}'**
  String transitFormatTextMenuProductDetails(
      int count, String names, String details);

  /// Strings are used so that regex can be inserted here during import to obtain information
  ///
  /// In zh, this message translates to:
  /// **'{amount} 個 {name}，{details}'**
  String transitFormatTextMenuIngredient(
      String amount, String name, String details);

  /// No description provided for @transitFormatTextMenuIngredientDetails.
  ///
  /// In zh, this message translates to:
  /// **'{count, plural, =0{無法做份量調整} other{它還有 {count} 個不同份量 {quantities}}}'**
  String transitFormatTextMenuIngredientDetails(int count, String quantities);

  /// Strings are used so that regex can be inserted here during import to obtain information
  ///
  /// In zh, this message translates to:
  /// **'每份產品改成使用 {amount} 個並調整產品售價 {price} 元和成本 {cost} 元'**
  String transitFormatTextMenuQuantity(
      String amount, String price, String cost);

  /// No description provided for @transitFormatTextStockHeader.
  ///
  /// In zh, this message translates to:
  /// **'本庫存共有 {count} 種成分。'**
  String transitFormatTextStockHeader(int count);

  /// This is used to check if this text is stock
  ///
  /// In zh, this message translates to:
  /// **'本庫存'**
  String get transitFormatTextStockHeaderPrefix;

  /// Strings are used so that regex can be inserted here during import to obtain information
  ///
  /// In zh, this message translates to:
  /// **'第{index}個成分叫做 {name}，庫存現有 {amount} 個{details}。'**
  String transitFormatTextStockIngredient(
      String index, String name, String amount, String details);

  /// String(max) are used so that regex can be inserted here during import to obtain information
  ///
  /// In zh, this message translates to:
  /// **'{exist, plural, =0{} other{，最大量有 {max} 個}}'**
  String transitFormatTextStockIngredientMaxAmount(int exist, String max);

  /// No description provided for @transitFormatTextStockIngredientRestockPrice.
  ///
  /// In zh, this message translates to:
  /// **'{exist, plural, =0{} other{且每 {quantity} 個成本要價 {price} 元}}'**
  String transitFormatTextStockIngredientRestockPrice(
      int exist, String quantity, String price);

  /// No description provided for @transitFormatTextQuantitiesHeader.
  ///
  /// In zh, this message translates to:
  /// **'共設定 {count} 種份量。'**
  String transitFormatTextQuantitiesHeader(int count);

  /// This is used to check if this text is quantities
  ///
  /// In zh, this message translates to:
  /// **'種份量。'**
  String get transitFormatTextQuantitiesHeaderSuffix;

  /// Strings are used so that regex can be inserted here during import to obtain information
  ///
  /// In zh, this message translates to:
  /// **'第{index}種份量叫做 {name}，預設會讓成分的份量乘以 {prop} 倍。'**
  String transitFormatTextQuantitiesQuantity(
      String index, String name, String prop);

  /// No description provided for @transitFormatTextReplenisherHeader.
  ///
  /// In zh, this message translates to:
  /// **'共設定 {count} 種補貨方式。'**
  String transitFormatTextReplenisherHeader(int count);

  /// This is used to check if this text is replenishment quantity
  ///
  /// In zh, this message translates to:
  /// **'種補貨方式。'**
  String get transitFormatTextReplenisherHeaderSuffix;

  /// Strings are used so that regex can be inserted here during import to obtain information
  ///
  /// In zh, this message translates to:
  /// **'第{index}個成分叫做 {name}，{details}。'**
  String transitFormatTextReplenisherReplenishment(
      String index, String name, String details);

  /// No description provided for @transitFormatTextReplenisherReplenishmentDetails.
  ///
  /// In zh, this message translates to:
  /// **'{count, plural, =0{它並不會調整庫存} other{它會調整{count}種成份的庫存}}'**
  String transitFormatTextReplenisherReplenishmentDetails(int count);

  /// No description provided for @transitFormatTextOaHeader.
  ///
  /// In zh, this message translates to:
  /// **'共設定 {count} 種顧客屬性。'**
  String transitFormatTextOaHeader(int count);

  /// This is used to check if this text is customer settings
  ///
  /// In zh, this message translates to:
  /// **'種顧客屬性。'**
  String get transitFormatTextOaHeaderSuffix;

  /// Strings are used so that regex can be inserted here during import to obtain information
  ///
  /// In zh, this message translates to:
  /// **'第{index}種屬性叫做 {name}，屬於 {mode} 類型，{details}。'**
  String transitFormatTextOaOa(
      String index, String name, String mode, String details);

  /// No description provided for @transitFormatTextOaOaDetails.
  ///
  /// In zh, this message translates to:
  /// **'{count, plural, =0{它並沒有設定選項} other{它有 {count} 個選項}}'**
  String transitFormatTextOaOaDetails(int count);

  /// No description provided for @transitFormatTextOaDefaultOption.
  ///
  /// In zh, this message translates to:
  /// **'預設'**
  String get transitFormatTextOaDefaultOption;

  /// No description provided for @transitFormatTextOaModeValue.
  ///
  /// In zh, this message translates to:
  /// **'選項的值為 {value}'**
  String transitFormatTextOaModeValue(num value);

  /// No description provided for @transitGoogleSheetDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'提供 Google 試算表'**
  String get transitGoogleSheetDialogTitle;

  /// No description provided for @transitGoogleSheetDialogCreate.
  ///
  /// In zh, this message translates to:
  /// **'建立新的試算表'**
  String get transitGoogleSheetDialogCreate;

  /// No description provided for @transitGoogleSheetDialogSelectExist.
  ///
  /// In zh, this message translates to:
  /// **'選擇現有的試算表'**
  String get transitGoogleSheetDialogSelectExist;

  /// No description provided for @transitGoogleSheetDialogConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確認'**
  String get transitGoogleSheetDialogConfirm;

  /// No description provided for @transitGoogleSheetDialogIdLabel.
  ///
  /// In zh, this message translates to:
  /// **'試算表 ID 或網址'**
  String get transitGoogleSheetDialogIdLabel;

  /// No description provided for @transitGoogleSheetDialogIdHelper.
  ///
  /// In zh, this message translates to:
  /// **'試算表的 ID 是網址中的英文、數字、底線和減號的組合。\n例如，\"https://docs.google.com/spreadsheets/d/1a2b3c4d5e6f7g8h9i0j\" 的 ID 是 \"1a2b3c4d5e6f7g8h9i0j\"。\n使用現有的試算表將可能覆蓋選擇的工作表中的數據。'**
  String get transitGoogleSheetDialogIdHelper;

  /// No description provided for @transitGoogleSheetProgressCreate.
  ///
  /// In zh, this message translates to:
  /// **'建立試算表'**
  String get transitGoogleSheetProgressCreate;

  /// No description provided for @transitGoogleSheetProgressFulfill.
  ///
  /// In zh, this message translates to:
  /// **'在試算表中建立表單'**
  String get transitGoogleSheetProgressFulfill;

  /// No description provided for @transitGoogleSheetErrorCreateTitle.
  ///
  /// In zh, this message translates to:
  /// **'無法建立試算表'**
  String get transitGoogleSheetErrorCreateTitle;

  /// No description provided for @transitGoogleSheetErrorCreateHelper.
  ///
  /// In zh, this message translates to:
  /// **'別擔心，通常都可以簡單解決！\n可能的原因有：\n• 網路狀況不穩；\n• 尚未授權 POS 系統進行表單的編輯。'**
  String get transitGoogleSheetErrorCreateHelper;

  /// No description provided for @transitGoogleSheetErrorFulfillTitle.
  ///
  /// In zh, this message translates to:
  /// **'無法在試算表中建立表單'**
  String get transitGoogleSheetErrorFulfillTitle;

  /// No description provided for @transitGoogleSheetErrorFulfillHelper.
  ///
  /// In zh, this message translates to:
  /// **'別擔心，通常都可以簡單解決！\n可能的原因有：\n• 網路狀況不穩；\n• 尚未授權 POS 系統進行表單的建立；\n• 試算表 ID 打錯了，請嘗試複製整個網址後貼上；\n• 該試算表被刪除了。'**
  String get transitGoogleSheetErrorFulfillHelper;

  /// No description provided for @transitGoogleSheetErrorIdNotFound.
  ///
  /// In zh, this message translates to:
  /// **'找不到試算表'**
  String get transitGoogleSheetErrorIdNotFound;

  /// No description provided for @transitGoogleSheetErrorIdNotFoundHelper.
  ///
  /// In zh, this message translates to:
  /// **'別擔心，通常都可以簡單解決！\n可能的原因有：\n• 網路狀況不穩；\n• 尚未授權 POS 系統進行表單的讀取；\n• 試算表 ID 打錯了，請嘗試複製整個網址後貼上；\n• 該試算表被刪除了。'**
  String get transitGoogleSheetErrorIdNotFoundHelper;

  /// No description provided for @transitGoogleSheetErrorIdEmpty.
  ///
  /// In zh, this message translates to:
  /// **'ID 不能為空'**
  String get transitGoogleSheetErrorIdEmpty;

  /// No description provided for @transitGoogleSheetErrorIdInvalid.
  ///
  /// In zh, this message translates to:
  /// **'不合法的 ID，必須包含：\n• /spreadsheets/d/<ID>/\n• 或者直接給 ID（英文+數字+底線+減號的組合）'**
  String get transitGoogleSheetErrorIdInvalid;

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'POS 系統'**
  String get appTitle;

  /// Action executed successfully and displayed on the Snackbar.
  ///
  /// In zh, this message translates to:
  /// **'執行成功'**
  String get actSuccess;

  /// Error message displayed on the Snackbar when an error occurs.
  ///
  /// In zh, this message translates to:
  /// **'錯誤'**
  String get actError;

  /// Button on the Snackbar to show more details.
  ///
  /// In zh, this message translates to:
  /// **'說明'**
  String get actMoreInfo;

  /// Reminder to the user that only one option can be selected at a time.
  ///
  /// In zh, this message translates to:
  /// **'一次只能選擇一種'**
  String get singleChoice;

  /// Reminder to the user that multiple options can be selected.
  ///
  /// In zh, this message translates to:
  /// **'可以選擇多種'**
  String get multiChoices;

  /// Total count displayed on the ListView.
  ///
  /// In zh, this message translates to:
  /// **'{count, plural, other{總共 {count} 項}}'**
  String totalCount(int count);

  /// Total count displayed on the SearchScaffold.
  ///
  /// In zh, this message translates to:
  /// **'搜尋到 {count} 個結果'**
  String searchCount(int count);

  /// No description provided for @title.
  ///
  /// In zh, this message translates to:
  /// **'{name, select, analysis{分析} stock{庫存} cashier{收銀} settings{設定} menu{菜單} printers{出單機} transit{資料轉移} orderAttributes{顧客設定} stockQuantities{份量} elf{建議} more{更多} debug{Debug} other{UNKNOWN}}'**
  String title(String name);

  /// Title displayed on the DeleteDialog.
  ///
  /// In zh, this message translates to:
  /// **'刪除確認通知'**
  String get dialogDeletionTitle;

  /// Content displayed on the DeleteDialog.
  ///
  /// In zh, this message translates to:
  /// **'確定要刪除「{name}」嗎？\n\n{more}此動作將無法復原！'**
  String dialogDeletionContent(String name, String more);

  /// No description provided for @imageHolderCreate.
  ///
  /// In zh, this message translates to:
  /// **'點選以新增圖片'**
  String get imageHolderCreate;

  /// No description provided for @imageHolderUpdate.
  ///
  /// In zh, this message translates to:
  /// **'點擊以更新圖片'**
  String get imageHolderUpdate;

  /// No description provided for @imageBtnCrop.
  ///
  /// In zh, this message translates to:
  /// **'裁切'**
  String get imageBtnCrop;

  /// No description provided for @imageGalleryTitle.
  ///
  /// In zh, this message translates to:
  /// **'圖片管理'**
  String get imageGalleryTitle;

  /// No description provided for @imageGalleryEmpty.
  ///
  /// In zh, this message translates to:
  /// **'點擊開始匯入你的第一張照片！'**
  String get imageGalleryEmpty;

  /// No description provided for @imageGalleryActionCreate.
  ///
  /// In zh, this message translates to:
  /// **'新增圖片'**
  String get imageGalleryActionCreate;

  /// No description provided for @imageGalleryActionDelete.
  ///
  /// In zh, this message translates to:
  /// **'刪除'**
  String get imageGalleryActionDelete;

  /// No description provided for @imageGallerySnackbarDeleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'有一個或多個圖片沒有刪成功。'**
  String get imageGallerySnackbarDeleteFailed;

  /// No description provided for @imageGallerySelectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'選擇相片'**
  String get imageGallerySelectionTitle;

  /// No description provided for @imageGallerySelectionDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'將會刪除 {count} 個圖片\n刪除之後會讓相關產品顯示不到圖片'**
  String imageGallerySelectionDeleteConfirm(int count);

  /// Text displayed on EmptyBody, informing the user that there are no items yet. This is the default text.
  ///
  /// In zh, this message translates to:
  /// **'哎呀！這裡還是空的'**
  String get emptyBodyTitle;

  /// No description provided for @emptyBodyAction.
  ///
  /// In zh, this message translates to:
  /// **'立即設定'**
  String get emptyBodyAction;

  /// Button text to navigate to another screen in trailing.
  ///
  /// In zh, this message translates to:
  /// **'查看'**
  String get btnNavTo;

  /// No description provided for @btnSignInWithGoogle.
  ///
  /// In zh, this message translates to:
  /// **'使用 Google 登入'**
  String get btnSignInWithGoogle;

  /// No description provided for @semanticsPercentileBar.
  ///
  /// In zh, this message translates to:
  /// **'目前佔總數的 {percent}'**
  String semanticsPercentileBar(num percent);

  /// Warning message when the input is not an integer.
  ///
  /// In zh, this message translates to:
  /// **'{field}必須是整數'**
  String invalidIntegerType(String field);

  /// Warning message when the input is not a number.
  ///
  /// In zh, this message translates to:
  /// **'{field}必須是數字'**
  String invalidNumberType(String field);

  /// Warning message when the input is not positive.
  ///
  /// In zh, this message translates to:
  /// **'{field}不能為負數'**
  String invalidNumberPositive(String field);

  /// Warning message when the input exceeds the maximum value.
  ///
  /// In zh, this message translates to:
  /// **'{field}不能超過 {maximum}'**
  String invalidNumberMaximum(String field, num maximum);

  /// Warning message when the input is less than the minimum value.
  ///
  /// In zh, this message translates to:
  /// **'{field}不能低於 {minimum}'**
  String invalidNumberMinimum(String field, num minimum);

  /// Warning message when no text is entered.
  ///
  /// In zh, this message translates to:
  /// **'{field}不能為空'**
  String invalidStringEmpty(String field);

  /// Warning message when the input exceeds the maximum character limit.
  ///
  /// In zh, this message translates to:
  /// **'{field}不能超過 {maximum} 個字'**
  String invalidStringMaximum(String field, int maximum);

  /// One of the units for calendar period conversion.
  ///
  /// In zh, this message translates to:
  /// **'單月'**
  String get singleMonth;

  /// One of the units for calendar period conversion.
  ///
  /// In zh, this message translates to:
  /// **'單週'**
  String get singleWeek;

  /// One of the units for calendar period conversion.
  ///
  /// In zh, this message translates to:
  /// **'雙週'**
  String get twoWeeks;

  /// No description provided for @orderAttributeTitle.
  ///
  /// In zh, this message translates to:
  /// **'顧客設定'**
  String get orderAttributeTitle;

  /// No description provided for @orderAttributeDescription.
  ///
  /// In zh, this message translates to:
  /// **'內用、外帶等幫助分析的資訊'**
  String get orderAttributeDescription;

  /// No description provided for @orderAttributeTitleCreate.
  ///
  /// In zh, this message translates to:
  /// **'新增顧客設定'**
  String get orderAttributeTitleCreate;

  /// No description provided for @orderAttributeTitleUpdate.
  ///
  /// In zh, this message translates to:
  /// **'編輯顧客設定'**
  String get orderAttributeTitleUpdate;

  /// No description provided for @orderAttributeTitleReorder.
  ///
  /// In zh, this message translates to:
  /// **'排序顧客設定'**
  String get orderAttributeTitleReorder;

  /// No description provided for @orderAttributeEmptyBody.
  ///
  /// In zh, this message translates to:
  /// **'顧客設定可以幫助我們統計哪些人來消費，例如：\n20-30歲、外帶、上班族。'**
  String get orderAttributeEmptyBody;

  /// Displayed on the upper rectangle in homepage
  ///
  /// In zh, this message translates to:
  /// **'顧客設定'**
  String get orderAttributeHeaderInfo;

  /// No description provided for @orderAttributeTutorialTitle.
  ///
  /// In zh, this message translates to:
  /// **'建立屬於你的顧客設定'**
  String get orderAttributeTutorialTitle;

  /// No description provided for @orderAttributeTutorialContent.
  ///
  /// In zh, this message translates to:
  /// **'這裡是用來設定顧客的資訊，例如：內用、外帶、上班族等。\n這些資訊可以幫助我們統計哪些人來消費，進而做出更好的經營策略。'**
  String get orderAttributeTutorialContent;

  /// No description provided for @orderAttributeTutorialCreateExample.
  ///
  /// In zh, this message translates to:
  /// **'幫助建立一份範例以供測試。'**
  String get orderAttributeTutorialCreateExample;

  /// No description provided for @orderAttributeExampleAge.
  ///
  /// In zh, this message translates to:
  /// **'年齡'**
  String get orderAttributeExampleAge;

  /// No description provided for @orderAttributeExampleAgeChild.
  ///
  /// In zh, this message translates to:
  /// **'小孩'**
  String get orderAttributeExampleAgeChild;

  /// No description provided for @orderAttributeExampleAgeAdult.
  ///
  /// In zh, this message translates to:
  /// **'成人'**
  String get orderAttributeExampleAgeAdult;

  /// No description provided for @orderAttributeExampleAgeSenior.
  ///
  /// In zh, this message translates to:
  /// **'長者'**
  String get orderAttributeExampleAgeSenior;

  /// No description provided for @orderAttributeExamplePlace.
  ///
  /// In zh, this message translates to:
  /// **'位置'**
  String get orderAttributeExamplePlace;

  /// No description provided for @orderAttributeExamplePlaceTakeout.
  ///
  /// In zh, this message translates to:
  /// **'外帶'**
  String get orderAttributeExamplePlaceTakeout;

  /// No description provided for @orderAttributeExamplePlaceDineIn.
  ///
  /// In zh, this message translates to:
  /// **'內用'**
  String get orderAttributeExamplePlaceDineIn;

  /// No description provided for @orderAttributeExampleEcoFriendly.
  ///
  /// In zh, this message translates to:
  /// **'環保'**
  String get orderAttributeExampleEcoFriendly;

  /// No description provided for @orderAttributeExampleEcoFriendlyReusableBottle.
  ///
  /// In zh, this message translates to:
  /// **'環保杯'**
  String get orderAttributeExampleEcoFriendlyReusableBottle;

  /// No description provided for @orderAttributeExampleEcoFriendlyReusableBag.
  ///
  /// In zh, this message translates to:
  /// **'環保袋'**
  String get orderAttributeExampleEcoFriendlyReusableBag;

  /// No description provided for @orderAttributeMetaMode.
  ///
  /// In zh, this message translates to:
  /// **'種類：{name}'**
  String orderAttributeMetaMode(String name);

  /// No description provided for @orderAttributeMetaDefault.
  ///
  /// In zh, this message translates to:
  /// **'預設：{name}'**
  String orderAttributeMetaDefault(String name);

  /// No description provided for @orderAttributeMetaNoDefault.
  ///
  /// In zh, this message translates to:
  /// **'未設定預設'**
  String get orderAttributeMetaNoDefault;

  /// No description provided for @orderAttributeModeDivider.
  ///
  /// In zh, this message translates to:
  /// **'顧客設定種類'**
  String get orderAttributeModeDivider;

  /// Customer setting mode name
  ///
  /// In zh, this message translates to:
  /// **'{name, select, statOnly{一般} changePrice{變價} changeDiscount{折扣} other{UNKNOWN}}'**
  String orderAttributeModeName(String name);

  /// Explanation of customer setting categories
  ///
  /// In zh, this message translates to:
  /// **'{name, select, statOnly{一般的設定，選取時並不會影響點單價格。} changePrice{選取設定時，可能會影響價格。\n例如：外送 + 30塊錢、環保杯 - 5塊錢。} changeDiscount{選取設定時，會根據折扣影響總價。\n例如：內用 + 10% 服務費、親友價 - 10%。} other{UNKNOWN}}'**
  String orderAttributeModeHelper(String name);

  /// No description provided for @orderAttributeNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'顧客設定名稱'**
  String get orderAttributeNameLabel;

  /// No description provided for @orderAttributeNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：顧客年齡'**
  String get orderAttributeNameHint;

  /// No description provided for @orderAttributeNameErrorRepeat.
  ///
  /// In zh, this message translates to:
  /// **'名稱不能重複'**
  String get orderAttributeNameErrorRepeat;

  /// No description provided for @orderAttributeOptionTitleCreate.
  ///
  /// In zh, this message translates to:
  /// **'新增選項'**
  String get orderAttributeOptionTitleCreate;

  /// No description provided for @orderAttributeOptionTitleUpdate.
  ///
  /// In zh, this message translates to:
  /// **'編輯選項'**
  String get orderAttributeOptionTitleUpdate;

  /// No description provided for @orderAttributeOptionTitleReorder.
  ///
  /// In zh, this message translates to:
  /// **'排序選項'**
  String get orderAttributeOptionTitleReorder;

  /// No description provided for @orderAttributeOptionMetaDefault.
  ///
  /// In zh, this message translates to:
  /// **'預設'**
  String get orderAttributeOptionMetaDefault;

  /// No description provided for @orderAttributeOptionMetaOptionOf.
  ///
  /// In zh, this message translates to:
  /// **'{name}的選項'**
  String orderAttributeOptionMetaOptionOf(String name);

  /// No description provided for @orderAttributeOptionNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'選項名稱'**
  String get orderAttributeOptionNameLabel;

  /// No description provided for @orderAttributeOptionNameHelper.
  ///
  /// In zh, this message translates to:
  /// **'以年齡為例，可能的選項有：\n- ⇣ 20\n- 20 ⇢ 30'**
  String get orderAttributeOptionNameHelper;

  /// No description provided for @orderAttributeOptionNameErrorRepeat.
  ///
  /// In zh, this message translates to:
  /// **'名稱不能重複'**
  String get orderAttributeOptionNameErrorRepeat;

  /// No description provided for @orderAttributeOptionModeTitle.
  ///
  /// In zh, this message translates to:
  /// **'選項模式'**
  String get orderAttributeOptionModeTitle;

  /// Explanation of mode
  ///
  /// In zh, this message translates to:
  /// **'{name, select, statOnly{因為本設定為「一般」故無須設定「折價」或「變價」} changePrice{訂單時選擇此項會套用此變價} changeDiscount{訂單時選擇此項會套用此折價} other{UNKNOWN}}'**
  String orderAttributeOptionModeHelper(String name);

  /// No description provided for @orderAttributeOptionModeHint.
  ///
  /// In zh, this message translates to:
  /// **'{name, select, statOnly{} changePrice{例如：-30 代表減少三十塊} changeDiscount{例如：80 代表「八折」} other{UNKNOWN}}'**
  String orderAttributeOptionModeHint(String name);

  /// No description provided for @orderAttributeOptionToDefaultLabel.
  ///
  /// In zh, this message translates to:
  /// **'設為預設'**
  String get orderAttributeOptionToDefaultLabel;

  /// No description provided for @orderAttributeOptionToDefaultHelper.
  ///
  /// In zh, this message translates to:
  /// **'設定此選項為預設值，每個訂單預設都會是使用這個選項。'**
  String get orderAttributeOptionToDefaultHelper;

  /// No description provided for @orderAttributeOptionToDefaultConfirmChangeTitle.
  ///
  /// In zh, this message translates to:
  /// **'覆蓋選項預設？'**
  String get orderAttributeOptionToDefaultConfirmChangeTitle;

  /// Prompt to ensure the user knows what the original default value was
  ///
  /// In zh, this message translates to:
  /// **'這麼做會讓「{name}」變成非預設值'**
  String orderAttributeOptionToDefaultConfirmChangeContent(String name);

  /// No description provided for @orderAttributeValueEmpty.
  ///
  /// In zh, this message translates to:
  /// **'不影響價錢'**
  String get orderAttributeValueEmpty;

  /// No description provided for @orderAttributeValueFree.
  ///
  /// In zh, this message translates to:
  /// **'免費'**
  String get orderAttributeValueFree;

  /// No description provided for @menuTitle.
  ///
  /// In zh, this message translates to:
  /// **'菜單'**
  String get menuTitle;

  /// No description provided for @menuSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'產品種類、產品'**
  String get menuSubtitle;

  /// No description provided for @menuTutorialTitle.
  ///
  /// In zh, this message translates to:
  /// **'建立屬於你的菜單'**
  String get menuTutorialTitle;

  /// No description provided for @menuTutorialContent.
  ///
  /// In zh, this message translates to:
  /// **'首先我們來開始建立一份菜單吧！'**
  String get menuTutorialContent;

  /// No description provided for @menuTutorialCreateExample.
  ///
  /// In zh, this message translates to:
  /// **'幫助建立一份範例菜單以供測試。'**
  String get menuTutorialCreateExample;

  /// No description provided for @menuSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜尋產品、成分、份量'**
  String get menuSearchHint;

  /// No description provided for @menuSearchNotFound.
  ///
  /// In zh, this message translates to:
  /// **'搜尋不到相關資訊，打錯字了嗎？'**
  String get menuSearchNotFound;

  /// No description provided for @menuExampleCatalogBurger.
  ///
  /// In zh, this message translates to:
  /// **'漢堡'**
  String get menuExampleCatalogBurger;

  /// No description provided for @menuExampleCatalogDrink.
  ///
  /// In zh, this message translates to:
  /// **'飲品'**
  String get menuExampleCatalogDrink;

  /// No description provided for @menuExampleCatalogSide.
  ///
  /// In zh, this message translates to:
  /// **'點心'**
  String get menuExampleCatalogSide;

  /// No description provided for @menuExampleCatalogOther.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get menuExampleCatalogOther;

  /// No description provided for @menuExampleProductCheeseBurger.
  ///
  /// In zh, this message translates to:
  /// **'起司漢堡'**
  String get menuExampleProductCheeseBurger;

  /// No description provided for @menuExampleProductVeggieBurger.
  ///
  /// In zh, this message translates to:
  /// **'蔬菜漢堡'**
  String get menuExampleProductVeggieBurger;

  /// No description provided for @menuExampleProductHamBurger.
  ///
  /// In zh, this message translates to:
  /// **'火腿漢堡'**
  String get menuExampleProductHamBurger;

  /// No description provided for @menuExampleProductCola.
  ///
  /// In zh, this message translates to:
  /// **'可樂'**
  String get menuExampleProductCola;

  /// No description provided for @menuExampleProductCoffee.
  ///
  /// In zh, this message translates to:
  /// **'咖啡'**
  String get menuExampleProductCoffee;

  /// No description provided for @menuExampleProductFries.
  ///
  /// In zh, this message translates to:
  /// **'薯條'**
  String get menuExampleProductFries;

  /// No description provided for @menuExampleProductStraw.
  ///
  /// In zh, this message translates to:
  /// **'吸管'**
  String get menuExampleProductStraw;

  /// No description provided for @menuExampleProductPlasticBag.
  ///
  /// In zh, this message translates to:
  /// **'塑膠袋'**
  String get menuExampleProductPlasticBag;

  /// No description provided for @menuExampleIngredientCheese.
  ///
  /// In zh, this message translates to:
  /// **'起司'**
  String get menuExampleIngredientCheese;

  /// No description provided for @menuExampleIngredientLettuce.
  ///
  /// In zh, this message translates to:
  /// **'萵苣'**
  String get menuExampleIngredientLettuce;

  /// No description provided for @menuExampleIngredientTomato.
  ///
  /// In zh, this message translates to:
  /// **'番茄'**
  String get menuExampleIngredientTomato;

  /// No description provided for @menuExampleIngredientBun.
  ///
  /// In zh, this message translates to:
  /// **'麵包'**
  String get menuExampleIngredientBun;

  /// No description provided for @menuExampleIngredientChili.
  ///
  /// In zh, this message translates to:
  /// **'辣醬'**
  String get menuExampleIngredientChili;

  /// No description provided for @menuExampleIngredientHam.
  ///
  /// In zh, this message translates to:
  /// **'火腿'**
  String get menuExampleIngredientHam;

  /// No description provided for @menuExampleIngredientCola.
  ///
  /// In zh, this message translates to:
  /// **'可樂'**
  String get menuExampleIngredientCola;

  /// No description provided for @menuExampleIngredientCoffee.
  ///
  /// In zh, this message translates to:
  /// **'濾掛咖啡包'**
  String get menuExampleIngredientCoffee;

  /// No description provided for @menuExampleIngredientFries.
  ///
  /// In zh, this message translates to:
  /// **'薯條'**
  String get menuExampleIngredientFries;

  /// No description provided for @menuExampleIngredientStraw.
  ///
  /// In zh, this message translates to:
  /// **'吸管'**
  String get menuExampleIngredientStraw;

  /// No description provided for @menuExampleIngredientPlasticBag.
  ///
  /// In zh, this message translates to:
  /// **'塑膠袋'**
  String get menuExampleIngredientPlasticBag;

  /// No description provided for @menuExampleQuantitySmall.
  ///
  /// In zh, this message translates to:
  /// **'少量'**
  String get menuExampleQuantitySmall;

  /// No description provided for @menuExampleQuantityLarge.
  ///
  /// In zh, this message translates to:
  /// **'增量'**
  String get menuExampleQuantityLarge;

  /// No description provided for @menuExampleQuantityNone.
  ///
  /// In zh, this message translates to:
  /// **'無'**
  String get menuExampleQuantityNone;

  /// No description provided for @menuCatalogEmptyBody.
  ///
  /// In zh, this message translates to:
  /// **'我們會把相似「產品」放在「產品種類」中，\n到時候點餐會比較方便，例如：\n• 「起司漢堡」、「蔬菜漢堡」整合進「漢堡」\n• 「塑膠袋」、「環保杯」整合進「其他」'**
  String get menuCatalogEmptyBody;

  /// FloatingActionButton description on the menu page
  ///
  /// In zh, this message translates to:
  /// **'新增產品種類'**
  String get menuCatalogTitleCreate;

  /// No description provided for @menuCatalogTitleUpdate.
  ///
  /// In zh, this message translates to:
  /// **'編輯產品種類'**
  String get menuCatalogTitleUpdate;

  /// No description provided for @menuCatalogTitleReorder.
  ///
  /// In zh, this message translates to:
  /// **'排序產品種類'**
  String get menuCatalogTitleReorder;

  /// Warning message when deleting product categories on the menu page
  ///
  /// In zh, this message translates to:
  /// **'{count, plural, =0{其內無任何產品} other{將會一同刪除掉 {count} 個產品}}'**
  String menuCatalogDialogDeletionContent(int count);

  /// No description provided for @menuCatalogNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'產品種類名稱'**
  String get menuCatalogNameLabel;

  /// No description provided for @menuCatalogNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：漢堡'**
  String get menuCatalogNameHint;

  /// No description provided for @menuCatalogNameErrorRepeat.
  ///
  /// In zh, this message translates to:
  /// **'名稱重複了，請改個名字吧！'**
  String get menuCatalogNameErrorRepeat;

  /// No description provided for @menuCatalogEmptyProducts.
  ///
  /// In zh, this message translates to:
  /// **'尚未設定產品'**
  String get menuCatalogEmptyProducts;

  /// Displayed on the upper rectangle in homepage
  ///
  /// In zh, this message translates to:
  /// **'產品'**
  String get menuProductHeaderInfo;

  /// No description provided for @menuProductEmptyBody.
  ///
  /// In zh, this message translates to:
  /// **'「產品」是菜單裡的基本單位，例如：\n「起司漢堡」、「可樂」'**
  String get menuProductEmptyBody;

  /// When not selecting a category, the product list will not be displayed. This message will be displayed in the product list
  ///
  /// In zh, this message translates to:
  /// **'請先選擇產品種類'**
  String get menuProductNotSelected;

  /// No description provided for @menuProductTitleCreate.
  ///
  /// In zh, this message translates to:
  /// **'新增產品'**
  String get menuProductTitleCreate;

  /// No description provided for @menuProductTitleUpdate.
  ///
  /// In zh, this message translates to:
  /// **'編輯產品'**
  String get menuProductTitleUpdate;

  /// No description provided for @menuProductTitleReorder.
  ///
  /// In zh, this message translates to:
  /// **'排序產品'**
  String get menuProductTitleReorder;

  /// No description provided for @menuProductTitleUpdateImage.
  ///
  /// In zh, this message translates to:
  /// **'更新照片'**
  String get menuProductTitleUpdateImage;

  /// Prefix for meta, so users know this is product meta info, not category
  ///
  /// In zh, this message translates to:
  /// **'產品'**
  String get menuProductMetaTitle;

  /// Price of the product
  ///
  /// In zh, this message translates to:
  /// **'價格：{price}'**
  String menuProductMetaPrice(num price);

  /// Cost of the product
  ///
  /// In zh, this message translates to:
  /// **'成本：{cost}'**
  String menuProductMetaCost(num cost);

  /// Text displayed in the subtitle in the product list
  ///
  /// In zh, this message translates to:
  /// **'尚未設定成分'**
  String get menuProductMetaEmpty;

  /// No description provided for @menuProductNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'產品名稱'**
  String get menuProductNameLabel;

  /// No description provided for @menuProductNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：起司漢堡'**
  String get menuProductNameHint;

  /// No description provided for @menuProductNameErrorRepeat.
  ///
  /// In zh, this message translates to:
  /// **'產品名稱重複'**
  String get menuProductNameErrorRepeat;

  /// No description provided for @menuProductPriceLabel.
  ///
  /// In zh, this message translates to:
  /// **'產品價格'**
  String get menuProductPriceLabel;

  /// No description provided for @menuProductPriceHelper.
  ///
  /// In zh, this message translates to:
  /// **'訂單頁面會呈現的價錢'**
  String get menuProductPriceHelper;

  /// No description provided for @menuProductCostLabel.
  ///
  /// In zh, this message translates to:
  /// **'產品成本'**
  String get menuProductCostLabel;

  /// No description provided for @menuProductCostHelper.
  ///
  /// In zh, this message translates to:
  /// **'用來算出利潤，理應小於價錢'**
  String get menuProductCostHelper;

  /// No description provided for @menuProductEmptyIngredients.
  ///
  /// In zh, this message translates to:
  /// **'尚未設定成分'**
  String get menuProductEmptyIngredients;

  /// No description provided for @menuIngredientEmptyBody.
  ///
  /// In zh, this message translates to:
  /// **'你可以在產品中設定成分等資訊，例如：\n「起司漢堡」有「起司」、「麵包」等成分'**
  String get menuIngredientEmptyBody;

  /// No description provided for @menuIngredientTitleCreate.
  ///
  /// In zh, this message translates to:
  /// **'新增成分'**
  String get menuIngredientTitleCreate;

  /// No description provided for @menuIngredientTitleUpdate.
  ///
  /// In zh, this message translates to:
  /// **'編輯成分'**
  String get menuIngredientTitleUpdate;

  /// No description provided for @menuIngredientTitleReorder.
  ///
  /// In zh, this message translates to:
  /// **'排序成分'**
  String get menuIngredientTitleReorder;

  /// No description provided for @menuIngredientMetaAmount.
  ///
  /// In zh, this message translates to:
  /// **'使用量：{amount}'**
  String menuIngredientMetaAmount(num amount);

  /// No description provided for @menuIngredientSearchLabel.
  ///
  /// In zh, this message translates to:
  /// **'搜尋成分'**
  String get menuIngredientSearchLabel;

  /// No description provided for @menuIngredientSearchHelper.
  ///
  /// In zh, this message translates to:
  /// **'新增成分後，可至「庫存」設定相關資訊。'**
  String get menuIngredientSearchHelper;

  /// No description provided for @menuIngredientSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：起司'**
  String get menuIngredientSearchHint;

  /// Button to add ingredient if search result not found
  ///
  /// In zh, this message translates to:
  /// **'新增成分「{name}」'**
  String menuIngredientSearchAdd(String name);

  /// No description provided for @menuIngredientSearchErrorEmpty.
  ///
  /// In zh, this message translates to:
  /// **'必須設定成分，請點選以設定。'**
  String get menuIngredientSearchErrorEmpty;

  /// No description provided for @menuIngredientSearchErrorRepeat.
  ///
  /// In zh, this message translates to:
  /// **'產品已經有相同的成分了，不能重複選取。'**
  String get menuIngredientSearchErrorRepeat;

  /// No description provided for @menuIngredientAmountLabel.
  ///
  /// In zh, this message translates to:
  /// **'使用量'**
  String get menuIngredientAmountLabel;

  /// No description provided for @menuIngredientAmountHelper.
  ///
  /// In zh, this message translates to:
  /// **'預設的使用量，若餐點可以調整該成分的使用量，請於成分的「份量」中設定。'**
  String get menuIngredientAmountHelper;

  /// No description provided for @menuQuantityTitleCreate.
  ///
  /// In zh, this message translates to:
  /// **'新增份量'**
  String get menuQuantityTitleCreate;

  /// No description provided for @menuQuantityTitleUpdate.
  ///
  /// In zh, this message translates to:
  /// **'編輯'**
  String get menuQuantityTitleUpdate;

  /// No description provided for @menuQuantityMetaAmount.
  ///
  /// In zh, this message translates to:
  /// **'使用量：{amount}'**
  String menuQuantityMetaAmount(num amount);

  /// No description provided for @menuQuantityMetaAdditionalPrice.
  ///
  /// In zh, this message translates to:
  /// **'額外售價：{price}'**
  String menuQuantityMetaAdditionalPrice(String price);

  /// No description provided for @menuQuantityMetaAdditionalCost.
  ///
  /// In zh, this message translates to:
  /// **'額外成本：{cost}'**
  String menuQuantityMetaAdditionalCost(String cost);

  /// No description provided for @menuQuantitySearchLabel.
  ///
  /// In zh, this message translates to:
  /// **'搜尋份量'**
  String get menuQuantitySearchLabel;

  /// No description provided for @menuQuantitySearchHelper.
  ///
  /// In zh, this message translates to:
  /// **'新增成分份量後，可至「份量」設定相關資訊。'**
  String get menuQuantitySearchHelper;

  /// No description provided for @menuQuantitySearchHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：多量、少量'**
  String get menuQuantitySearchHint;

  /// Button to add quantity if search result not found
  ///
  /// In zh, this message translates to:
  /// **'新增份量「{name}」'**
  String menuQuantitySearchAdd(String name);

  /// No description provided for @menuQuantitySearchErrorEmpty.
  ///
  /// In zh, this message translates to:
  /// **'必須設定份量，請點選以設定。'**
  String get menuQuantitySearchErrorEmpty;

  /// No description provided for @menuQuantitySearchErrorRepeat.
  ///
  /// In zh, this message translates to:
  /// **'產品已經有相同的份量了，不能重複選取。'**
  String get menuQuantitySearchErrorRepeat;

  /// No description provided for @menuQuantityAmountLabel.
  ///
  /// In zh, this message translates to:
  /// **'使用量'**
  String get menuQuantityAmountLabel;

  /// No description provided for @menuQuantityAdditionalPriceLabel.
  ///
  /// In zh, this message translates to:
  /// **'額外售價'**
  String get menuQuantityAdditionalPriceLabel;

  /// No description provided for @menuQuantityAdditionalPriceHelper.
  ///
  /// In zh, this message translates to:
  /// **'設為 0 則代表加量（減量）不加價。'**
  String get menuQuantityAdditionalPriceHelper;

  /// No description provided for @menuQuantityAdditionalCostLabel.
  ///
  /// In zh, this message translates to:
  /// **'額外成本'**
  String get menuQuantityAdditionalCostLabel;

  /// No description provided for @menuQuantityAdditionalCostHelper.
  ///
  /// In zh, this message translates to:
  /// **'預額外成本可以為負數，如「少量」會減少成分的使用，相對成本降低。'**
  String get menuQuantityAdditionalCostHelper;

  /// No description provided for @cashierTab.
  ///
  /// In zh, this message translates to:
  /// **'收銀'**
  String get cashierTab;

  /// No description provided for @cashierUnitLabel.
  ///
  /// In zh, this message translates to:
  /// **'幣值：{unit}'**
  String cashierUnitLabel(String unit);

  /// 設定幣值數量時的標籤
  ///
  /// In zh, this message translates to:
  /// **'數量'**
  String get cashierCounterLabel;

  /// No description provided for @cashierToDefaultTitle.
  ///
  /// In zh, this message translates to:
  /// **'設為預設'**
  String get cashierToDefaultTitle;

  /// No description provided for @cashierToDefaultTutorialTitle.
  ///
  /// In zh, this message translates to:
  /// **'收銀機預設狀態'**
  String get cashierToDefaultTutorialTitle;

  /// No description provided for @cashierToDefaultTutorialContent.
  ///
  /// In zh, this message translates to:
  /// **'在下面設定完收銀機各幣值的數量後，\n按這裡設定預設狀態！\n設定好的數量就會是各個幣值狀態條的「最大值」。'**
  String get cashierToDefaultTutorialContent;

  /// No description provided for @cashierToDefaultDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'調整收銀臺預設？'**
  String get cashierToDefaultDialogTitle;

  /// No description provided for @cashierToDefaultDialogContent.
  ///
  /// In zh, this message translates to:
  /// **'這將會把目前的收銀機狀態設定為預設狀態。\n此動作將會覆蓋掉先前的設定。'**
  String get cashierToDefaultDialogContent;

  /// No description provided for @cashierChangerTitle.
  ///
  /// In zh, this message translates to:
  /// **'換錢'**
  String get cashierChangerTitle;

  /// No description provided for @cashierChangerButton.
  ///
  /// In zh, this message translates to:
  /// **'套用'**
  String get cashierChangerButton;

  /// No description provided for @cashierChangerTutorialTitle.
  ///
  /// In zh, this message translates to:
  /// **'收銀機換錢'**
  String get cashierChangerTutorialTitle;

  /// No description provided for @cashierChangerTutorialContent.
  ///
  /// In zh, this message translates to:
  /// **'一百塊換成 10 個十塊之類。\n幫助快速調整收銀機狀態。'**
  String get cashierChangerTutorialContent;

  /// No description provided for @cashierChangerErrorNoSelection.
  ///
  /// In zh, this message translates to:
  /// **'請選擇要套用的組合'**
  String get cashierChangerErrorNoSelection;

  /// No description provided for @cashierChangerErrorNotEnough.
  ///
  /// In zh, this message translates to:
  /// **'{unit} 元不夠換'**
  String cashierChangerErrorNotEnough(String unit);

  /// No description provided for @cashierChangerErrorInvalidHead.
  ///
  /// In zh, this message translates to:
  /// **'{count} 個 {unit} 元沒辦法換'**
  String cashierChangerErrorInvalidHead(int count, String unit);

  /// Concatenated multiple lines after `invalidHead` to form a complete sentence.
  ///
  /// In zh, this message translates to:
  /// **'{count} 個 {unit} 元'**
  String cashierChangerErrorInvalidBody(int count, String unit);

  /// No description provided for @cashierChangerFavoriteTab.
  ///
  /// In zh, this message translates to:
  /// **'常用'**
  String get cashierChangerFavoriteTab;

  /// No description provided for @cashierChangerFavoriteHint.
  ///
  /// In zh, this message translates to:
  /// **'選完後請點選「套用」來使用該組合'**
  String get cashierChangerFavoriteHint;

  /// No description provided for @cashierChangerFavoriteEmptyBody.
  ///
  /// In zh, this message translates to:
  /// **'這裡可以幫助你快速轉換不同幣值'**
  String get cashierChangerFavoriteEmptyBody;

  /// No description provided for @cashierChangerFavoriteItemFrom.
  ///
  /// In zh, this message translates to:
  /// **'用 {count} 個 {unit} 元換'**
  String cashierChangerFavoriteItemFrom(int count, String unit);

  /// No description provided for @cashierChangerFavoriteItemTo.
  ///
  /// In zh, this message translates to:
  /// **'{count} 個 {unit} 元'**
  String cashierChangerFavoriteItemTo(int count, String unit);

  /// No description provided for @cashierChangerCustomTab.
  ///
  /// In zh, this message translates to:
  /// **'自訂'**
  String get cashierChangerCustomTab;

  /// No description provided for @cashierChangerCustomAddBtn.
  ///
  /// In zh, this message translates to:
  /// **'新增常用'**
  String get cashierChangerCustomAddBtn;

  /// No description provided for @cashierChangerCustomCountLabel.
  ///
  /// In zh, this message translates to:
  /// **'數量'**
  String get cashierChangerCustomCountLabel;

  /// No description provided for @cashierChangerCustomUnitLabel.
  ///
  /// In zh, this message translates to:
  /// **'幣值'**
  String get cashierChangerCustomUnitLabel;

  /// No description provided for @cashierChangerCustomUnitAddBtn.
  ///
  /// In zh, this message translates to:
  /// **'新增幣種'**
  String get cashierChangerCustomUnitAddBtn;

  /// No description provided for @cashierChangerCustomDividerFrom.
  ///
  /// In zh, this message translates to:
  /// **'拿'**
  String get cashierChangerCustomDividerFrom;

  /// No description provided for @cashierChangerCustomDividerTo.
  ///
  /// In zh, this message translates to:
  /// **'換'**
  String get cashierChangerCustomDividerTo;

  /// No description provided for @cashierSurplusTitle.
  ///
  /// In zh, this message translates to:
  /// **'結餘'**
  String get cashierSurplusTitle;

  /// No description provided for @cashierSurplusButton.
  ///
  /// In zh, this message translates to:
  /// **'結餘'**
  String get cashierSurplusButton;

  /// No description provided for @cashierSurplusTutorialTitle.
  ///
  /// In zh, this message translates to:
  /// **'每日結餘'**
  String get cashierSurplusTutorialTitle;

  /// No description provided for @cashierSurplusTutorialContent.
  ///
  /// In zh, this message translates to:
  /// **'結餘可以幫助我們在每天打烊時，\n計算現有金額和預設金額的差異。'**
  String get cashierSurplusTutorialContent;

  /// No description provided for @cashierSurplusErrorEmptyDefault.
  ///
  /// In zh, this message translates to:
  /// **'尚未設定預設狀態'**
  String get cashierSurplusErrorEmptyDefault;

  /// No description provided for @cashierSurplusTableHint.
  ///
  /// In zh, this message translates to:
  /// **'若你確認收銀機的金錢都沒問題之後就可以完成結餘囉！'**
  String get cashierSurplusTableHint;

  /// No description provided for @cashierSurplusColumnName.
  ///
  /// In zh, this message translates to:
  /// **'{name, select, unit{單位} currentCount{現有} diffCount{差異} defaultCount{預設} other{UNKNOWN}}'**
  String cashierSurplusColumnName(String name);

  /// Allow users to customize currency when surplus.
  ///
  /// In zh, this message translates to:
  /// **'幣值{unit}的數量'**
  String cashierSurplusCounterLabel(String unit);

  /// This is for display in error messages, e.g., "Quantity cannot be 0".
  ///
  /// In zh, this message translates to:
  /// **'數量'**
  String get cashierSurplusCounterShortLabel;

  /// No description provided for @cashierSurplusCurrentTotalLabel.
  ///
  /// In zh, this message translates to:
  /// **'現有總額'**
  String get cashierSurplusCurrentTotalLabel;

  /// No description provided for @cashierSurplusCurrentTotalHelper.
  ///
  /// In zh, this message translates to:
  /// **'現在收銀機應該要有的總額。\n若你發現現金和這值對不上，想一想今天有沒有用收銀機的錢買東西？'**
  String get cashierSurplusCurrentTotalHelper;

  /// No description provided for @cashierSurplusDiffTotalLabel.
  ///
  /// In zh, this message translates to:
  /// **'差額'**
  String get cashierSurplusDiffTotalLabel;

  /// No description provided for @cashierSurplusDiffTotalHelper.
  ///
  /// In zh, this message translates to:
  /// **'和收銀機最一開始的總額的差額。\n這可以快速幫你了解今天收銀機多了多少錢唷。'**
  String get cashierSurplusDiffTotalHelper;

  /// No description provided for @orderTitle.
  ///
  /// In zh, this message translates to:
  /// **'點餐'**
  String get orderTitle;

  /// No description provided for @orderBtn.
  ///
  /// In zh, this message translates to:
  /// **'點餐'**
  String get orderBtn;

  /// No description provided for @orderTutorialTitle.
  ///
  /// In zh, this message translates to:
  /// **'開始點餐！'**
  String get orderTutorialTitle;

  /// No description provided for @orderTutorialContent.
  ///
  /// In zh, this message translates to:
  /// **'一旦設定好菜單，就可以開始點餐囉\n讓我們趕緊進去看看有什麼吧！\n'**
  String get orderTutorialContent;

  /// No description provided for @orderTutorialPrinterBtnTitle.
  ///
  /// In zh, this message translates to:
  /// **'出單機異動'**
  String get orderTutorialPrinterBtnTitle;

  /// No description provided for @orderTutorialPrinterBtnContent.
  ///
  /// In zh, this message translates to:
  /// **'出單機狀態出現異動，請查看。'**
  String get orderTutorialPrinterBtnContent;

  /// No description provided for @orderSnackbarPrinterConnected.
  ///
  /// In zh, this message translates to:
  /// **'出單機連線成功：{names}'**
  String orderSnackbarPrinterConnected(String names);

  /// No description provided for @orderSnackbarPrinterDisconnected.
  ///
  /// In zh, this message translates to:
  /// **'出單機「{name}」斷線'**
  String orderSnackbarPrinterDisconnected(String name);

  /// No description provided for @orderSnackbarCashierNotEnough.
  ///
  /// In zh, this message translates to:
  /// **'收銀機錢不夠找囉！'**
  String get orderSnackbarCashierNotEnough;

  /// No description provided for @orderSnackbarCashierUsingSmallMoney.
  ///
  /// In zh, this message translates to:
  /// **'收銀機使用小錢去找零'**
  String get orderSnackbarCashierUsingSmallMoney;

  /// No description provided for @orderSnackbarCashierUsingSmallMoneyHelper.
  ///
  /// In zh, this message translates to:
  /// **'找錢給顧客時，收銀機無法使用最適合的錢，就會顯示這個訊息。\n\n例如，售價「65」，消費者支付「100」，此時應找「35」\n如果收銀機只有兩個十元，且有三個以上的五元，就會顯示本訊息。\n\n怎麼避免本提示：\n• 到換錢頁面把各幣值補足。\n• 到[設定頁]({link})關閉收銀機的相關提示。'**
  String orderSnackbarCashierUsingSmallMoneyHelper(String link);

  /// Proceed to the next step after confirming the items in your cart
  ///
  /// In zh, this message translates to:
  /// **'結帳'**
  String get orderActionCheckout;

  /// No description provided for @orderActionExchange.
  ///
  /// In zh, this message translates to:
  /// **'換錢'**
  String get orderActionExchange;

  /// No description provided for @orderActionStash.
  ///
  /// In zh, this message translates to:
  /// **'暫存本次點餐'**
  String get orderActionStash;

  /// No description provided for @orderActionReview.
  ///
  /// In zh, this message translates to:
  /// **'訂單記錄'**
  String get orderActionReview;

  /// Total revenue from orders in the order list
  ///
  /// In zh, this message translates to:
  /// **'總營收：{revenue}'**
  String orderLoaderMetaTotalRevenue(String revenue);

  /// Total cost from orders in the order list
  ///
  /// In zh, this message translates to:
  /// **'總成本：{cost}'**
  String orderLoaderMetaTotalCost(String cost);

  /// Total number of orders in the order list
  ///
  /// In zh, this message translates to:
  /// **'總數：{count}'**
  String orderLoaderMetaTotalCount(int count);

  /// No description provided for @orderLoaderEmpty.
  ///
  /// In zh, this message translates to:
  /// **'查無點餐紀錄'**
  String get orderLoaderEmpty;

  /// No description provided for @orderCatalogListEmpty.
  ///
  /// In zh, this message translates to:
  /// **'尚未設定產品種類'**
  String get orderCatalogListEmpty;

  /// Product list display mode
  ///
  /// In zh, this message translates to:
  /// **'{name, select, grid{圖片} list{列表} other{UNKNOWN}}'**
  String orderProductListViewHelper(String name);

  /// No description provided for @orderProductListNoIngredient.
  ///
  /// In zh, this message translates to:
  /// **'無設定成分'**
  String get orderProductListNoIngredient;

  /// No description provided for @orderPrinterEmpty.
  ///
  /// In zh, this message translates to:
  /// **'尚未設定出單機'**
  String get orderPrinterEmpty;

  /// No description provided for @orderPrinterDividerUnused.
  ///
  /// In zh, this message translates to:
  /// **'未使用'**
  String get orderPrinterDividerUnused;

  /// No description provided for @orderPrinterDividerConnecting.
  ///
  /// In zh, this message translates to:
  /// **'連線中'**
  String get orderPrinterDividerConnecting;

  /// No description provided for @orderPrinterDividerConnected.
  ///
  /// In zh, this message translates to:
  /// **'已連線'**
  String get orderPrinterDividerConnected;

  /// No description provided for @orderPrinterErrorCreateReceipt.
  ///
  /// In zh, this message translates to:
  /// **'無法產生出單資料'**
  String get orderPrinterErrorCreateReceipt;

  /// No description provided for @orderCartActionBulk.
  ///
  /// In zh, this message translates to:
  /// **'批量操作'**
  String get orderCartActionBulk;

  /// No description provided for @orderCartActionToggle.
  ///
  /// In zh, this message translates to:
  /// **'反選'**
  String get orderCartActionToggle;

  /// No description provided for @orderCartActionSelectAll.
  ///
  /// In zh, this message translates to:
  /// **'全選'**
  String get orderCartActionSelectAll;

  /// No description provided for @orderCartActionDiscount.
  ///
  /// In zh, this message translates to:
  /// **'打折'**
  String get orderCartActionDiscount;

  /// No description provided for @orderCartActionDiscountLabel.
  ///
  /// In zh, this message translates to:
  /// **'折扣'**
  String get orderCartActionDiscountLabel;

  /// No description provided for @orderCartActionDiscountHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：50，代表打五折（半價）'**
  String get orderCartActionDiscountHint;

  /// No description provided for @orderCartActionDiscountHelper.
  ///
  /// In zh, this message translates to:
  /// **'這裡的數字代表「折」，即，85 代表 85 折，總價乘 0.85。若需要準確的價錢請用「變價」。'**
  String get orderCartActionDiscountHelper;

  /// No description provided for @orderCartActionDiscountSuffix.
  ///
  /// In zh, this message translates to:
  /// **'折'**
  String get orderCartActionDiscountSuffix;

  /// No description provided for @orderCartActionChangePrice.
  ///
  /// In zh, this message translates to:
  /// **'變價'**
  String get orderCartActionChangePrice;

  /// No description provided for @orderCartActionChangePriceLabel.
  ///
  /// In zh, this message translates to:
  /// **'價錢'**
  String get orderCartActionChangePriceLabel;

  /// No description provided for @orderCartActionChangePriceHint.
  ///
  /// In zh, this message translates to:
  /// **'每項產品的價錢'**
  String get orderCartActionChangePriceHint;

  /// No description provided for @orderCartActionChangePricePrefix.
  ///
  /// In zh, this message translates to:
  /// **''**
  String get orderCartActionChangePricePrefix;

  /// No description provided for @orderCartActionChangePriceSuffix.
  ///
  /// In zh, this message translates to:
  /// **'元'**
  String get orderCartActionChangePriceSuffix;

  /// No description provided for @orderCartActionChangeCount.
  ///
  /// In zh, this message translates to:
  /// **'變更數量'**
  String get orderCartActionChangeCount;

  /// No description provided for @orderCartActionChangeCountLabel.
  ///
  /// In zh, this message translates to:
  /// **'數量'**
  String get orderCartActionChangeCountLabel;

  /// No description provided for @orderCartActionChangeCountHint.
  ///
  /// In zh, this message translates to:
  /// **'產品數量'**
  String get orderCartActionChangeCountHint;

  /// No description provided for @orderCartActionChangeCountSuffix.
  ///
  /// In zh, this message translates to:
  /// **'個'**
  String get orderCartActionChangeCountSuffix;

  /// No description provided for @orderCartActionFree.
  ///
  /// In zh, this message translates to:
  /// **'招待'**
  String get orderCartActionFree;

  /// No description provided for @orderCartActionDelete.
  ///
  /// In zh, this message translates to:
  /// **'刪除'**
  String get orderCartActionDelete;

  /// No description provided for @orderCartSnapshotEmpty.
  ///
  /// In zh, this message translates to:
  /// **'尚未點餐'**
  String get orderCartSnapshotEmpty;

  /// Total price of items in the cart
  ///
  /// In zh, this message translates to:
  /// **'總價：{price}'**
  String orderCartMetaTotalPrice(String price);

  /// Total number of items in the cart
  ///
  /// In zh, this message translates to:
  /// **'總數：{count}'**
  String orderCartMetaTotalCount(int count);

  /// Price of the product
  ///
  /// In zh, this message translates to:
  /// **'{price, select, 0{免費} other{{price}元}}'**
  String orderCartProductPrice(String price);

  /// No description provided for @orderCartProductIncrease.
  ///
  /// In zh, this message translates to:
  /// **'數量加一'**
  String get orderCartProductIncrease;

  /// No description provided for @orderCartProductDefaultQuantity.
  ///
  /// In zh, this message translates to:
  /// **'預設份量'**
  String get orderCartProductDefaultQuantity;

  /// Ingredients and quantities of each item in the product list when ordering
  ///
  /// In zh, this message translates to:
  /// **'{name}（{quantity}）'**
  String orderCartProductIngredient(String name, String quantity);

  /// Prompt to users during ordering if the selected product doesn't require ingredient settings
  ///
  /// In zh, this message translates to:
  /// **'{status, select, emptyCart{請選擇產品來設定其成分} differentProducts{請選擇相同的產品來設定其成分} noNeedIngredient{這個產品沒有可以設定的成分} other{UNKNOWN}}'**
  String orderCartIngredientStatus(String status);

  /// During ordering, select the ingredient to set the quantity
  ///
  /// In zh, this message translates to:
  /// **'請選擇成分來設定份量'**
  String get orderCartQuantityNotAble;

  /// No description provided for @orderCartQuantityLabel.
  ///
  /// In zh, this message translates to:
  /// **'{name}（{amount}）'**
  String orderCartQuantityLabel(String name, num amount);

  /// During ingredient setup, the quantity can be customized or set to default (no quantity used)
  ///
  /// In zh, this message translates to:
  /// **'預設值（{amount}）'**
  String orderCartQuantityDefaultLabel(num amount);

  /// No description provided for @orderCheckoutEmptyCart.
  ///
  /// In zh, this message translates to:
  /// **'請先進行點單。'**
  String get orderCheckoutEmptyCart;

  /// No description provided for @orderCheckoutActionStash.
  ///
  /// In zh, this message translates to:
  /// **'暫存'**
  String get orderCheckoutActionStash;

  /// No description provided for @orderCheckoutActionConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確認'**
  String get orderCheckoutActionConfirm;

  /// No description provided for @orderCheckoutStashTab.
  ///
  /// In zh, this message translates to:
  /// **'暫存'**
  String get orderCheckoutStashTab;

  /// No description provided for @orderCheckoutStashEmpty.
  ///
  /// In zh, this message translates to:
  /// **'目前無任何暫存餐點。'**
  String get orderCheckoutStashEmpty;

  /// No description provided for @orderCheckoutStashNoProducts.
  ///
  /// In zh, this message translates to:
  /// **'沒有任何產品'**
  String get orderCheckoutStashNoProducts;

  /// No description provided for @orderCheckoutStashActionCheckout.
  ///
  /// In zh, this message translates to:
  /// **'結帳'**
  String get orderCheckoutStashActionCheckout;

  /// No description provided for @orderCheckoutStashActionRestore.
  ///
  /// In zh, this message translates to:
  /// **'還原'**
  String get orderCheckoutStashActionRestore;

  /// No description provided for @orderCheckoutStashDialogCalculator.
  ///
  /// In zh, this message translates to:
  /// **'結帳計算機'**
  String get orderCheckoutStashDialogCalculator;

  /// No description provided for @orderCheckoutStashDialogRestoreTitle.
  ///
  /// In zh, this message translates to:
  /// **'還原暫存訂單'**
  String get orderCheckoutStashDialogRestoreTitle;

  /// No description provided for @orderCheckoutStashDialogRestoreContent.
  ///
  /// In zh, this message translates to:
  /// **'此動作將會覆蓋掉現在購物車內的訂單。'**
  String get orderCheckoutStashDialogRestoreContent;

  /// No description provided for @orderCheckoutStashDialogDeleteName.
  ///
  /// In zh, this message translates to:
  /// **'訂單'**
  String get orderCheckoutStashDialogDeleteName;

  /// No description provided for @orderCheckoutAttributeTab.
  ///
  /// In zh, this message translates to:
  /// **'顧客設定'**
  String get orderCheckoutAttributeTab;

  /// No description provided for @orderCheckoutAttributeNoteTitle.
  ///
  /// In zh, this message translates to:
  /// **'備註'**
  String get orderCheckoutAttributeNoteTitle;

  /// No description provided for @orderCheckoutAttributeNoteHint.
  ///
  /// In zh, this message translates to:
  /// **'一些關於此訂單的說明'**
  String get orderCheckoutAttributeNoteHint;

  /// No description provided for @orderCheckoutDetailsTab.
  ///
  /// In zh, this message translates to:
  /// **'訂單細項'**
  String get orderCheckoutDetailsTab;

  /// No description provided for @orderCheckoutDetailsCalculatorLabelPaid.
  ///
  /// In zh, this message translates to:
  /// **'付額'**
  String get orderCheckoutDetailsCalculatorLabelPaid;

  /// No description provided for @orderCheckoutDetailsCalculatorLabelChange.
  ///
  /// In zh, this message translates to:
  /// **'找錢'**
  String get orderCheckoutDetailsCalculatorLabelChange;

  /// Change given by the cashier after the customer's payment
  ///
  /// In zh, this message translates to:
  /// **'找錢：{change}'**
  String orderCheckoutDetailsSnapshotLabelChange(String change);

  /// No description provided for @orderCheckoutSnackbarPaidFailed.
  ///
  /// In zh, this message translates to:
  /// **'付額小於訂單總價，無法結帳。'**
  String get orderCheckoutSnackbarPaidFailed;

  /// No description provided for @orderObjectViewEmpty.
  ///
  /// In zh, this message translates to:
  /// **'查無點餐紀錄'**
  String get orderObjectViewEmpty;

  /// No description provided for @orderObjectViewChange.
  ///
  /// In zh, this message translates to:
  /// **'找錢'**
  String get orderObjectViewChange;

  /// Total price information after ordering
  ///
  /// In zh, this message translates to:
  /// **'訂單總價：{price}'**
  String orderObjectViewPriceTotal(String price);

  /// No description provided for @orderObjectViewPriceProducts.
  ///
  /// In zh, this message translates to:
  /// **'產品總價'**
  String get orderObjectViewPriceProducts;

  /// No description provided for @orderObjectViewPriceAttributes.
  ///
  /// In zh, this message translates to:
  /// **'顧客設定總價'**
  String get orderObjectViewPriceAttributes;

  /// No description provided for @orderObjectViewCost.
  ///
  /// In zh, this message translates to:
  /// **'成本'**
  String get orderObjectViewCost;

  /// No description provided for @orderObjectViewProfit.
  ///
  /// In zh, this message translates to:
  /// **'淨利'**
  String get orderObjectViewProfit;

  /// No description provided for @orderObjectViewPaid.
  ///
  /// In zh, this message translates to:
  /// **'付額'**
  String get orderObjectViewPaid;

  /// No description provided for @orderObjectViewNote.
  ///
  /// In zh, this message translates to:
  /// **'備註'**
  String get orderObjectViewNote;

  /// No description provided for @orderObjectViewDividerAttribute.
  ///
  /// In zh, this message translates to:
  /// **'顧客設定'**
  String get orderObjectViewDividerAttribute;

  /// No description provided for @orderObjectViewDividerProduct.
  ///
  /// In zh, this message translates to:
  /// **'產品資訊'**
  String get orderObjectViewDividerProduct;

  /// No description provided for @orderObjectViewProductPrice.
  ///
  /// In zh, this message translates to:
  /// **'總價'**
  String get orderObjectViewProductPrice;

  /// No description provided for @orderObjectViewProductCost.
  ///
  /// In zh, this message translates to:
  /// **'總成本'**
  String get orderObjectViewProductCost;

  /// No description provided for @orderObjectViewProductCount.
  ///
  /// In zh, this message translates to:
  /// **'總數'**
  String get orderObjectViewProductCount;

  /// No description provided for @orderObjectViewProductSinglePrice.
  ///
  /// In zh, this message translates to:
  /// **'單價'**
  String get orderObjectViewProductSinglePrice;

  /// No description provided for @orderObjectViewProductOriginalPrice.
  ///
  /// In zh, this message translates to:
  /// **'折扣前單價'**
  String get orderObjectViewProductOriginalPrice;

  /// No description provided for @orderObjectViewProductCatalog.
  ///
  /// In zh, this message translates to:
  /// **'產品種類'**
  String get orderObjectViewProductCatalog;

  /// No description provided for @orderObjectViewProductIngredient.
  ///
  /// In zh, this message translates to:
  /// **'成分'**
  String get orderObjectViewProductIngredient;

  /// No description provided for @orderObjectViewProductDefaultQuantity.
  ///
  /// In zh, this message translates to:
  /// **'預設'**
  String get orderObjectViewProductDefaultQuantity;

  /// No description provided for @analysisTab.
  ///
  /// In zh, this message translates to:
  /// **'統計'**
  String get analysisTab;

  /// No description provided for @analysisHistoryBtn.
  ///
  /// In zh, this message translates to:
  /// **'紀錄'**
  String get analysisHistoryBtn;

  /// No description provided for @analysisHistoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'訂單記錄'**
  String get analysisHistoryTitle;

  /// No description provided for @analysisHistoryTitleEmpty.
  ///
  /// In zh, this message translates to:
  /// **'查無點餐紀錄'**
  String get analysisHistoryTitleEmpty;

  /// No description provided for @analysisHistoryCalendarTutorialTitle.
  ///
  /// In zh, this message translates to:
  /// **'日曆'**
  String get analysisHistoryCalendarTutorialTitle;

  /// No description provided for @analysisHistoryCalendarTutorialContent.
  ///
  /// In zh, this message translates to:
  /// **'上下滑動可以調整週期單位，如月或週。\n左右滑動可以調整日期起訖。'**
  String get analysisHistoryCalendarTutorialContent;

  /// No description provided for @analysisHistoryExportBtn.
  ///
  /// In zh, this message translates to:
  /// **'匯出'**
  String get analysisHistoryExportBtn;

  /// No description provided for @analysisHistoryExportTutorialTitle.
  ///
  /// In zh, this message translates to:
  /// **'訂單資料匯出'**
  String get analysisHistoryExportTutorialTitle;

  /// No description provided for @analysisHistoryExportTutorialContent.
  ///
  /// In zh, this message translates to:
  /// **'把訂單匯出到外部，讓你可以做進一步分析或保存。\n你可以到「資料轉移」去匯出多日訂單。'**
  String get analysisHistoryExportTutorialContent;

  /// Order ID for specific order in the order list.
  ///
  /// In zh, this message translates to:
  /// **'編號：{id}'**
  String analysisHistoryOrderListMetaId(String id);

  /// Price of specific orders in the order list.
  ///
  /// In zh, this message translates to:
  /// **'售價：{price}'**
  String analysisHistoryOrderListMetaPrice(num price);

  /// Payment amount for specific orders in the order list.
  ///
  /// In zh, this message translates to:
  /// **'付額：{paid}'**
  String analysisHistoryOrderListMetaPaid(num paid);

  /// Net profit for specific orders in the order list.
  ///
  /// In zh, this message translates to:
  /// **'淨利：{profit}'**
  String analysisHistoryOrderListMetaProfit(num profit);

  /// Order ID for specific order in the order detailed page.
  ///
  /// In zh, this message translates to:
  /// **'編號：{id}'**
  String analysisHistoryOrderTitle(String id);

  /// No description provided for @analysisHistoryOrderNotFound.
  ///
  /// In zh, this message translates to:
  /// **'找不到相關訂單'**
  String get analysisHistoryOrderNotFound;

  /// No description provided for @analysisHistoryOrderDeleteDialog.
  ///
  /// In zh, this message translates to:
  /// **'確定要刪除 {name} 的訂單嗎？\n將不會復原收銀機和庫存資料。\n此動作無法復原。'**
  String analysisHistoryOrderDeleteDialog(String name);

  /// No description provided for @analysisGoalsTitle.
  ///
  /// In zh, this message translates to:
  /// **'本日總結'**
  String get analysisGoalsTitle;

  /// No description provided for @analysisGoalsCountTitle.
  ///
  /// In zh, this message translates to:
  /// **'訂單數'**
  String get analysisGoalsCountTitle;

  /// No description provided for @analysisGoalsCountDescription.
  ///
  /// In zh, this message translates to:
  /// **'訂單數反映了產品對顧客的吸引力。\n它代表了市場對你產品的需求程度，能幫助你了解何種產品或時段最受歡迎。\n高訂單數可能意味著你的定價策略或行銷活動取得成功，是商業模型有效性的指標之一。\n但要注意，單純追求高訂單數可能會忽略盈利能力。'**
  String get analysisGoalsCountDescription;

  /// No description provided for @analysisGoalsRevenueTitle.
  ///
  /// In zh, this message translates to:
  /// **'營收'**
  String get analysisGoalsRevenueTitle;

  /// No description provided for @analysisGoalsRevenueDescription.
  ///
  /// In zh, this message translates to:
  /// **'營收代表總銷售額，是業務規模的指標。\n高營收可能顯示了你的產品受歡迎且銷售良好，但營收無法反映出業務的可持續性和盈利能力。\n有時候，為了提高營收，公司可能會採取降價等策略，這可能會對公司的盈利能力造成影響。'**
  String get analysisGoalsRevenueDescription;

  /// No description provided for @analysisGoalsProfitTitle.
  ///
  /// In zh, this message translates to:
  /// **'淨利'**
  String get analysisGoalsProfitTitle;

  /// No description provided for @analysisGoalsProfitDescription.
  ///
  /// In zh, this message translates to:
  /// **'淨利是營業收入減去營業成本後的餘額，是公司能否持續經營的關鍵。\n盈利直接反映了營運效率和成本管理能力。\n不同於營收，盈利考慮了生意的開支，包括原料成本、人力、租金等，\n這是一個更實際的指標，能幫助你評估經營是否有效且可持續。'**
  String get analysisGoalsProfitDescription;

  /// No description provided for @analysisGoalsCostTitle.
  ///
  /// In zh, this message translates to:
  /// **'成本'**
  String get analysisGoalsCostTitle;

  /// No description provided for @analysisGoalsAchievedRate.
  ///
  /// In zh, this message translates to:
  /// **'利潤達成\n{rate}'**
  String analysisGoalsAchievedRate(String rate);

  /// No description provided for @analysisChartTitle.
  ///
  /// In zh, this message translates to:
  /// **'圖表分析'**
  String get analysisChartTitle;

  /// No description provided for @analysisChartTitleCreate.
  ///
  /// In zh, this message translates to:
  /// **'新增圖表'**
  String get analysisChartTitleCreate;

  /// No description provided for @analysisChartTitleUpdate.
  ///
  /// In zh, this message translates to:
  /// **'編輯圖表'**
  String get analysisChartTitleUpdate;

  /// No description provided for @analysisChartTitleReorder.
  ///
  /// In zh, this message translates to:
  /// **'排序圖表'**
  String get analysisChartTitleReorder;

  /// No description provided for @analysisChartTutorialTitle.
  ///
  /// In zh, this message translates to:
  /// **'圖表分析'**
  String get analysisChartTutorialTitle;

  /// No description provided for @analysisChartTutorialContent.
  ///
  /// In zh, this message translates to:
  /// **'透過圖表，你可以更直觀地看到數據變化。\n現在就開始設計圖表追蹤你的銷售狀況吧！。'**
  String get analysisChartTutorialContent;

  /// No description provided for @analysisChartCardEmptyData.
  ///
  /// In zh, this message translates to:
  /// **'沒有資料'**
  String get analysisChartCardEmptyData;

  /// No description provided for @analysisChartCardTitleUpdate.
  ///
  /// In zh, this message translates to:
  /// **'編輯圖表'**
  String get analysisChartCardTitleUpdate;

  /// No description provided for @analysisChartMetricName.
  ///
  /// In zh, this message translates to:
  /// **'{name, select, revenue{營收} cost{成本} profit{淨利} count{數量} other{UNKNOWN}}'**
  String analysisChartMetricName(String name);

  /// No description provided for @analysisChartTargetName.
  ///
  /// In zh, this message translates to:
  /// **'{name, select, order{訂單} catalog{產品種類} product{產品} ingredient{成分} attribute{顧客屬性} other{UNKNOWN}}'**
  String analysisChartTargetName(String name);

  /// No description provided for @analysisChartRangeYesterday.
  ///
  /// In zh, this message translates to:
  /// **'昨天'**
  String get analysisChartRangeYesterday;

  /// No description provided for @analysisChartRangeToday.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get analysisChartRangeToday;

  /// No description provided for @analysisChartRangeLastWeek.
  ///
  /// In zh, this message translates to:
  /// **'上週'**
  String get analysisChartRangeLastWeek;

  /// No description provided for @analysisChartRangeThisWeek.
  ///
  /// In zh, this message translates to:
  /// **'本週'**
  String get analysisChartRangeThisWeek;

  /// No description provided for @analysisChartRangeLast7Days.
  ///
  /// In zh, this message translates to:
  /// **'最近7日'**
  String get analysisChartRangeLast7Days;

  /// No description provided for @analysisChartRangeLastMonth.
  ///
  /// In zh, this message translates to:
  /// **'上月'**
  String get analysisChartRangeLastMonth;

  /// No description provided for @analysisChartRangeThisMonth.
  ///
  /// In zh, this message translates to:
  /// **'本月'**
  String get analysisChartRangeThisMonth;

  /// No description provided for @analysisChartRangeLast30Days.
  ///
  /// In zh, this message translates to:
  /// **'最近30日'**
  String get analysisChartRangeLast30Days;

  /// No description provided for @analysisChartRangeTabName.
  ///
  /// In zh, this message translates to:
  /// **'{name, select, day{日期} week{週} month{月} custom{自訂} other{UNKNOWN}}'**
  String analysisChartRangeTabName(String name);

  /// No description provided for @analysisChartModalNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'圖表名稱'**
  String get analysisChartModalNameLabel;

  /// No description provided for @analysisChartModalNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：每日營收'**
  String get analysisChartModalNameHint;

  /// No description provided for @analysisChartModalIgnoreEmptyLabel.
  ///
  /// In zh, this message translates to:
  /// **'忽略空資料'**
  String get analysisChartModalIgnoreEmptyLabel;

  /// No description provided for @analysisChartModalIgnoreEmptyHelper.
  ///
  /// In zh, this message translates to:
  /// **'某商品或指標在該時段沒有資料，則不顯示。'**
  String get analysisChartModalIgnoreEmptyHelper;

  /// No description provided for @analysisChartModalDivider.
  ///
  /// In zh, this message translates to:
  /// **'資料設定'**
  String get analysisChartModalDivider;

  /// No description provided for @analysisChartModalTypeLabel.
  ///
  /// In zh, this message translates to:
  /// **'圖表類型'**
  String get analysisChartModalTypeLabel;

  /// No description provided for @analysisChartModalTypeName.
  ///
  /// In zh, this message translates to:
  /// **'{name, select, cartesian{時序圖} circular{圓餅圖} other{UNKNOWN}}'**
  String analysisChartModalTypeName(String name);

  /// No description provided for @analysisChartModalMetricLabel.
  ///
  /// In zh, this message translates to:
  /// **'觀看指標'**
  String get analysisChartModalMetricLabel;

  /// No description provided for @analysisChartModalMetricHelper.
  ///
  /// In zh, this message translates to:
  /// **'根據不同目的，選擇不同指標類型。'**
  String get analysisChartModalMetricHelper;

  /// No description provided for @analysisChartModalTargetLabel.
  ///
  /// In zh, this message translates to:
  /// **'項目種類'**
  String get analysisChartModalTargetLabel;

  /// No description provided for @analysisChartModalTargetHelper.
  ///
  /// In zh, this message translates to:
  /// **'選擇圖表中要針對哪些資訊做分析。'**
  String get analysisChartModalTargetHelper;

  /// No description provided for @analysisChartModalTargetErrorEmpty.
  ///
  /// In zh, this message translates to:
  /// **'請選擇一個項目種類'**
  String get analysisChartModalTargetErrorEmpty;

  /// No description provided for @analysisChartModalTargetItemLabel.
  ///
  /// In zh, this message translates to:
  /// **'項目選擇'**
  String get analysisChartModalTargetItemLabel;

  /// No description provided for @analysisChartModalTargetItemHelper.
  ///
  /// In zh, this message translates to:
  /// **'你想要觀察哪些項目的變化，例如區間內某商品的數量。'**
  String get analysisChartModalTargetItemHelper;

  /// No description provided for @analysisChartModalTargetItemSelectAll.
  ///
  /// In zh, this message translates to:
  /// **'全選'**
  String get analysisChartModalTargetItemSelectAll;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return lookupAppLocalizations(locale);
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

Future<AppLocalizations> lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return app_localizations_en
          .loadLibrary()
          .then((dynamic _) => app_localizations_en.AppLocalizationsEn());
    case 'zh':
      return app_localizations_zh
          .loadLibrary()
          .then((dynamic _) => app_localizations_zh.AppLocalizationsZh());
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
