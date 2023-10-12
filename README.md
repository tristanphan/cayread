# Cayread

Cayread is a simple ebook reader designed for iOS and Android

## Table of Contents

* [Features](#features)
* [Project Status](#project-status)
* [Installing Cayread](#installing-cayread)
    * [iOS](#ios)
    * [Android](#android)
* [Building from Source](#building-from-source)
* [License](#license)

## Features

- Cross-platform compatibility with iOS and Android
- Support for multiple ebook formats, including EPUB, PDF, TXT, and CBZ
- Wiktionary integration for quick in-reader definitions and etymology references
- Reader theming, with different fonts

## Project Status

Cayread is currently in __active development__. As such, many features are not yet available.

Here's a *rough* roadmap of planned features and their progress:

| Feature                        | Progress |
|--------------------------------|----------|
| EPUB processing & injection    | ✅        |
| Catalog database system        | ✅        |
| Library frontend               | ✅        |
| Reader frontend                | 🚧       |
| Theming                        | 🚧       |
| Settings frontend              |          |
| Implementation documentation   |          |
| Wiktionary support             |          |
| Support for PDF, CBZ, etc.     |          |
| Third-party dictionary support |          |

## Installing Cayread

The app currently supports iOS, and Android

NOTE: a compiled version of the app (in the Releases section) will not be available until more features are implemented.
If you want a fresh version, you'll need to [build it](#build) to get an IPA or APK file.

### iOS

Currently, the only way to install without jailbreaking your device is through AltStore

1. Set Up [AltStore](https://altstore.io/)
2. Download the IPA file from Releases (or [build it yourself](#build)))
3. Install the file in AltStore

When sideloading the app from a free developer account, you'll need to refresh the app every seven days

### Android

Android support is untested, so if you encounter any issues,
please [open an issue](https://github.com/tristanphan/cayread/issues/new).

1. Download the IPA file from Releases (or [build it yourself](#build)))
2. Allow installing unknown apps in Settings, if necessary
3. Open the APK file to install the app

## Building from Source

To build for iOS, you need to have macOS and Xcode set up. To build for Android, you need
the [Android SDK](https://developer.android.com/studio) set up.

1. Install [Flutter](https://flutter.dev/docs/get-started/install) and [git](https://git-scm.com/)
    - Use `flutter doctor -v` to make sure everything works
2. Clone this repository and enter the directory
    - `git clone https://github.com/tristanphan/cayread`
    - `cd cayread`
3. Get dependencies with `flutter pub get`
4. Generate injectables with `flutter pub run build_runner build`
5. Build or Run (use `--debug` and `--release` as necessary)
    - Run on a device/simulator/emulator with `flutter run`
    - Build for iOS: `flutter build ipa`
        - This may require an iOS developer account. Here's a workaround to get an IPA file with a free account:
            - Use `flutter run` to run the app on an iOS simulator
            - Copy `build/ios/iphonesimulator/Runner.app` to new folder called `Payload`
            - Compress the Payload folder and change the extension to `.ipa`
    - Build for Android: `flutter build apk`
        - Debug build: `build/app/outputs/flutter-apk/app-debug.apk`
        - Release build: `build/app/outputs/flutter-apk/app-release.apk`
6. Install the app using steps from the [Install](#install) section

For iOS, you may need to set up signing information in Xcode (General -> Signing), then compile the app from within
Xcode. Then try `flutter build` or `flutter run` again.

## License

Ebook Reader is free and open source under the GNU General Public License v3.0.<br> Read more about
that [here](LICENSE).

    This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

