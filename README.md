<!--

This source file is part of the Stanforf CardinalKit Template Application project

SPDX-FileCopyrightText: 2023 Stanford University

SPDX-License-Identifier: MIT

-->

# Template Application

This repository contains the Stanforf CardinalKit Template Application. It serves as a template repository for projects requiering a mobile application using a continous integration and continous delivery setup.

## Continous Delivery Workflows

### Beta Deployment

The Beta Deployment workflow is triggered when a new commit is added to the main branch. 

It first runs the Build and Test workflow to ensure all tests are passing.
Once the Build and Test workflow passes, it builds the iOS application so it can be archived and sent to [TestFlight](https://developer.apple.com/testflight/) for internal beta deployment.

### Build and Test

The Build and Test workflow builds and tests the iOS application, shared Swift package, and web service. It runs all unit and user interface (UI) tests defined in the targets. The iOS application is tested on the iOS simulator on macOS. The shared and web service Swift packages are tested on Linux and macOS as well as in release and debug configuration to demonstrate all possible variations. 

### SwiftLint

The Swiftlint workflow is triggered by every pull request (PR) and checks if the files found in the diff contain any [SwiftLint](https://github.com/realm/SwiftLint) violations.
You can change the SwiftLint configuration in the `.swiftlint.yml` file found at the root of this repository.

## Continous Delivery Setup

It is a prerequiesite to have access to a Apple Developer Account that allows [TestFlight](https://developer.apple.com/testflight/) releases and create a app in [App Store Connect](https://appstoreconnect.apple.com) that matches the bundle identifier you have defined in the App project.

### App Store Connect Access

The [TestFlight](https://developer.apple.com/testflight/) deployment requires access to the App Store Connect API using an API key. Please follow the Apple instructions to [Creating API Keys for the App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api). The key needs the `App Manager` access role.
Store the following information in the following GitHub secrets:
- `APPLE_ID`: The Apple ID you use to access the App Store Connect API.
- `APP_STORE_CONNECT_ISSUER_ID`: The issuer ID of the App Store Connect API is displayed in the App Store Connect API keys section.
- `APP_STORE_CONNECT_API_KEY_ID`: The key ID of the API key created in the App Store Connect API keys section.
- `APP_STORE_CONNECT_API_KEY_BASE64`: The content of the key created in App Store Connect condensed into a Base64 representation, e.g., using `base64 -i AuthKey_ABCDEFGHIJ.p8 | pbcopy`.

### Apple Xcode Certificate and Provisioning Profile

The GitHub Action imports the Apple certificate and provisioning profile from the GitHub secrets and installs them in a local KeyChain on the GitHub runner instances.
Please follow the GitHub instructions to [Installing an Apple certificate on macOS runners for Xcode development](https://docs.github.com/en/enterprise-server@3.4/actions/deployment/deploying-xcode-applications/installing-an-apple-certificate-on-macos-runners-for-xcode-development).

Obtaining the Apple provisioning profile requires you to follow the following steps:
1. Register the app identifier in the [Apple Developer Account Identifiers section](https://developer.apple.com/account/resources/identifiers/list) using the bundle identifier for your application, e.g., `com.schmiedmayer.continousdelivery`.
2. Create an **AppStore** distribution provisioning profile in the [Apple Developer Account Profiles section](https://developer.apple.com/account/resources/profiles/list) using the app identifier you have created in the previous step.
3. Download the provisioning profile and convert it to a Base64 representation as detailed in [Installing an Apple certificate on macOS runners for Xcode development](https://docs.github.com/en/enterprise-server@3.4/actions/deployment/deploying-xcode-applications/installing-an-apple-certificate-on-macos-runners-for-xcode-development) and add it as the value for the `BUILD_PROVISION_PROFILE_BASE64` secret.

After following the setup steps detailed in [Installing an Apple certificate on macOS runners for Xcode development](https://docs.github.com/en/enterprise-server@3.4/actions/deployment/deploying-xcode-applications/installing-an-apple-certificate-on-macos-runners-for-xcode-development) and obtaining the Apple provisioning profile as described above, you should have the following secrets configured in the repository settings:
- `BUILD_CERTIFICATE_BASE64`: The Base64 version of the Apple signing certificate to build your iOS application.
- `P12_PASSWORD`: The password for the Apple signing certificate.
- `BUILD_PROVISION_PROFILE_BASE64`: The Base64 version of the Apple provisioning profile to build your iOS application.
- `KEYCHAIN_PASSWORD`: A password for the keychain that will be created on the runner instance.

Be sure that you update the name of the provisioning profile in the `Gymfile` and update the app name, bundle identifyer, Xcode project name, paths, and other settings in the fastlane files when modifying the template to your needs!

### Swift Package and Fastlane Update ACCESS_TOKEN

The [Swift Package and Fastlane Update workflow](https://github.com/PSchmiedmayer/ContinousDelivery/blob/main/.github/workflows/update.yml) requires an `ACCESS_TOKEN` secret: a GitHub Personal Access Token (PAT) allowing write access to the repository.
We suggest using a bot account to create the access token. Using the PAT triggers the GitHub Actions in the create PR. [The GitHub documentation provides instructions on creating a PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token). The [scrop of the token](https://docs.github.com/en/developers/apps/building-oauth-apps/scopes-for-oauth-apps) can be limited to the `public_repo` scope for public repositories or the `repo` scrope for private repositories as well as the `workflow` scope.

Removing the `token` input in the GitHub action workflow results in using the default `GITHUB_TOKEN` and the GitHub Action bot account that does not trigger any possible merge checks in the newly created PR.

### Contributors

This project is based on [ContinousDelivery Example by Paul Schmiedmayer](https://github.com/PSchmiedmayer/ContinousDelivery). You can find a list of contributors in the `CONTRIBUTORS.md` file.
