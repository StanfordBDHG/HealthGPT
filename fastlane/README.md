fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios test

```sh
[bundle exec] fastlane ios test
```

Build and test

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Screenshots

### ios codeql

```sh
[bundle exec] fastlane ios codeql
```

CodeQL

### ios build

```sh
[bundle exec] fastlane ios build
```

Build app

### ios archive

```sh
[bundle exec] fastlane ios archive
```

Archive app

### ios signin

```sh
[bundle exec] fastlane ios signin
```

Sign in to the App Store Connect API

### ios deploy

```sh
[bundle exec] fastlane ios deploy
```

Publish a release to TestFlight or the App Store depending on the environment

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
