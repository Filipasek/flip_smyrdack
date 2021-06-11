import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flip_smyrdack/models/config.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:provider/provider.dart';

String get bannerAdUnitId {
  /// Always test with test ads
  if (kDebugMode)
    return MobileAds.bannerAdTestUnitId;
  else
    return 'ca-app-pub-9537370157330943/6534905339';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runZonedGuarded<Future<void>>(() async {
    await MobileAds.initialize(
      bannerAdUnitId: bannerAdUnitId,
    );

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);
    await FirebaseCrashlytics.instance.setUserIdentifier("unidentified");

    initializeDateFormatting('pl_PL');
    runApp(MyApp());
  }, FirebaseCrashlytics.instance.recordError);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Localizations(
      locale: const Locale('pl', 'en'),
      delegates: <LocalizationsDelegate<dynamic>>[
        DefaultWidgetsLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
      ],
      child: MultiProvider(
        providers: [
          Provider<FirebaseAuth>.value(
            value: FirebaseAuth.instance,
          ),
          // Provider<PushNotificationService>(
          //   create: (_) => PushNotificationService(),
          // ),
          ChangeNotifierProvider<UserData>(create: (_) => UserData()),
          ChangeNotifierProvider<ConfigData>(create: (_) => ConfigData()),
          // ChangeNotifierProvider<UIData>(create: (_) => UIData()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flip&Smyrdack',
          themeMode: ThemeMode.system,
          theme: ThemeData(
            fontFamily: 'Comfortaa',
            primaryColor: Colors.white,
            accentColor: Color.fromRGBO(255, 182, 185, 1),
            textTheme: TextTheme(
              bodyText2: TextStyle(color: Colors.grey),
              headline5: TextStyle(color: Colors.black),
            ),
          ),
          // darkTheme: ThemeData(
          //   fontFamily: 'Comfortaa',
          //   primaryColor: Color.fromRGBO(40, 44, 55, 1),
          //   accentColor: Color.fromRGBO(255, 182, 185, 1),
          //   textTheme: TextTheme(
          //     bodyText2: TextStyle(color: Colors.grey),
          //     headline5: TextStyle(color: Colors.white),
          //   ),
          // ),
          home: App(),
        ),
      ),
    );
  }
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    // Provider.of<ConfigData>(context, listen: false).readConfigs();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return HomeScreen();
    // return Scaffold();
  }
}
