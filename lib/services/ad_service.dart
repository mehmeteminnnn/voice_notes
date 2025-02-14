import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../helpers/ad_helper.dart';

class AdService {
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  bool _isLoadingAd = false;

  void loadInterstitialAd() {
    if (_isLoadingAd) return;
    _isLoadingAd = true;

    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _isLoadingAd = false;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _isInterstitialAdReady = false;
              ad.dispose();
              loadInterstitialAd(); // Yeni reklam yükle
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _isInterstitialAdReady = false;
              ad.dispose();
              loadInterstitialAd(); // Yeni reklam yükle
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          _isLoadingAd = false;
        },
      ),
    );
  }

  Future<bool> showInterstitialAd() async {
    if (!_isInterstitialAdReady || _interstitialAd == null) {
      return false;
    }

    try {
      await _interstitialAd!.show();
      return true;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
} 