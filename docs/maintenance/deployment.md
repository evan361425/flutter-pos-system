# Deployment Process

Divided into three environments:

- `internal`: For internal testing.
- `beta`: For external testing. The same files will be pushed to `promote_to_production`.
- `promote_to_production`: Pushes the `beta` version to production.

Deployment steps for each environment are as follows:

- `internal`
  1. Run `make bump` and input the desired version update.
- `beta`
  1. Run `make bump-beta`.
- `promote_to_production`
  1. Publish the [draft release](https://github.com/evan361425/flutter-pos-system/releases) on GitHub.
  2. After confirming everything is fine, you can clean up old tags: `make clean-version`.
