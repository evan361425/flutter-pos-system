# 本地端開發

正常程式碼開發只需要：

    flutter pub get

就可以安裝你需要的東西了，但如果你想要建置應用程式，你需要三個東西：

- `/android/<any-name>.jks`，這是用來存放你的鑰匙的，確保你就是這個應用程式的擁有者，你可以這樣產生：

```bash
# 假設 <any-name> 為 my-jks
keytool -genkey -v -keystore android/app/my-jks.jks \
  -alias possystem \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass possystem \
  -dname 'CN=possystem, OU=possystem, O=possystem, L=Unknown, ST=Unknown, C=Unknown'
```

- `/android/key.properties`，用來告訴建置應用程式時，你的鑰匙放哪裡，他裡面需要這些東西（依照上述產生範例）：
  - `keyAlias=possystem`
  - `keyPassword=possystem`，keyPassword 如果你沒特別設定，預設和 storePassword 一樣
  - `storeFile=my-jks.jks`
  - `storePassword=possystem`

```bash
printf "keyAlias=%s\nkeyPassword=%s\nstoreFile=%s\nstorePassword=%s" \
  'possystem' \
  'possystem' \
  'my-jks.jks' \
  'possystem' > android/key.properties
```

- `/android/app/google-services.json`，
  你可以到 [Firebase Console](https://console.firebase.google.com/) 去產生，
  但是記得要在 *專案設定* 裡面去設定剛剛產生的金鑰 SHA 憑證指紋，你可以這樣輸出：

```bash
$ keytool -list -keystore android/app/my-jks.jks --storepass possystem
Keystore type: PKCS12
Keystore provider: SUN

Your keystore contains 1 entry

mykey, May 18, 2024, PrivateKeyEntry, 
Certificate fingerprint (SHA-256): 6F:14:57:54:CC:26:0A:4C:70:E3:28:1D:CE:D0:73:3F:72:19:49:96:8F:9A:1B:31:A5:E2:96:E4:44:14:E1:A1
```

- 最後請更改 `/lib/firebase_compatible_options.dart` 裡面最下面的 `androidDebug` 設定。
  你可以 `dart pub global activate flutterfire_cli` 安裝指令套件後 `flutterfire configure`，
  然後把產生的檔案的設定資訊複製到 `firebase_compatible_options.dart` 中。

## 測試

在開始執行測試之前，你可以先把 mock 檔案準備好：

    make mock

當想要開始測試，你可以：

    make test

如果想要測試加上 coverage，你可以：

    make test-coverage

最後產出的覆蓋率就可以打開以網頁格式打開：

    open coverage/html/index.html

## 建立藍牙虛擬裝置

為了測試藍牙相關功能，根據[官網建議](https://developer.android.com/training/wearables/apps/test-bluetooth-audio)，
需要建立虛擬裝置才能和 Android 的虛擬裝置連結。

透過 [Android Studio 建議的做法](https://developer.android.com/studio/run/emulator-commandline)，
找到你的 emulator 指令後，啟動你的虛擬機。
以我的例子來說，就是 `Pixel_8_API_34`：

```bash
# 注意前綴的 `@`
emulator @Pixel_8_API_34 -no-boot-anim -packet-streamer-endpoint default
```

??? tip "Flag 代表的意思"
    - `-no-boot-anim` 可以關閉啟動動畫，單純想省計算資源而已；
    - `-packet-streamer-endpoint` 讓虛擬機透過 [netsimd](https://google.github.io/bumble/hive/index.html) 去建立對外溝通。

接著下載 alpha 版本的虛擬裝置工具 [bumble](https://google.github.io/bumble)：

```bash
git clone https://github.com/google/bumble
```

之所以要把他 clone 下來是因為裡面已經寫好一些範例了，
如果你有興趣可以透過 python 依賴，自己撰寫相關邏輯：

```bash
cd bumble && python3 -m pip install "."
```

!!! note "建議安裝做法"
    我自己習慣使用 [pipenv](https://pipenv.pypa.io/en/latest/) 做事，
    可以把系統 python 和專案開發隔絕開來。

最後啟動 bumble 的 RFComm Server 應用程式，模擬印表機：

```bash
python run_rfcomm_server.py device1.json android-netsim 8080 00001101-0000-1000-8000-00805F9B34FB

cd ~/Library/Android/sdk/platform-tools
./adb logcat -c && ./adb shell dumpsys batterystats --reset
./adb bugreport ~/Downloads
LC_CTYPE=C sed -n "/BEGIN:BTSNOOP_LOG_SUMMARY/,/END:BTSNOOP_LOG_SUMMARY/p " ~/Downloads/bugreport/dumpstate-2024-10-02-19-58-20.txt | egrep -av "BTSNOOP_LOG_SUMMARY" | python3 btsnooz.py > hci.log
```
