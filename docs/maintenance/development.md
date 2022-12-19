# 本地端開發

正常程式碼開發只需要：

    pub get

就可以安裝你需要的東西了，但如果你想要建置應用程式，你需要三個東西：

-   `/android/app/<any-name>.jks`，這是用來存放你的鑰匙的，確保你就是這個應用程式的擁有者，你可以這樣產生：

```bash
$ keytool -genkey -v -keystore android/my-jks.jks -alias alias_name -keyalg RSA -keysize 2048 -validity 10000
Enter keystore password: <輸入你的密碼>
Re-enter new password: <輸入你的密碼>
What is your first and last name?
  [Unknown]:  
What is the name of your organizational unit?
  [Unknown]:  
What is the name of your organization?
  [Unknown]:  
What is the name of your City or Locality?
  [Unknown]:  
What is the name of your State or Province?
  [Unknown]:  
What is the two-letter country code for this unit?
  [Unknown]:  
Is CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, ST=Unknown, C=Unknown correct?
  [no]:  y

Generating 2,048 bit RSA key pair and self-signed certificate (SHA256withRSA) with a validity of 10,000 days
        for: CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, ST=Unknown, C=Unknown
[Storing android/app/my-jks.jks]
```

!!! info "位置"

    產生的 keystore 請放在 `/android/app/` 資料夾底下！

-   `/android/key.properties`，用來告訴建置應用程式時，你的鑰匙放哪裡，他裡面需要這些東西（依照上述產生範例）：
    -   `keyAlias=alias_name`
    -   `keyPassword=<輸入你的密碼>`，keyPassword 如果你沒特別設定，預設和 storePassword 一樣
    -   `storeFile=my-jks.jks`
    -   `storePassword=<輸入你的密碼>`
-   `/android/app/google-services.json`，你可以到 [Firebase Console](https://console.firebase.google.com/) 去產生，
    但是記得要在 *專案設定* 裡面去設定剛剛產生的金鑰 SHA 憑證指紋，你可以這樣輸出：

```bash
$ keytool -list -keystore android/my-jks.jks -alias alias_name
Enter keystore password:
alias_name, Dec 18, 2022, PrivateKeyEntry, 
Certificate fingerprint (SHA-256): B4:D1:3E:F5:8A:4C:20:07:30:16:4A:01:59:4A:4F:01:39:2C:62:C7:6B:EB:2B:89:3D:48:63:4D:59:D8:A1:9C
```

-   最後請更改 `/lib/firebase_compatible_options.dart` 裡面最下面的 `androidDebug` ID。
    你可以 `dart pub global activate flutterfire_cli` 安裝指令套件後 `flutterfire configure`，
    然後把產生的檔案的設定資訊複製到 `firebase_compatible_options.dart` 中。

## 測試

如果你想要測試，你可以

    flutter test

如果想要測試加上 coverage，你可以

    flutter test --coverage

最後產出 `./coverage/lconv.info` 後就可以

    genhtml coverage/lcov.info -o coverage/html
