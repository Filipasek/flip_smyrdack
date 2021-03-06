import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flip_smyrdack/getters/weather_data.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/models/weather_data_model.dart';
import 'package:flip_smyrdack/screens/add_trip.dart';
import 'package:flip_smyrdack/screens/details_screen.dart';
import 'package:flip_smyrdack/screens/home_screen.dart';
import 'package:flip_smyrdack/screens/my_account_screen.dart';
import 'package:flip_smyrdack/screens/users_to_be_verified_screen.dart';
import 'package:flip_smyrdack/screens/verify_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flip_smyrdack/ad_helper.dart';
import 'package:in_app_review/in_app_review.dart';

// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:timeago/timeago.dart' as timeago;

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ExpansionTileCardState> cardA = new GlobalKey();
  bool isReviewAvailable = false;
  bool updateReady = false;
  Future<void> checkForUpdate() async {
    if (!kIsWeb)
      await InAppUpdate.checkForUpdate().then((info) {
        if (info.updateAvailability ==
            UpdateAvailability.updateAvailable) if (mounted) {
          setState(() {
            updateReady = true;
          });
        }
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color.fromRGBO(249, 101, 116, 1),
            behavior: SnackBarBehavior.floating,
            content: Text(
              e.toString(),
            ),
            duration:
                Duration(seconds: ((e.toString().length) / 6).round() + 5),
          ),
        );
      });
    bool isRevReady = kIsWeb ? false : await _inAppReview.isAvailable();
    if (mounted)
      setState(() {
        isReviewAvailable = isRevReady;
      });
  }

  final InAppReview _inAppReview = InAppReview.instance;
  static final _kAdIndex = 1;
  // late BannerAd _ad;
  bool _isAdLoaded = false;

  int _getDestinationItemIndex(int rawIndex) {
    if (rawIndex >= _kAdIndex) {
      return rawIndex - 1;
    }
    return rawIndex;
  }

  String get bannerAdUnitId {
    //list screen ad
    if (kDebugMode)
      return MobileAds.bannerAdTestUnitId;
    else
      return 'ca-app-pub-9537370157330943/4756889424';
  }

  @override
  void initState() {
    checkForUpdate();
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

  bool showOnlyVerified = true;
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb)
      FirebaseCrashlytics.instance.setCustomKey("screen name", 'Main Screen');

    String? name = Provider.of<UserData>(context, listen: false).name;
    String begginingOfEmergencyText = name != null ? ", tutaj $name" : '';
    Future firebaseData = showOnlyVerified
        ? FirebaseFirestore.instance
            .collection('trips')
            .where("showable", isEqualTo: true)
            .where("verified", isEqualTo: true)
            .get()
        : FirebaseFirestore.instance
            .collection('trips')
            .where("showable", isEqualTo: true)
            .get();
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        // brightness: Brightness.light,
        // bottom: Provider.of<UserData>(context, listen: false).thisVersion <
        //         Provider.of<UserData>(context, listen: false).currentVersion
        bottom: updateReady
            ? PreferredSize(
                preferredSize: Size.fromHeight(30.0),
                child: Tooltip(
                  padding: EdgeInsets.all(15.0),
                  showDuration: Duration(seconds: 7),
                  // message: Provider.of<UserData>(context, listen: false)
                  //             .thisVersion <
                  //         Provider.of<UserData>(context, listen: false)
                  //             .workingVersion
                  message: true
                      ? 'Aplikacja wymaga pilnej aktualizacji. Zosta??y dodane nowe funkcje b??d?? zaktualizowano spos??b dzia??ania bazy danych i ta wersja aplikacji mo??e nie dzia??a?? w pe??ni prawid??owo, b??d?? nie dzia??a?? w og??le. Sprawd?? w sklepie z aplikacjami czy nie ma aktualizacji.'
                      : 'Aplikacja b??d?? baza danych dosta??a drobn?? aktualizacj??, kt??ra nie powinna wp??yn???? na spos??b jej dzia??ania i wszystkie funkcje powinny dalej dzia??a??, ale wszystkie nowo dodane nie b??d?? dost??pne a?? do aktualizacji, Sprawd?? w sklepie z aplikacjami czy nie ma dost??pnej nowej wersji.',
                  child: Center(
                    child: FlatButton(
                      onPressed: () async {
                        InAppUpdate.performImmediateUpdate().catchError(
                          (e) => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Color.fromRGBO(249, 101, 116, 1),
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                e.toString(),
                              ),
                              duration: Duration(
                                  seconds:
                                      ((e.toString().length) / 6).round() + 5),
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Provider.of<UserData>(context, listen: false)
                          //             .thisVersion <
                          //         Provider.of<UserData>(context, listen: false)
                          //             .workingVersion
                          true
                              ? Icon(
                                  Icons.gpp_maybe_outlined,
                                  // : Icons.model_training_outlined,
                                  size: 30.0,
                                  color: Color.fromRGBO(249, 101, 116, 1),
                                )
                              : Icon(
                                  // Icons.dangerous_rounded,
                                  Icons.model_training_outlined,
                                  size: 30.0,
                                  color: Color.fromRGBO(132, 207, 150, 1),
                                ),
                          SizedBox(width: 10.0),
                          Text(
                            // Provider.of<UserData>(context, listen: false)
                            //             .thisVersion <
                            //         Provider.of<UserData>(context,
                            //                 listen: false)
                            //             .workingVersion
                            false
                                ? 'Pilnie zaktualizuj aplikacj??!'
                                : 'Dost??pna nowa wersja aplikacji!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .color ??
                                  Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : null,
        elevation: 0.0,
        leading: (Provider.of<UserData>(context, listen: false).isVerified ??
                    false) &&
                (!kIsWeb ||
                    (Provider.of<UserData>(context, listen: false).isAdmin ??
                        false))
            ? IconButton(
                tooltip: 'Dodaj wstawk??',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return AddTripScreen();
                    },
                  ),
                ),
                icon: Icon(Icons.add_location_alt_outlined),
              )
            : null,
        actions: [
          // Tooltip(
          //   message: 'Numer wersji',
          //   // padding: EdgeInsets.all(15.0),
          //   showDuration: Duration(seconds: 2),
          //   child: Text('beta'),
          // ),
          Badge(
            badgeContent: Text(
              (Provider.of<UserData>(context, listen: false).usersList ?? [])
                  .length
                  .toString(),
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            position: BadgePosition.topStart(),
            showBadge:
                ((Provider.of<UserData>(context, listen: false).usersList ?? [])
                            .length >
                        0) &&
                    (Provider.of<UserData>(context, listen: false).isAdmin ??
                        false),
            child: Container(
              padding: EdgeInsets.all(5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: PopupMenuButton(
                  enableFeedback: true,
                  tooltip: 'Opcje',
                  color: Theme.of(context).primaryColor,
                  // color: Color.fromRGBO(112, 238, 156, 1),
                  itemBuilder: (context) {
                    List<PopupMenuEntry> list = [
                      PopupMenuItem(
                        child: Text(
                          showOnlyVerified
                              ? "Pokazuj r??wnie?? niezweryfikowane wstawki"
                              : "Pokazuj tylko zweryfikowane wstawki",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headline5!.color,
                          ),
                        ),
                        value: 0,
                      ),
                      (Provider.of<UserData>(context, listen: false).isAdmin ??
                              false)
                          ? PopupMenuItem(
                              enabled:
                                  (Provider.of<UserData>(context, listen: false)
                                                  .usersList ??
                                              [])
                                          .length >
                                      0,
                              child: Text(
                                "Osoby do zweryfikowania: ${(Provider.of<UserData>(context, listen: false).usersList ?? []).length}",
                                style: TextStyle(
                                  color: (Provider.of<UserData>(context,
                                                          listen: false)
                                                      .usersList ??
                                                  [])
                                              .length >
                                          0
                                      ? Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyText2!
                                          .color,
                                ),
                              ),
                              value: 1,
                            )
                          : PopupMenuDivider(
                              height: 0,
                            ) as PopupMenuEntry,
                      PopupMenuItem(
                        child: Provider.of<UserData>(context, listen: false)
                                    .isVerified ??
                                false
                            ? Text(
                                'Konto zweryfikowane',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .color,
                                ),
                              )
                            : Text(
                                "Zweryfikuj konto",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .color,
                                ),
                              ),
                        value: 2,
                        enabled: !(Provider.of<UserData>(context, listen: false)
                                .isVerified ??
                            false),
                      ),
                      PopupMenuItem(
                        child: Text(
                          "M??j Profil",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headline5!.color,
                          ),
                        ),
                        value: 3,
                        enabled: true,
                      ),
                      PopupMenuItem(
                        child: Text(
                          "Wyloguj si??",
                          style: TextStyle(
                            color: Color.fromRGBO(249, 101, 116, 1),
                          ),
                        ),
                        value: 4,
                        enabled: true,
                      ),
                      // CheckedPopupMenuItem(
                      //   child: Text(
                      //     "Nie zweryfikowano",
                      //     style: TextStyle(color: Theme.of(context)
                      // .textTheme
                      // .headline5!
                      // .color!),
                      //   ),
                      //   value: 2,
                      //   checked: false,

                      // ),
                    ];
                    return list;
                  },
                  onSelected: (value) {
                    switch (value) {
                      case 0:
                        setState(() {
                          showOnlyVerified = !showOnlyVerified;
                        });
                        break;
                      case 1:
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                              return UsersToBeVerifiedScreen();
                            },
                          ),
                        );
                        break;
                      case 2:
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                              return VerifyUserScreen();
                            },
                          ),
                        );
                        break;
                      case 3:
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                              return MyAccountScreen(
                                adsEnabled: Provider.of<UserData>(context,
                                            listen: false)
                                        .showAds ??
                                    false,
                              );
                            },
                          ),
                        );
                        break;
                      case 4:
                        UserData().logout().then((value) async {
                          if (mounted) {
                            await Future.delayed(Duration(seconds: 3));
                            if (mounted)
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) {
                                    return HomeScreen();
                                  },
                                ),
                              );
                          }
                        });
                        break;
                      default:
                    }
                  },
                  child: Image.network(
                    Provider.of<UserData>(context).currentUserPhoto ??
                        'https://techpowerusa.com/wp-content/uploads/2017/06/default-user.png',
                  ),
                  // icon: Icon(
                  //   Icons.settings,
                  // ),
                ),
              ),
            ),
          ),
        ],
        title: Text(
          'Flip&Smyrdack',
          style: GoogleFonts.comfortaa(
            wordSpacing: 20.0,
            color: Theme.of(context).textTheme.headline5!.color,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: (Provider.of<UserData>(context, listen: false)
                  .isVerified ??
              false)
          ? Container(
              padding: EdgeInsets.all(5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: PopupMenuButton(
                  enableFeedback: true,
                  tooltip: 'Opcje',
                  color: Theme.of(context).primaryColor,
                  itemBuilder: (context) {
                    List<PopupMenuEntry> list = [
                      PopupMenuItem(
                        child: Text(
                          "Zadzwo?? do: Smyrdack",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headline5!.color,
                          ),
                        ),
                        value: 0,
                        enabled: true,
                      ),
                      PopupMenuItem(
                        child: Text(
                          "Wy??lij SMS-a do: Smyrdack",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headline5!.color,
                          ),
                        ),
                        value: 1,
                        enabled: true,
                      ),
                      PopupMenuDivider(
                        height: 10,
                      ),
                      PopupMenuItem(
                        child: Text(
                          "Zadzwo?? do: Flip",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headline5!.color,
                          ),
                        ),
                        value: 2,
                        enabled: true,
                      ),
                      PopupMenuItem(
                        child: Text(
                          "Wy??lij SMS-a do: Flip",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headline5!.color,
                          ),
                        ),
                        value: 3,
                        enabled: true,
                      ),
                      // PopupMenuItem(
                      //   child: Text("Setting Language"),
                      //   value: 1,
                      // ),
                      // PopupMenuDivider(
                      //   height: 10,
                      // ),
                      // CheckedPopupMenuItem(
                      //   child: Text(
                      //     "Nie zweryfikowano",
                      //     style: TextStyle(color: Theme.of(context)
                      // .textTheme
                      // .headline5!
                      // .color!),
                      //   ),
                      //   value: 2,
                      //   checked: false,

                      // ),
                    ];
                    return list;
                  },
                  onSelected: (value) async {
                    switch (value) {
                      case 0:
                        const number = '+48518669037';
                        bool res = kIsWeb
                            ? false
                            : await FlutterPhoneDirectCaller.callNumber(number)
                                    .onError((error, stackTrace) => false) ??
                                false;
                        if (!res)
                          launch(Uri(
                            scheme: 'tel',
                            path: number,
                            // queryParameters: {'body': 'Panie Przewodniku$begginingOfEmergencyText. Potrzebuj?? pilnego kontaktu.'},
                          ).toString());
                        break;
                      case 1:
                        launch(Uri(
                          scheme: 'sms',
                          path: '+48518669037',
                          queryParameters: {
                            'body':
                                'Panie Przewodniku$begginingOfEmergencyText. Potrzebuj?? pilnego kontaktu.'
                          },
                        ).toString());
                        break;
                      case 2:
                        const number = '+48692847356';
                        bool res = kIsWeb
                            ? false
                            : await FlutterPhoneDirectCaller.callNumber(number)
                                    .onError((error, stackTrace) => false) ??
                                false;
                        if (!res)
                          launch(Uri(
                            scheme: 'tel',
                            path: number,
                            // queryParameters: {'body': 'Panie Przewodniku$begginingOfEmergencyText. Potrzebuj?? pilnego kontaktu.'},
                          ).toString());
                        break;
                      case 3:
                        launch(Uri(
                          scheme: 'sms',
                          path: '+48692847356',
                          queryParameters: {
                            'body':
                                'Panie Przewodniku$begginingOfEmergencyText. Potrzebuj?? pilnego kontaktu.'
                          },
                        ).toString());
                        break;
                      default:
                    }
                  },
                  child: Container(
                    height: 60.0,
                    width: 60.0,
                    color: Theme.of(context).accentColor,
                    child: Icon(
                      Icons.call_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 700.0),
          // padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          child: FutureBuilder(
            future: firebaseData,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if ((Provider.of<UserData>(context, listen: false).isVerified ??
                        false) &&
                    isReviewAvailable) {
                  Future.delayed(const Duration(seconds: 3), () {
                    _inAppReview.requestReview();
                  });
                }
                // WidgetsBinding.instance!.addPostFrameCallback((_) async {
                //   try {
                //     final isAvailable = await _inAppReview.isAvailable();
                //     print('HHH');
                //     if (isAvailable)
                //       Future.delayed(const Duration(seconds: 3), () {
                //         _inAppReview.requestReview();
                //       });
                //   } catch (e) {
                //     print(e);
                //   }
                // });
                List data = snapshot.data.docs;
                int length = data.length;

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      firebaseData = showOnlyVerified
                          ? FirebaseFirestore.instance
                              .collection('trips')
                              .where("showable", isEqualTo: true)
                              .where("verified", isEqualTo: true)
                              .get()
                          : FirebaseFirestore.instance
                              .collection('trips')
                              .where("showable", isEqualTo: true)
                              .get();
                    });
                    return firebaseData;
                  },
                  child: length > 0
                      ? ListView.builder(
                          itemCount: length + 2,
                          itemBuilder: (context, indexo) {
                            if (indexo == 0) {
                              return FutureBuilder(
                                future: getWeatherData(),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    WeatherData data = snapshot.data;
                                    return WeatherTile(
                                        cardA: cardA, data: data);
                                  } else if (snapshot.hasError) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0, vertical: 10),
                                      child: Center(
                                        child: Text(snapshot.error.toString()),
                                      ),
                                    );
                                  } else {
                                    return Center(
                                      // child: CircularProgressIndicator(),
                                      child: Container(
                                        height: 50.0,
                                        child: LoadingIndicator(
                                          indicatorType: Indicator.ballPulse,
                                          colors: [
                                            Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .color ??
                                                Colors.grey
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            }
                            int index = indexo - 1;
                            if (index == (length + 1))
                              return SizedBox(height: 75.0);
                            if (index == _kAdIndex) {
                              // return Container(
                              //   // margin: EdgeInsets.symmetric(horizontal: 15.0),
                              //   child: AdWidget(ad: _ad),
                              //   // width: _ad.size.width.toDouble(),
                              //   height: _ad.size.height.toDouble(),
                              //   // height: 72.0,
                              //   width: double.infinity,
                              //   alignment: Alignment.center,
                              // );
                              return InkWell(
                                onTap: () => print('tapped'),
                                child: (Provider.of<UserData>(context,
                                                listen: false)
                                            .showAds ??
                                        false)
                                    ? BannerAd(
                                        unitId: bannerAdUnitId,
                                        size: BannerSize.ADAPTIVE,
                                        loading: Center(
                                            child: Text('??adowanie reklamy')),
                                        // loading: Center(child: CircularProgressIndicator()),
                                        error: Center(
                                            child: Text(
                                                'Nie uda??o si?? za??adowa?? reklamy')),
                                        // builder: (context, child) {
                                        //   return GestureDetector(
                                        //     onTap: () => print('tappp'),
                                        //     child: child,
                                        //   );
                                        // return Container(
                                        //   margin:
                                        //       EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                                        //   decoration: BoxDecoration(
                                        //     borderRadius: BorderRadius.circular(15.0),
                                        //     border: Border.all(
                                        //       color: Colors.grey,
                                        //     ),
                                        //   ),
                                        //   child: ClipRRect(
                                        //     borderRadius: BorderRadius.circular(15.0),
                                        //     child: child,
                                        //   ),
                                        // );
                                        // }
                                        // unitId: ,
                                      )
                                    : SizedBox(),
                              );
                            } else {
                              dynamic info =
                                  data[_getDestinationItemIndex(index)];
                              List<String> photosList = [];
                              for (int i = 0; i < info['photosCount']; i++) {
                                photosList = [
                                  ...photosList,
                                  ...[info['photo$i']]
                                ];
                              }
                              return Destinations(
                                index,
                                info['name'],
                                info['date'],
                                info['difficulty'],
                                info['transportCost'],
                                photosList,
                                info['description'],
                                info['endTime'],
                                info['otherCosts'],
                                info['startTime'],
                                info.data().containsKey('eagers')
                                    ? info['eagers']
                                    : [],
                                info['createdTimestamp'],
                                info['elevation'],
                                info['elevation_differences'],
                                info['trip_length'],
                                info['verified'],
                              );
                            }
                          },
                        )
                      : Center(
                          child: Container(
                            margin: EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.hiking_rounded,
                                  size: 100.0,
                                  color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color ??
                                      Colors.grey,
                                ),
                                SizedBox(height: 15.0),
                                Text(
                                  'Nie ma ??adnych nadchodz??cych wypraw',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24.0,
                                    color: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .color ??
                                        Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      firebaseData = FirebaseFirestore.instance
                                          .collection('trips')
                                          .get();
                                    });
                                  },
                                  icon: Icon(
                                    Icons.refresh_rounded,
                                    size: 30.0,
                                    color: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .color ??
                                        Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Co?? posz??o nie tak, b????d:',
                        ),
                        Text(
                          snapshot.error.toString(),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}

class WeatherTile extends StatelessWidget {
  const WeatherTile({
    Key? key,
    required this.cardA,
    required this.data,
  }) : super(key: key);

  final GlobalKey<ExpansionTileCardState> cardA;
  final WeatherData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: ExpansionTileCard(
        // baseColor: Colors.cyan[50],
        baseColor: Color.fromRGBO(107, 120, 180, 1),
        expandedColor: Color.fromRGBO(107, 120, 180, 1),
        key: cardA,
        trailing: Icon(Icons.expand_more_rounded, color: Colors.white),
        animateTrailing: true,
        leading: Container(
          height: 50.0,
          // width: 50.0,
          child: FittedBox(
            child: Image.network(
              "https://openweathermap.org/img/wn/${data.icon}@2x.png",
              // color: Colors.red,
              // fit: BoxFit.none,
              height: 80.0,
              width: 80.0,
            ),
            fit: BoxFit.none,
            alignment: Alignment.center,
          ),
        ),
        title: Text(
          "${data.temperature.round().toString()}??C",
          style: TextStyle(
            color: Colors.white,
            fontSize: 19.0,
          ),
          // style: Theme.of(context)
          //     .textTheme
          //     .headline5!
          //     .copyWith(fontSize: 19.0),
        ),
        subtitle: Text(
          "${data.description.toUpperCase()}\n${data.name.toLowerCase()}",
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.0,
          ),
        ),
        children: <Widget>[
          Divider(
            thickness: 1.0,
            height: 1.0,
          ),
          Padding(
            padding: const EdgeInsets.all(7.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      CreateColumnOfInfo(
                        "Odczuwalna",
                        "${(data.feelsLikeTemperature * 10).round() / 10}??C",
                        "Odczuwalna temperatura",
                      ),
                      CreateColumnOfInfo(
                        "Wsch??d",
                        "${DateFormat("HH:mm", 'pl_PL').format(DateTime.fromMillisecondsSinceEpoch(data.sunRiseTimestamp * 1000).toLocal())}",
                        "Godzina i minuta wschodu s??o??ca",
                      ),
                      CreateColumnOfInfo(
                        "Wilgotno????",
                        "${data.humidity}%",
                        "Wilgotno???? powietrza wyra??ona w procentach",
                      ),
                      CreateColumnOfInfo(
                        "Widoczno????",
                        convertBigToSmall(data.visibility),
                        "Widoczno???? przez powietrze",
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      CreateColumnOfInfo(
                        "Ci??nienie",
                        "${data.pressure} hPa",
                        "Ci??nienie powietrza",
                      ),
                      CreateColumnOfInfo(
                        "Zach??d",
                        "${DateFormat("HH:mm", 'pl_PL').format(DateTime.fromMillisecondsSinceEpoch(data.sunSetTimestamp * 1000).toLocal())}",
                        "Godzina i minuta zachodu s??o??ca",
                      ),
                      CreateColumnOfInfo(
                        "Wiatr",
                        "${(data.windSpeed * 10).round() / 10} m/s",
                        "Pr??dko???? wiatru",
                      ),
                      CreateColumnOfInfo(
                        "Zachmurzenie",
                        "${data.clouds}%",
                        "Zachmurzenie w tym miejscu wyra??one w procentach",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 10.0,
              ),
              child: Text(
                timeago.format(
                  DateTime.fromMillisecondsSinceEpoch(
                    data.time * 1000,
                  ),
                  locale: "pl",
                ),
                // overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  // fontWeight: FontWeight.bold,

                  fontSize: 13.0,
                ),
              ),
            ),
          ),

          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: Padding(
          //     padding:
          //         const EdgeInsets.symmetric(
          //       horizontal: 16.0,
          //       vertical: 8.0,
          //     ),
          //     child: Text(
          //       "FlutterDevs specializes in creating cost-effective and efficient applications with our perfectly crafted,"
          //       " creative and leading-edge flutter app development solutions for customers all around the globe.",
          //       style: Theme.of(context)
          //           .textTheme
          //           .headline5!
          //           .copyWith(fontSize: 16.0),
          //     ),
          //   ),
          // ),
          // ButtonBar(
          //   alignment:
          //       MainAxisAlignment.spaceAround,
          //   buttonHeight: 52.0,
          //   buttonMinWidth: 90.0,
          //   children: <Widget>[
          //     FlatButton(
          //       shape: RoundedRectangleBorder(
          //           borderRadius:
          //               BorderRadius.circular(
          //                   4.0)),
          //       onPressed: () {
          //         cardA.currentState?.expand();
          //       },
          //       child: Column(
          //         children: <Widget>[
          //           Icon(
          //             Icons.arrow_downward,
          //             color: Theme.of(context)
          //                 .textTheme
          //                 .headline5!
          //                 .color,
          //           ),
          //           Padding(
          //             padding: const EdgeInsets
          //                     .symmetric(
          //                 vertical: 2.0),
          //           ),
          //           Text(
          //             'Open',
          //             style: TextStyle(
          //               color: Theme.of(context)
          //                   .textTheme
          //                   .headline5!
          //                   .color,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //     FlatButton(
          //       shape: RoundedRectangleBorder(
          //           borderRadius:
          //               BorderRadius.circular(
          //                   4.0)),
          //       onPressed: () {
          //         cardA.currentState
          //             ?.collapse();
          //       },
          //       child: Column(
          //         children: <Widget>[
          //           Icon(
          //             Icons.arrow_upward,
          //             color: Theme.of(context)
          //                 .textTheme
          //                 .headline5!
          //                 .color,
          //           ),
          //           Padding(
          //             padding: const EdgeInsets
          //                     .symmetric(
          //                 vertical: 2.0),
          //           ),
          //           Text(
          //             'Close',
          //             style: TextStyle(
          //               color: Theme.of(context)
          //                   .textTheme
          //                   .headline5!
          //                   .color,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //     FlatButton(
          //       shape: RoundedRectangleBorder(
          //           borderRadius:
          //               BorderRadius.circular(
          //                   4.0)),
          //       onPressed: () {

          //       },
          //       child: Column(
          //         children: <Widget>[
          //           Icon(
          //             Icons.swap_vert,
          //             color: Theme.of(context)
          //                 .textTheme
          //                 .headline5!
          //                 .color,
          //           ),
          //           Padding(
          //             padding: const EdgeInsets
          //                     .symmetric(
          //                 vertical: 2.0),
          //           ),
          //           Text(
          //             'Toggle',
          //             style: TextStyle(
          //               color: Theme.of(context)
          //                   .textTheme
          //                   .headline5!
          //                   .color,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (from.difference(to).inHours / 24).round();
}

String textDate(Timestamp from) {
  if (from.toDate().year == 2000) return "Wkr??tce";
  int days = daysBetween(from.toDate(), DateTime.now());
  // int days = -2;
  if (days == -2)
    return "Przedwczoraj";
  else if (days == -1)
    return "Wczoraj";
  else if (days == 0)
    return "Dzisiaj";
  else if (days == 1)
    return "Jutro";
  else if (days == 2) return "Pojutrze";
  return DateFormat('EEEE, dd MMM', 'pl_PL').format(from.toDate().toLocal());
}

class CreateColumnOfInfo extends StatelessWidget {
  String topText;
  String bottomText;
  String tooltipText;
  CreateColumnOfInfo(this.topText, this.bottomText, this.tooltipText);
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltipText,
      padding: EdgeInsets.all(10.0),
      showDuration: Duration(seconds: 4),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          children: [
            SingleInfoText(topText),
            SingleInfoTextBold(bottomText),
          ],
        ),
      ),
    );
  }
}

