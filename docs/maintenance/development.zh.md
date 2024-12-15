# 本地端開發

因為一些隱私權問題，我們建置了私有工具 `flutter-pos-packages`，
在開始開發前，必須先替換成模擬工具：

    sed -i.bk 's/flutter-pos-packages$/flutter-pos-packages-mock/' pubspec.yaml
    rm -f pubspec.yaml.bk

接著

    flutter pub get

就可以安裝你需要的東西了，但如果你想要建置應用程式，你需要三個東西：

- `/android/<any-name>.jks`，這是用來存放你的鑰匙的，確保你就是這個應用程式的擁有者，你可以這樣產生：

```bash title="設定好你的 my-jks.jks"
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

```bash title="設定好你的 key.properties"
printf "keyAlias=%s\nkeyPassword=%s\nstoreFile=%s\nstorePassword=%s" \
  'possystem' \
  'possystem' \
  'my-jks.jks' \
  'possystem' > android/key.properties
```

- `/android/app/google-services.json`，
  你可以到 [Firebase Console](https://console.firebase.google.com/) 去產生，
  但是記得要在 *專案設定* 裡面去設定剛剛產生的金鑰 SHA 憑證指紋，你可以這樣輸出：

```bash title="取得你的 fingerprint"
$ keytool -list -keystore android/app/my-jks.jks --storepass possystem
Keystore type: PKCS12
Keystore provider: SUN

Your keystore contains 1 entry

mykey, May 18, 2024, PrivateKeyEntry, 
Certificate fingerprint (SHA-256): 6F:14:57:54:CC:26:0A:4C:70:E3:28:1D:CE:D0:73:3F:72:19:49:96:8F:9A:1B:31:A5:E2:96:E4:44:14:E1:A1
```

- 最後請更改 `/lib/firebase_compatible_options.dart` 裡面最下面的 `androidDebug` 設定。
  1. 安裝指令套件：`dart pub global activate flutterfire_cli`；
  2. 產生指定設定檔：`flutterfire configure`；
  3. 把產生的檔案的設定資訊複製到 `firebase_compatible_options.dart`。

## 測試

在開始執行測試之前，你可以先把 mock 檔案準備好：

    make mock

當想要開始測試，你可以：

    make test

如果想要測試加上 coverage，你可以：

    make test-coverage

最後產出的覆蓋率就可以打開以網頁格式打開：

    open coverage/html/index.html
