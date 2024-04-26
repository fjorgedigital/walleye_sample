# walleye_sample

A new Flutter project.

## Getting Started

This project is a Walleye Now app Demo built in flutter, focused on showcasing how subscription products are loaded from the App stores.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Notes

- The methods and routines for subscription are in `/lib/providers/subscription_provider.dart`
- [flutter_inapp_purchase](https://github.com/dooboolab-community/flutter_inapp_purchase), a flutter package is used to provide APIs to the native StoreKit APIS on IOS and Google Play Billing APIs on Android.
- iOS specific implementation of the package can be found [here](https://github.com/dooboolab-community/flutter_inapp_purchase/blob/main/ios/Classes/FlutterInappPurchasePlugin.m), See Line 65.
- For iOS project files, see the ios folder. Open in this folder `/ios/Runner` in Xcode to view the ios project

## Running the project

- [Setup flutter](https://docs.flutter.dev/)
- Run flutter build ipa to produce an Xcode build archive (.xcarchive file)  `/build/ios/archive/` directory and an App Store app bundle (.ipa file) in `/build/ios/ipa`.