class SingleInfoText extends StatelessWidget {
  String text;
  SingleInfoText(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.0,
      child: Text(
        text,
        // overflow: TextOverflow.ellipsis,
        maxLines: 2,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).textTheme.headline5!.color,
          // fontWeight: FontWeight.bold,

          fontSize: 16.0,
        ),
      ),
    );
  }
}

class SingleInfoTextBold extends StatelessWidget {
  String text;
  SingleInfoTextBold(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      // overflow: TextOverflow.ellipsis,
      maxLines: 2,
      // textAlign: TextAlign.left,
      style: TextStyle(
        color: Theme.of(context).textTheme.headline5!.color,
        fontWeight: FontWeight.bold,
        fontSize: 18.0,
      ),
    );
  }
}

String convertBigToSmall(int meters) {
  if (meters >= 3000) return '${((meters / 100).round()) / 10} km';
  return '$meters m';
}

class Destinations extends StatelessWidget {
  int index;
  String name;
  String difficulty;
  String description;
  Timestamp date;
  int transportCost;
  int otherCosts;
  String startTime;
  String endTime;
  List eager;
  List<String> imageUrl; //TODO: list
  int _id;
  int elevation, elevDifference, tripLength;
  bool verified;

  Destinations(
    this.index,
    this.name,
    this.date,
    this.difficulty,
    this.transportCost,
    this.imageUrl,
    this.description,
    this.endTime,
    this.otherCosts,
    this.startTime,
    this.eager,
    this._id,
    this.elevation,
    this.elevDifference,
    this.tripLength,
    this.verified,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      margin: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
      height: 400.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          child: Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Hero(
                  tag: imageUrl[0],
                  child: Image.network(
                    imageUrl[0],
                    // 'https://www.pexels.com/photo/1471294/download/',
                    height: 300.0, width: double.infinity, fit: BoxFit.cover,
                    // loadingBuilder: ,
                    // frameBuilder: (BuildContext context, Widget child,
                    //     int? frame, bool wasSynchronouslyLoaded) {
                    //   if (wasSynchronouslyLoaded) {
                    //     return child;
                    //   } else
                    //     return SkeletonAnimation(
                    //       borderRadius: BorderRadius.circular(10.0),
                    //       shimmerColor:
                    //           index % 2 != 0 ? Colors.grey : Colors.white54,
                    //       child: Container(
                    //         height: 30,
                    //         width: MediaQuery.of(context).size.width * 0.35,
                    //         decoration: BoxDecoration(
                    //             borderRadius: BorderRadius.circular(10.0),
                    //             color: Colors.grey[300]),
                    //       ),
                    //     );
                    // },
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      Color darken(Color color, [double amount = .1]) {
                        assert(amount >= 0 && amount <= 1);

                        final hsl = HSLColor.fromColor(color);
                        final hslDark = hsl.withLightness(
                            (hsl.lightness - amount).clamp(0.0, 1.0));

                        return hslDark.toColor();
                      }

                      if (loadingProgress == null) {
                        // The child (AnimatedOpacity) is build with loading == true, and then the setState will change loading to false, which trigger the animation
                        // WidgetsBinding.instance!.addPostFrameCallback((_) {
                        //   setState(() => loading = false);
                        // });

                        return child;
                      }
                      // loading = true;
                      return Container(
                        margin: EdgeInsets.only(bottom: 100.0),
                        child: Center(
                          // child: CupertinoActivityIndicator(),
                          child: LoadingIndicator(
                            indicatorType: Indicator.ballClipRotateMultiple,
                            colors: [
                              Theme.of(context).textTheme.headline5!.color ??
                                  Colors.grey
                            ],
                          ),
                        ),
                      );
                      // return SkeletonAnimation(
                      //   borderRadius: BorderRadius.circular(10.0),
                      //   shimmerColor: index % 2 != 0
                      //       ? Theme.of(context).accentColor
                      //       : darken(Theme.of(context).accentColor, .1),
                      //   child: Container(
                      //     height: 300.0,
                      //     width: double.infinity,
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(10.0),
                      //       color: Theme.of(context).primaryColor,
                      //     ),
                      //   ),
                      // );
                    },
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                child: FlatButton(
                  disabledColor: Theme.of(context).accentColor,
                  disabledTextColor:
                      Theme.of(context).textTheme.headline5!.color ??
                          Colors.grey,
                  textColor: Theme.of(context).textTheme.headline5!.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  // splashColor: Color.fromRGBO(120, 254, 224, 1),
                  color: Colors.white.withOpacity(0.0001),
                  padding: EdgeInsets.fromLTRB(10.0, 300.0, 10.0, 5.0),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        return DetailsScreen(
                          index,
                          name,
                          date,
                          difficulty,
                          transportCost,
                          imageUrl,
                          description,
                          endTime,
                          otherCosts,
                          startTime,
                          elevDifference,
                          elevation,
                          tripLength,
                          eager,
                          _id,
                        );
                        // return DetailsScreen(
                        //     name, index, date, difficulty, cost, imageUrl);
                      },
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0,
                            ),
                          ),
                        ),
                      ),
                      Text("Trudno????: $difficulty"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Text(
                          //   '${otherCosts + transportCost}z??',
                          //   style: TextStyle(
                          //     color: Colors.transparent,
                          //   ),
                          // ),
                          verified
                              ? Tooltip(
                                  message:
                                      'Wstawka zosta??a zweryfikowana przez Zesp???? Flip&Smyrdack',
                                  padding: EdgeInsets.all(15.0),
                                  showDuration: Duration(seconds: 3),
                                  child: Icon(
                                    Icons.verified_rounded,
                                    color: Colors.blue,
                                    // color: Color.fromRGBO(65, 211, 189, 1),
                                  ),
                                )
                              : Text(
                                  '${otherCosts + transportCost}z??',
                                  style: TextStyle(
                                    color: Colors.transparent,
                                  ),
                                ),
                          Text("Kiedy: ${textDate(date)}"),
                          Tooltip(
                            message:
                                '????czne koszty transportu i innych dodatk??w typu op??aty za wst??p. Po wi??cej informacji wejd?? we wstawk??.',
                            padding: EdgeInsets.all(15.0),
                            showDuration: Duration(seconds: 4),
                            child: Text('${otherCosts + transportCost}z??'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
