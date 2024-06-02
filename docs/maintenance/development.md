# Local Development

For regular code development, simply run:

    flutter pub get

This will install the necessary dependencies. However, if you want to build the application, you need three things:

- `/android/<any-name>.jks`: This is for storing your keys to ensure ownership of the application. You can generate it with:

```bash
# Assuming <any-name> is my-jks
keytool -genkey -v -keystore android/app/my-jks.jks \
  -alias possystem \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass possystem \
  -dname 'CN=possystem, OU=possystem, O=possystem, L=Unknown, ST=Unknown, C=Unknown'
```

- `/android/key.properties`: This file tells the build process where your key is located. It should contain the following (based on the example above):
  - `keyAlias=possystem`
  - `keyPassword=possystem` (If not specifically set, it defaults to the same as storePassword)
  - `storeFile=my-jks.jks`
  - `storePassword=possystem`

```bash
printf "keyAlias=%s\nkeyPassword=%s\nstoreFile=%s\nstorePassword=%s" \
  'possystem' \
  'possystem' \
  'my-jks.jks' \
  'possystem' > android/key.properties
```

- `/android/app/google-services.json`: This can be generated from the [Firebase Console](https://console.firebase.google.com/). Remember to configure the SHA certificate fingerprint in *Project Settings* using:

```bash
$ keytool -list -keystore android/app/my-jks.jks --storepass possystem
Keystore type: PKCS12
Keystore provider: SUN

Your keystore contains 1 entry

mykey, May 18, 2024, PrivateKeyEntry, 
Certificate fingerprint (SHA-256): 6F:14:57:54:CC:26:0A:4C:70:E3:28:1D:CE:D0:73:3F:72:19:49:96:8F:9A:1B:31:A5:E2:96:E4:44:14:E1:A1
```

- Finally, update the `androidDebug` setting at the bottom of `/lib/firebase_compatible_options.dart`. You can install the command-line tool with `dart pub global activate flutterfire_cli` and then run `flutterfire configure`. Copy the generated configuration into `firebase_compatible_options.dart`.

## Testing

Before running tests, prepare the mock files:

    make mock

To start testing:

    make test

To run tests with coverage:

    make test-coverage

The generated coverage report can be viewed in a web format:

    open coverage/html/index.html
