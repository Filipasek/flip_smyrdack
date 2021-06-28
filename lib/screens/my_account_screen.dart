import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_smyrdack/main.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/home_screen.dart';
import 'package:flip_smyrdack/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:ndialog/ndialog.dart';

class MyAccountScreen extends StatefulWidget {
  bool adsEnabled;
  MyAccountScreen({required this.adsEnabled});
  // String userId;
  // MyAccountScreen(this.userId);
  @override
  _MyAccountScreenState createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  bool rewardedAdReady = false;
  String rewardedAdErrorText = '';
  int diamonds = 0;
  String get bannerAdUnitId {
    if (kDebugMode)
      return MobileAds.bannerAdTestUnitId;
    else
      return 'ca-app-pub-9537370157330943/7967368516';
  }

  String get rewardedAdUnitId {
    if (kDebugMode)
      return MobileAds.rewardedAdTestUnitId;
    else
      return 'ca-app-pub-9537370157330943/2383869343';
  }

  late RewardedAd rewardedAd;

  @override
  void initState() {
    if (widget.adsEnabled) {
      rewardedAd = RewardedAd(
        unitId: rewardedAdUnitId,
      );
      rewardedAd.load();

      rewardedAd.onEvent.listen((e) async {
        final event = e.keys.first;
        switch (event) {
          case RewardedAdEvent.loading:
            setState(() {
              rewardedAdReady = false;
            });
            break;
          case RewardedAdEvent.loaded:
            setState(() {
              rewardedAdReady = true;
            });
            break;
          case RewardedAdEvent.loadFailed:
            final errorCode = e.values.first;
            FirebaseCrashlytics.instance.recordError(
              errorCode, StackTrace.current,
              reason: 'Loading a rewarded ad',
              // Pass in 'fatal' argument
              // fatal: true
            );
            rewardedAdErrorText = errorCode.toString();
            print('load failed $errorCode');
            break;
          // case RewardedAdEvent.opened:
          //   print('ad opened');
          //   break;
          case RewardedAdEvent.closed:
            print('ad closed');
            rewardedAd.load();
            break;
          case RewardedAdEvent.earnedReward:
            await AuthService.incrementDiamonds(
                Provider.of<UserData>(context, listen: false).currentUserId, 5);
            setState(() {
              diamonds += 5;
            });
            final reward = e.values.first;
            print('earned reward: $reward');
            break;
          case RewardedAdEvent.showFailed:
            final errorCode = e.values.first;
            FirebaseCrashlytics.instance.recordError(
              errorCode, StackTrace.current,
              reason: 'Loading a rewarded ad',
              // Pass in 'fatal' argument
              // fatal: true
            );
            rewardedAdErrorText = errorCode.toString();
            print('show failed $errorCode');
            break;
          default:
            break;
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb)
      FirebaseCrashlytics.instance.setCustomKey("screen name", 'My Account');
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Konto użytkownika'),
        actions: [
          IconButton(
              onPressed: () async {
                await DialogBackground(
                  blur: 15.0,
                  dialog: AlertDialog(
                    title: Text("Nie odchodź..."),
                    content: Text(
                      "Na pewno chcesz usunąć konto? Stracisz dostęp do eksluzywnych wypraw organizowanych przez biuro Flip&Smyrdack, a także personalizowanych ofert tylko dla Ciebie.",
                      textAlign: TextAlign.left,
                    ),
                    actions: <Widget>[
                      FlatButton(
                          child: Text(
                            "Tak, usuń",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            AuthService.deleteMyAccount(Provider.of<UserData>(
                                        context,
                                        listen: false)
                                    .currentUserId!)
                                .then((value) {
                              if (value) {
                                UserData().logout().then((value) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) {
                                        return HomeScreen();
                                      },
                                    ),
                                  );
                                }).onError((error, stackTrace) {
                                  setState(() {
                                    rewardedAdErrorText = error.toString();
                                  });
                                });
                              }
                              // Navigator.of(context).pushReplacement(
                              //   MaterialPageRoute<void>(
                              //     builder: (BuildContext context) {
                              //       return App();
                              //     },
                              //   ),
                              // );
                            }).onError((error, stackTrace) {
                              setState(() {
                                rewardedAdErrorText = error.toString();
                              });
                            });
                          }),
                      FlatButton(
                        child: Text(
                          "Zostaję",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        color: Color.fromRGBO(0, 191, 166, 1),
                      ),
                    ],
                  ),
                ).show(context);
              },
              icon: Icon(
                Icons.delete_forever_rounded,
              ))
        ],
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(Provider.of<UserData>(context).currentUserId)
            .get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            dynamic data = snapshot.data!.data();
            diamonds = data['diamonds'] ?? 0;
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.all(15.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: Image.network(
                        data['avatar'] ??
                            'https://techpowerusa.com/wp-content/uploads/2017/06/default-user.png',
                        height: 120.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 30.0),
                    child: Text(
                      data['name'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headline5!.color,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                    child: Text(
                      'Adres e-mail: ${data['contactData']}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Theme.of(context).textTheme.headline5!.color,
                      ),
                    ),
                  ),
                ),

                // Center(
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Container(
                //         child: Text(
                //           'Adres e-mail: ${data['contactData']}',
                //           style: TextStyle(
                //             fontSize: 14.0,
                //             color: Theme.of(context)
                                            // .textTheme
                                            // .headline5!
                                            // .color!,
                //           ),
                //         ),
                //       ),
                //       IconButton(
                //         onPressed: () {
                //           launch(Uri(
                //             scheme: 'mailto',
                //             path: data['contactData'],
                //             queryParameters: {
                //               'subject':
                //                   'Administracja Flip&Smyrdack w sprawie weryfikacji konta'
                //             },
                //           ).toString());
                //         },
                //         icon: Icon(
                //           Icons.mail_outline,
                //         ),
                //       )
                //     ],
                //   ),
                // ),
                Center(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                    child: Text(
                      'Uprawnienia admina: ${data['admin'] ? 'Tak' : 'Nie'}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Theme.of(context).textTheme.headline5!.color,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                    child: Text(
                      'Konto zweryfikowane: ${data['verified'] ? 'Tak' : 'Nie'}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Theme.of(context).textTheme.headline5!.color,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                    child: Text(
                      'Pierwsze logowanie: ${DateFormat('dd MMM, HH:mm', 'pl_PL').format(data['first_login'].toDate().toLocal())}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Theme.of(context).textTheme.headline5!.color,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                    child: Text(
                      'Ostatnie nowe logowanie: ${DateFormat('dd MMM, HH:mm', 'pl_PL').format(data['last_login'].toDate())}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Theme.of(context).textTheme.headline5!.color,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                    child: Text(
                      // 'Ilość uzbieranych diamentów: ${data['diamonds'] ?? '[BŁĄD]'}',
                      'Ilość wykopanych diamentów: $diamonds 💎',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Theme.of(context).textTheme.headline5!.color,
                      ),
                    ),
                  ),
                ),
                widget.adsEnabled
                    ? RaisedButton(
                        child: Text(
                          'Weno wykop trochę diamentów :)',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        color: Color.fromRGBO(0, 191, 166, 1),
                        onLongPress: () => rewardedAd.load(force: true),
                        onPressed: rewardedAdReady
                            ? () async {
                                if (!rewardedAd.isAvailable)
                                  await rewardedAd.load();
                                await rewardedAd.show();
                                rewardedAd.load();
                              }
                            : null,
                      )
                    : SizedBox(),
                // RaisedButton(
                //   child: Text(
                //     'Wymuś błąd',
                //     style: TextStyle(
                //       color: Colors.white,
                //     ),
                //   ),
                //   color: Color.fromRGBO(0, 191, 166, 1),
                //   onLongPress: () => rewardedAd.load(force: true),
                //   onPressed: () async {
                //     await FirebaseCrashlytics.instance.recordError(
                //       'error', StackTrace.current,
                //       reason: 'a non fatal error',
                //       // Pass in 'fatal' argument
                //       // fatal: true
                //     );
                //     await FirebaseCrashlytics.instance.sendUnsentReports();
                //   },
                // ),
                rewardedAdErrorText != ''
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          rewardedAdErrorText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12.0,
                          ),
                        ),
                      )
                    : SizedBox(),
                Expanded(child: SizedBox()),
                widget.adsEnabled
                    ? BannerAd(
                        unitId: bannerAdUnitId,
                        size: BannerSize.ADAPTIVE,
                        loading: Center(child: Text('Ładowanie reklamy')),
                        error: Center(
                            child: Text('Brak reklamy. Na nasz koszt :)')),
                      )
                    : SizedBox(),
              ],
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
    );
  }
}
