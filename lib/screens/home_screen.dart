import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/login_screen.dart';
import 'package:flip_smyrdack/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Provider.of<FirebaseAuth>(context, listen: false).authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? _user = snapshot.data;
          if (_user == null) return LoginScreen();
          Provider.of<UserData>(context, listen: false).currentUserId = _user.uid;
          return MainScreen();
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
