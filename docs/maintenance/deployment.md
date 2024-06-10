# Deployment Process

Divided into three environments (or `lane` in Fastlane):

- `internal`: For internal testing.
- `beta`: For external testing. The same files will be pushed to `promote_to_production`.
- `promote_to_production`: Pushes the `beta` version to production.

Deployment steps for each environment are as follows:

- `internal`: run `make bump-dev` and there will be two different input:
  1. If we are bumping for new version, enter new tag, ex. `1.2.3`.
  2. If we are bumping build code only, enter empty text.
- `beta`: run `make bump`.
- `promote_to_production`: publish the
  [draft release](https://github.com/evan361425/flutter-pos-system/releases) on GitHub.
