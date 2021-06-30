import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/add_trip.dart';
import 'package:flip_smyrdack/screens/details_screen.dart';
import 'package:flip_smyrdack/screens/home_screen.dart';
import 'package:flip_smyrdack/screens/my_account_screen.dart';
import 'package:flip_smyrdack/screens/users_to_be_verified_screen.dart';
import 'package:flip_smyrdack/screens/verify_user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flip_smyrdack/ad_helper.dart';
import 'package:in_app_review/in_app_review.dart';

// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isReviewAvailable = false;
  bool updateReady = false;
  Future<void> checkForUpdate() async {
    if (!kIsWeb)
      await InAppUpdate.checkForUpdate().then((info) {
        if (info.updateAvailability == UpdateAvailability.updateAvailable)
          setState(() {
            updateReady = true;
          });
      }).catchError((e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      });
    bool isRevReady = kIsWeb ? false : await _inAppReview.isAvailable();
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
                      ? 'Aplikacja wymaga pilnej aktualizacji. Zostały dodane nowe funkcje bądź zaktualizowano sposób działania bazy danych i ta wersja aplikacji może nie działać w pełni prawidłowo, bądź nie działać w ogóle. Sprawdź w sklepie z aplikacjami czy nie ma aktualizacji.'
                      : 'Aplikacja bądź baza danych dostała drobną aktualizację, która nie powinna wpłynąć na sposób jej działania i wszystkie funkcje powinny dalej działać, ale wszystkie nowo dodane nie będą dostępne aż do aktualizacji, Sprawdź w sklepie z aplikacjami czy nie ma dostępnej nowej wersji.',
                  child: Center(
                    child: FlatButton(
                      onPressed: () async {
                        InAppUpdate.performImmediateUpdate().catchError((e) =>
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString()))));
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
                                ? 'Pilnie zaktualizuj aplikację!'
                                : 'Dostępna nowa wersja aplikacji!',
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
                tooltip: 'Dodaj wstawkę',
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
                              ? "Pokazuj również niezweryfikowane wstawki"
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
                          "Mój Profil",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headline5!.color,
                          ),
                        ),
                        value: 3,
                        enabled: true,
                      ),
                      PopupMenuItem(
                        child: Text(
                          "Wyloguj się",
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
                          "Zadzwoń do: Smyrdack",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headline5!.color,
                          ),
                        ),
                        value: 0,
                        enabled: true,
                      ),
                      PopupMenuItem(
                        child: Text(
                          "Wyślij SMS-a do: Smyrdack",
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
                          "Zadzwoń do: Flip",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headline5!.color,
                          ),
                        ),
                        value: 2,
                        enabled: true,
                      ),
                      PopupMenuItem(
                        child: Text(
                          "Wyślij SMS-a do: Flip",
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
                            // queryParameters: {'body': 'Panie Przewodniku$begginingOfEmergencyText. Potrzebuję pilnego kontaktu.'},
                          ).toString());
                        break;
                      case 1:
                        launch(Uri(
                          scheme: 'sms',
                          path: '+48518669037',
                          queryParameters: {
                            'body':
                                'Panie Przewodniku$begginingOfEmergencyText. Potrzebuję pilnego kontaktu.'
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
                            // queryParameters: {'body': 'Panie Przewodniku$begginingOfEmergencyText. Potrzebuję pilnego kontaktu.'},
                          ).toString());
                        break;
                      case 3:
                        launch(Uri(
                          scheme: 'sms',
                          path: '+48692847356',
                          queryParameters: {
                            'body':
                                'Panie Przewodniku$begginingOfEmergencyText. Potrzebuję pilnego kontaktu.'
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
                          itemBuilder: (context, index) {
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
                                            child: Text('Ładowanie reklamy')),
                                        // loading: Center(child: CircularProgressIndicator()),
                                        error: Center(
                                            child: Text(
                                                'Nie udało się załadować reklamy')),
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
                                  'Nie ma żadnych nadchodzących wypraw',
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
                          'Coś poszło nie tak, błąd:',
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

int daysBetween(DateTime from, DateTime to) {

  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (from.difference(to).inHours / 24).round();
}

String textDate(Timestamp from) {
  
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
                    height: 300.0,
                    width: double.infinity,
                    fit: BoxFit.cover,
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
                      Text("Trudność: $difficulty"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Text(
                          //   '${otherCosts + transportCost}zł',
                          //   style: TextStyle(
                          //     color: Colors.transparent,
                          //   ),
                          // ),
                          verified
                              ? Tooltip(
                                  message:
                                      'Wstawka została zweryfikowana przez Zespół Flip&Smyrdack',
                                  padding: EdgeInsets.all(15.0),
                                  showDuration: Duration(seconds: 3),
                                  child: Icon(
                                    Icons.verified_rounded,
                                    color: Colors.blue,
                                    // color: Color.fromRGBO(65, 211, 189, 1),
                                  ),
                                )
                              : Text(
                                  '${otherCosts + transportCost}zł',
                                  style: TextStyle(
                                    color: Colors.transparent,
                                  ),
                                ),
                          Text("Kiedy: ${textDate(date)}"),
                          Tooltip(
                            message:
                                'Łączne koszty transportu i innych dodatków typu opłaty za wstęp. Po więcej informacji wejdź we wstawkę.',
                            padding: EdgeInsets.all(15.0),
                            showDuration: Duration(seconds: 4),
                            child: Text('${otherCosts + transportCost}zł'),
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
