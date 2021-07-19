import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flip_smyrdack/models/config.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

String get bannerAdUnitId {
  /// Always test with test ads
  if (kDebugMode && !kIsWeb)
    return MobileAds.bannerAdTestUnitId;
  else
    return 'ca-app-pub-9537370157330943/6534905339';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (!kIsWeb)
    FirebaseCrashlytics.instance.setCustomKey("screen name", 'main()');
  if (kIsWeb) {
    timeago.setLocaleMessages('pl', timeago.PlMessages());
    initializeDateFormatting('pl_PL');
    runApp(MyApp());
  } else {

    runZonedGuarded<Future<void>>(() async {
      timeago.setLocaleMessages('pl', timeago.PlMessages());
      MobileAds.initialize(
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
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb)
      FirebaseCrashlytics.instance.setCustomKey("screen name", 'MyApp');
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
          // ChangeNotifierProvider<ConfigData>(create: (_) => ConfigData()),
          // ChangeNotifierProvider<UIData>(create: (_) => UIData()),
        ],
        child: App(),
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
    if (!kIsWeb)
      FirebaseCrashlytics.instance.setCustomKey("screen name", 'App');
    // Provider.of<ConfigData>(context, listen: false).readConfigs();
    // FlutterStatusbarManager.setColor(Theme.of(context).primaryColor,
    //     animated: true);
    // FlutterStatusbarManager.setNavigationBarColor(
    //     Theme.of(context).primaryColor,
    //     animated: true);
    // FlutterStatusbarManager.setNavigationBarStyle(NavigationBarStyle.DARK);
    // FlutterStatusbarManager.setStyle(StatusBarStyle.DARK_CONTENT);
    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle(
    //       // statusBarColor: Colors.transparent,
    //       // statusBarIconBrightness: Brightness.light,
    //       // systemNavigationBarColor: Colors.transparent,
    //       // systemNavigationBarIconBrightness: Brightness.light,
    //       // statusBarBrightness: Brightness.light,
    //       ),
    // );
    // return AnnotatedRegion<SystemUiOverlayStyle>(
    //   value: SystemUiOverlayStyle.light,
    //   child: HomeScreen(),
    // );
    return MaterialApp(
      color: Colors.white,
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
        appBarTheme: AppBarTheme(
          elevation: 0,
          color: Colors.white,
          brightness: Brightness.light,
        ),
        cupertinoOverrideTheme: CupertinoThemeData(brightness: Brightness.light),
      ),
      darkTheme: ThemeData(
        fontFamily: 'Comfortaa',
        primaryColor: Color.fromRGBO(40, 44, 55, 1),
        accentColor: Color.fromRGBO(234, 112, 112, 1),
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.grey),
          headline5: TextStyle(color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          color: Color.fromRGBO(40, 44, 55, 1),
          brightness: Brightness.dark,
        ),
        cupertinoOverrideTheme: CupertinoThemeData(brightness: Brightness.dark),
      ),
      home: Container(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: HomeScreen(),
      ),
      // home: AnnotatedRegion<SystemUiOverlayStyle>(
      //   value: SystemUiOverlayStyle.dark,
      //   child: HomeScreen(),
      // ),
    );
    // return HomeScreen();
    // return Scaffold();
  }
}
