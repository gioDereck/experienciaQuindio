import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:travel_hour/utils/app_constants.dart';

class CustomAdWidget extends StatefulWidget {
  const CustomAdWidget({super.key});

  @override
  _CustomAdWidgetState createState() => _CustomAdWidgetState();
}

class _CustomAdWidgetState extends State<CustomAdWidget> {
  late BannerAd bannerAd;
  bool isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    loadBannerAd();
  }

  void loadBannerAd() {
    bannerAd = BannerAd(
      adUnitId: AppConstants.adUnitId, // 'ca-app-pub-3940256099942544/6300978111', // Replace with your ad unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (kDebugMode) {
            print('Ad failed to load: $error');
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return AppConstants.isAdAvailable && isAdLoaded
    //     ? Center(
    //         child: Container(
    //           margin: EdgeInsets.only(bottom: 15.h),
    //           alignment: Alignment.center,
    //           width: bannerAd.size.width.toDouble(),
    //           height: bannerAd.size.height.toDouble(),
    //           child: AdWidget(ad: bannerAd),
    //         ),
    //       )
    //     : const SizedBox.shrink();
    return const SizedBox.shrink();
  }
}

// 1. add package google_mobile_ads: ^2.4.0
// 2. add classpath 'com.google.gms:google-services:4.3.3' to android/build.gradle
// 3. add id 'com.google.gms.google-services' to android/app/build.gradle
// 4. initialize MobileAds.instance.initialize(); to main.dart
// 5. add <key>GADApplicationIdentifier</key> <string>ca-app-pub-3295304758970401~2429283870</string> to info.plist
// 6. add <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="ca-app-pub-3940256099942544~3347511713"/> to main/androidmanifest.xml