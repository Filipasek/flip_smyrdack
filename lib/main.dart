import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flip_smyrdack/models/config.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final initFuture = MobileAds.instance.initialize();
  // final adState = AdState(initFuture);
  await Firebase.initializeApp(
    // options: FirebaseOptions(
    //   apiKey: '64526134-67dc-4e9e-a93a-7eea9de7d95e',
    //   appId: 'acf8a433-1539-4f7b-9422-1c876982b833',
    //   messagingSenderId: 'ca75f581-5dfc-43af-b1f6-41ed391a2aad',
    //   projectId: 'bf984c50-1a0f-4d03-a51d-752d56fc3aa7',
    // ),
  );
  initializeDateFormatting('pl_PL');
  runApp(MyApp());
  // runApp(
  //   Provider.value(
  //     value: adState,
  //     builder: (context, child) => MyApp(),
  //   ),
  // );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
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
