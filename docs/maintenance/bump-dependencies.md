# Update Dependencies

There are three types:

- dependencies: Direct dependencies
- dev_dependencies: Development environment dependencies
- transitive: Dependencies of the dependencies

## How to Check Which Packages Need Updating

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

Note the following:

- `Current`: The current version
- `Upgradable`: The highest version upgradable according to [version constraints](https://dart.dev/tools/pub/dependencies#version-constraints)
- `Resolvable`: The highest version upgradable without conflicting with the current environment (mainly Dart/Flutter version)
- `Latest`: The latest version of the package

## How to Upgrade

After identifying the version to upgrade to:

    flutter pub upgrade some_package

This method also upgrades transitive dependencies.

### After Updating

Remember to rerun the mock process, as new versions of packages may introduce new APIs:

    make mock

## Platforms

Instructions for each platform.

### Android

Gradle version mush above Flutter's minimum supported version:

```bash
# android/gradle/wrapper/gradle-wrapper.properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.14.6-bin.zip
# android/gradle.properties
androidGradlePluginVersion=8.11.2
# android/settings.gradle
# update these package
com.google.gms.google-services
com.google.firebase.crashlytics"
com.google.firebase.firebase-perf
org.jetbrains.kotlin.android
# Bash
cd android
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
java -version
./gradlew clean
./gradlew wrapper --gradle-version 8.14.6
```
