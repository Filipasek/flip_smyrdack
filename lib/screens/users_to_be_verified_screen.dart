import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/user_screen.dart';
import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
// import 'package:flip_smyrdack/ad_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

class UsersToBeVerifiedScreen extends StatefulWidget {
  @override
  _UsersToBeVerifiedScreenState createState() =>
      _UsersToBeVerifiedScreenState();
}

class _UsersToBeVerifiedScreenState extends State<UsersToBeVerifiedScreen> {
  static final _kAdIndex = 1;
  String get bannerAdUnitId {
    if (kDebugMode)
      return MobileAds.bannerAdTestUnitId;
    else
      return 'ca-app-pub-9537370157330943/3269575605';
  }

  bool _isAdLoaded = false;
  // late BannerAd _ad;
  int _getDestinationItemIndex(int rawIndex) {
    if (rawIndex >= _kAdIndex) {
      return rawIndex - 1;
    }
    return rawIndex;
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
    // TODO: Dispose a BannerAd object
    // _ad.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String error = '';
    if (!kIsWeb)
      FirebaseCrashlytics.instance
          .setCustomKey("screen name", 'Users To Be Verified');

    List usersList = Provider.of<UserData>(context, listen: false).usersList!;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Wybierz użytkownika'),
      ),
      body: ListView.builder(
        itemCount: usersList.length + (_isAdLoaded ? 1 : 1),
        itemBuilder: (BuildContext context, int index) {
          if (index == _kAdIndex) {
            // return Container(
            //   child: AdWidget(ad: _ad),
            //   width: _ad.size.width.toDouble(),
            //   height: 72.0,
            //   alignment: Alignment.center,
            // );
            return Provider.of<UserData>(context, listen: false).showAds!
                ? BannerAd(
                    unitId: bannerAdUnitId,
                    size: BannerSize.ADAPTIVE,
                    loading: Center(child: Text('Ładowanie reklamy')),
                    error:
                        Center(child: Text('Brak reklamy. Na nasz koszt :)')),
                  )
                : SizedBox();
          } else {
            String userId = '';
            String name = '';
            try {
              name = Provider.of<UserData>(context, listen: false)
                          .usersToBeVerified[
                      usersList[_getDestinationItemIndex(index)].toString()]
                  ['name'];
              userId = Provider.of<UserData>(context, listen: false)
                          .usersToBeVerified[
                      usersList[_getDestinationItemIndex(index)].toString()]
                  ['userId'];
            } catch (e) {
              name = 'błąd';
              userId = 'błąd';
              error = e.toString();
              // if (mounted) {
              //   WidgetsBinding.instance!.addPostFrameCallback((_) {
              //     ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     backgroundColor: Color.fromRGBO(249, 101, 116, 1),
                      //     behavior: SnackBarBehavior.floating,
                      //     content: Text(
                      //       error,
                      //     ),
                      //     duration: Duration(
                      //         seconds: ((error.length) / 6).round() + 5),
                      //   ),
                      // );
              //     // Add Your Code here.
              //   });
              // }
            }

            // print(Provider.of<UserData>(context, listen: false)
            //     .usersToBeVerified!);
            // print('-----');
            // String name = "Filipo";

            // String userId = '1WSldr9OfeRJUtA2uLvXrUlOTyS2';
            return FlatButton.icon(
              onPressed: error != ''
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Color.fromRGBO(249, 101, 116, 1),
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            error,
                          ),
                          duration: Duration(
                              seconds: ((error.length) / 6).round() + 5),
                        ),
                      );
                    }
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) {
                            return UserScreen(userId);
                          },
                        ),
                      );
                    },
              height: 60.0,
              icon: Icon(
                error != '' ? Icons.person_off_rounded : Icons.person_rounded,
                size: 35.0,
                color: Theme.of(context).accentColor,
              ),
              label: Text(
                name,
                style: TextStyle(
                  fontSize: 25.0,
                  color: error != ''
                      ? Color.fromRGBO(249, 101, 116, 1)
                      : Theme.of(context).textTheme.headline5!.color,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
