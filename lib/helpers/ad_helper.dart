import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2913289160482051/4762025053';
    } else if (Platform.isIOS) {
      return 'iOS-banner-id'; // iOS için banner ID'nizi buraya ekleyin
    } else {
      throw UnsupportedError('Desteklenmeyen platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2913289160482051/2307252104';
    } else if (Platform.isIOS) {
      return 'iOS-interstitial-id';
    } else {
      throw UnsupportedError('Desteklenmeyen platform');
    }
  }
}
