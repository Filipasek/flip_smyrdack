import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flip_smyrdack/models/config.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
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

