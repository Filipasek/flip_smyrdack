import 'package:flip_smyrdack/models/user_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:flip_smyrdack/ad_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // late BannerAd _ad;
  bool _isAdLoaded = false;
  String get bannerAdUnitId {
    if (kDebugMode)
      return MobileAds.bannerAdTestUnitId;
    else
      return 'ca-app-pub-9537370157330943/2383089090';
  }

  @override
  void initState() {
    super.initState();

    // _ad = BannerAd(
    //   adUnitId: AdHelper.bannerAdUnitId,
    //   size: AdSize.banner,
    //   request: AdRequest(),
    //   listener: BannerAdListener(
    //     onAdLoaded: (_) {
    //       setState(() {
    //         _isAdLoaded = true;
    //       });
    //     },
    //     onAdFailedToLoad: (ad, error) {
    //       // Releases an ad resource when it fails to load
    //       ad.dispose();

    //       print('Ad load failed (code=${error.code} message=${error.message})');
    //     },
    //   ),
    // );

    // _ad.load();
  }

  @override
  void dispose() {
    // _ad.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return GestureDetector(
    //   onTap: () {
    //     FocusScopeNode currentFocus = FocusScope.of(context);
    //     if (!currentFocus.hasPrimaryFocus) {
    //       currentFocus.unfocus();
    //     }
    //   },
    //   child: Scaffold(
    //     backgroundColor: Theme.of(context).primaryColor,
    //     body: Container(
    //       child: LoginForm(),
    //     ),
    //   ),
    // );
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 150.0, left: 15.0),
            child: Text(
              'Flip&\nSmyrdack',
              style: GoogleFonts.comfortaa(
                wordSpacing: 20.0,
                color: Theme.of(context).textTheme.headline5!.color,
                fontSize: 60.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: SizedBox(height: 0.0, width: double.infinity)),
          Container(
            padding: EdgeInsets.only(bottom: 20.0),
            child: FlatButton(
              onPressed: () {
                //TODO: maybe show loading
                AuthService.signInWithGoogle();
              },
              child: Text(
                'Zaloguj się poprzez Google',
                style: TextStyle(
                  // color: Provider.of<ColorData>(context).secondaryTextColor,
                  color: Theme.of(context).textTheme.bodyText2!.color,
                ),
              ),
            ),
          ),
          // Container(
          //   child: AdWidget(ad: _ad),
          //   width: _ad.size.width.toDouble(),
          //   height: 72.0,
          //   alignment: Alignment.center,
          // ),
          Provider.of<UserData>(context, listen: false).showAds ?? true
              ? BannerAd(
                  unitId: bannerAdUnitId,
                  size: BannerSize.ADAPTIVE,
                  loading: Center(child: Text('Ładowanie reklamy')),
                  error: Center(child: Text('Brak reklamy. Na nasz koszt :)')),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
