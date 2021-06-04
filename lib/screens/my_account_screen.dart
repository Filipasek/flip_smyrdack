import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

class MyAccountScreen extends StatefulWidget {
  // String userId;
  // MyAccountScreen(this.userId);
  @override
  _MyAccountScreenState createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
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
    rewardedAd = RewardedAd(
      unitId: rewardedAdUnitId,
    );

    rewardedAd.load();

    rewardedAd.onEvent.listen((e) async {
      final event = e.keys.first;
      switch (event) {
        case RewardedAdEvent.loading:
          print('loading');
          break;
        case RewardedAdEvent.loaded:
          print('loaded');
          break;
        case RewardedAdEvent.loadFailed:
          final errorCode = e.values.first;
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
          print('show failed $errorCode');
          break;
        default:
          break;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Konto użytkownika'),
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
                        data['avatar'],
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
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    child: Text(
                      'Adres e-mail: ${data['contactData']}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
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
                //             color: Colors.black,
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
                        color: Colors.black,
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
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                    child: Text(
                      'Pierwsze logowanie (UTC): ${DateFormat('dd MMM, HH:mm', 'pl_PL').format(data['first_login'].toDate().toLocal())}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                    child: Text(
                      'Ostatnie nowe logowanie (UTC): ${DateFormat('dd MMM, HH:mm', 'pl_PL').format(data['last_login'].toDate())}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                    child: Text(
                      // 'Ilość uzbieranych diamentów: ${data['diamonds'] ?? '[BŁĄD]'}',
                      'Ilość uzbieranych diamentów: $diamonds',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                RaisedButton(
                  child: Text(
                    'Dodaj trochę diamentów :)',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  color: Color.fromRGBO(0, 191, 166, 1),
                  onLongPress: () => rewardedAd.load(force: true),
                  onPressed: () async {
                    if (!rewardedAd.isAvailable) await rewardedAd.load();
                    await rewardedAd.show();
                    rewardedAd.load();
                  },
                ),
                Expanded(child: SizedBox()),
                BannerAd(
                  unitId: bannerAdUnitId,
                  size: BannerSize.ADAPTIVE,
                  loading: Center(child: Text('Ładowanie reklamy')),
                  error: Center(child: Text('Nie udało się załadować reklamy')),
                ),
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
