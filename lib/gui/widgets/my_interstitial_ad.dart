import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../services/service_locator.dart';
import '../../utils/config.dart';
import '../../view_models/this_application_view_model.dart';

class MyInterstitialAd{
  static int maxFailedLoadAttempts = 3;
  static InterstitialAd? _interstitialAd;
  static int _numInterstitialLoadAttempts = 0;
  //thisappmodel
  static ThisApplicationViewModel thisApplicationModel = serviceLocator<ThisApplicationViewModel>();
  static void createInterstitialAd() {
    // check if settings has been set to show ads
    if(thisApplicationModel.settings?.showAds == null || !thisApplicationModel.settings!.showAds!) {
      return;
    }
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? Config.androidInterstitialAdUnitId
            : Config.iosInterstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              createInterstitialAd();
            }
          },
        ));
  }

  static void showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  static void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}