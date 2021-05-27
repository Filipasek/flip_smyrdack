import 'package:cloud_firestore/cloud_firestore.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: StreamBuilder<User?>(
        stream: Provider.of<FirebaseAuth>(context, listen: false)
            .authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? _user = snapshot.data;
            if (_user == null) return LoginScreen();
            return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(_user.uid)
                    .get(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    Map _data = snapshot.data!.data();
                    Provider.of<UserData>(context, listen: false)
                        .currentUserId = _user.uid;
                    Provider.of<UserData>(context, listen: false).name =
                        _user.displayName;
                    Provider.of<UserData>(context, listen: false).mail =
                        _user.email;
                    Provider.of<UserData>(context, listen: false)
                        .currentUserPhoto = _user.photoURL;
                    Provider.of<UserData>(context, listen: false).isAdmin =
                        _data['admin'];
                    Provider.of<UserData>(context, listen: false).isVerified =
                        _data['verified'];
                    return MainScreen();
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
                });
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
