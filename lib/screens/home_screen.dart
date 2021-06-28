import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/login_screen.dart';
import 'package:flip_smyrdack/screens/main_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatelessWidget {
  // Future<InitializationStatus> _initGoogleMobileAds() {
  //   // TODO: Initialize Google Mobile Ads SDK
  //   return MobileAds.instance.initialize();
  // }

  int apiVersion = 25; //TODO: change when major update been made to api
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb)
      FirebaseCrashlytics.instance.setCustomKey("screen name", 'Home Screen');
    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle(
    //     systemNavigationBarColor: Theme.of(context).primaryColor,
    //     systemNavigationBarIconBrightness: Brightness.light,
    //     // systemNavigationBarIconBrightness: Theme.of(context).appBarTheme.brightness,
    //   ),
    // );
    // AnnotatedRegion<SystemUiOverlayStyle>(
    //     value: SystemUiOverlayStyle.dark,
    //     child: HomeScreen(),
    //   ),
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).appBarTheme.brightness,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Container(
          child: FutureBuilder(
            future: FirebaseFirestore.instance.collection('appInfo').get(),
            builder: (BuildContext context, AsyncSnapshot sh) {
              if (sh.hasData) {
                if (sh.data == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_rounded,
                              size: 70.0,
                              color: Color.fromRGBO(249, 101, 116, 1)),
                          SizedBox(height: 20.0),
                          Text(
                            'Coś poszło nie tak, z serwera przyszly puste dane',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .color ??
                                  Colors.red,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          // Text(
                          //   'Aby zapewnić jak najlepszą jakość usług cały czas staramy się wprowadzić nowe funkcje i usprawniać już istniejące. Nowa wersja wprowadziła drastyczne zmiany w sposobie działania bazy danych lub sposobie jej łączenia z aplikacją, przez co należy zaktualizować aplikację do wersji, która będzie działać i rozumieć nowe instrukcje.',
                          //   textAlign: TextAlign.justify,
                          //   style: TextStyle(
                          //     fontSize: 16.0,
                          //     color: Colors.grey,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  );
                }
                dynamic data = sh.data.docs;
                dynamic versions = data[0] ?? [];
                dynamic settings = data[1] ?? [];
                List? usersList = data[2]['usersList'];
                dynamic usersToBeVerified = data[2];
                Provider.of<UserData>(context, listen: false).showAds =
                    !kIsWeb && (settings['showAds'] ?? true);
                if (apiVersion >= versions['minimum']) {
                  return StreamBuilder<User?>(
                    stream: Provider.of<FirebaseAuth>(context, listen: false)
                        .authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        User? _user = snapshot.data;
                        if (_user == null) return LoginScreen();
                        return Container(
                          child: FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(_user.uid)
                                  .get(),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.hasData) {
                                  Map _data = snapshot.data.data();

                                  Provider.of<UserData>(context, listen: false)
                                          .currentVersion =
                                      versions['current'] ?? apiVersion;
                                  Provider.of<UserData>(context, listen: false)
                                          .minimumVersion =
                                      versions['minimum'] ?? apiVersion;
                                  Provider.of<UserData>(context, listen: false)
                                          .workingVersion =
                                      versions['working'] ?? apiVersion;
                                  Provider.of<UserData>(context, listen: false)
                                      .thisVersion = apiVersion;

                                  Provider.of<UserData>(context, listen: false)
                                      .currentUserId = _user.uid;
                                  if (!kIsWeb)
                                    FirebaseCrashlytics.instance
                                        .setUserIdentifier(
                                            _user.uid.toString());
                                  Provider.of<UserData>(context, listen: false)
                                          .isVerCodeSet =
                                      _data.containsKey('verificationCode');
                                  Provider.of<UserData>(context, listen: false)
                                      .name = _user.displayName ?? 'Brak';
                                  Provider.of<UserData>(context, listen: false)
                                      .mail = _user.email ?? 'Brak';
                                  Provider.of<UserData>(context, listen: false)
                                          .isPhoneVerified =
                                      !(_data['phoneNumber'] == 'none');
                                  Provider.of<UserData>(context, listen: false)
                                      .currentUserPhoto = _user
                                          .photoURL ??
                                      'https://techpowerusa.com/wp-content/uploads/2017/06/default-user.png';

                                  bool admin = _data.containsKey('admin')
                                      ? (_data['admin'] ?? false)
                                      : false;

                                  Provider.of<UserData>(context, listen: false)
                                      .isAdmin = admin;
                                  Provider.of<UserData>(context, listen: false)
                                      .isVerified = _data['verified'] ?? false;
                                  if (admin) {
                                    Provider.of<UserData>(context,
                                            listen: false)
                                        .usersList = usersList ?? [];
                                    Provider.of<UserData>(context,
                                                listen: false)
                                            .usersToBeVerified =
                                        usersToBeVerified ?? [];
                                  }
                                  return MainScreen();
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Coś poszło nie tak, 1 błąd:',
                                          ),
                                          Text(
                                            snapshot.error.toString(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Coś poszło nie tak, 2 błąd:',
                                          ),
                                          Text(
                                            snapshot.error.toString(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                              }),
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  );
                } else {
                  // return Center(child: Text(
                  //   'Wymagana pilna aktualizacja aplikacji - Wymagana pilna aktualizacja aplikacji'
                  // ),);
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.dangerous_rounded,
                              size: 70.0,
                              color: Color.fromRGBO(249, 101, 116, 1)),
                          SizedBox(height: 20.0),
                          Text(
                            'Wymagana pilna aktualizacja aplikacji!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.headline5!.color ?? Colors.red,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'Aby zapewnić jak najlepszą jakość usług cały czas staramy się wprowadzić nowe funkcje i usprawniać już istniejące. Nowa wersja wprowadziła drastyczne zmiany w sposobie działania bazy danych lub sposobie jej łączenia z aplikacją, przez co należy zaktualizować aplikację do wersji, która będzie działać i rozumieć nowe instrukcje.',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              } else if (sh.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Coś poszło nie tak, 3 błąd:',
                        ),
                        Text(
                          sh.error.toString(),
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
