import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/login_screen.dart';
import 'package:flip_smyrdack/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  int apiVersion = 10; //TODO: change when major update been made to api
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('appInfo').get(),
        builder: (BuildContext context, AsyncSnapshot sh) {
          if (sh.hasData) {
            dynamic data = sh.data!.docs;
            dynamic versions = data[0];
            List usersList =
                data[1]['usersList'] ?? [];
            dynamic usersToBeVerified = data[1];
            if (apiVersion >= versions['minimum']) {
              return StreamBuilder<User?>(
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
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            Map _data = snapshot.data!.data();

                            Provider.of<UserData>(context, listen: false)
                                .currentVersion = versions['current'];
                            Provider.of<UserData>(context, listen: false)
                                .minimumVersion = versions['minimum'];
                            Provider.of<UserData>(context, listen: false)
                                .workingVersion = versions['working'];
                            Provider.of<UserData>(context, listen: false)
                                .thisVersion = apiVersion;

                            Provider.of<UserData>(context, listen: false)
                                .currentUserId = _user.uid;
                            Provider.of<UserData>(context, listen: false)
                                    .isVerCodeSet =
                                _data.containsKey('verificationCode');
                            Provider.of<UserData>(context, listen: false).name =
                                _user.displayName;
                            Provider.of<UserData>(context, listen: false).mail =
                                _user.email;
                            Provider.of<UserData>(context, listen: false)
                                .currentUserPhoto = _user.photoURL;

                            Provider.of<UserData>(context, listen: false)
                                .isAdmin = _data['admin'];
                            Provider.of<UserData>(context, listen: false)
                                .isVerified = _data['verified'];
                            if (_data['admin']) {
                              Provider.of<UserData>(context, listen: false)
                                  .usersList = usersList;
                              Provider.of<UserData>(context, listen: false)
                                  .usersToBeVerified = usersToBeVerified;
                            }
                            return MainScreen();
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                          size: 70.0, color: Color.fromRGBO(249, 101, 116, 1)),
                      SizedBox(height: 20.0),
                      Text(
                        'Wymagana pilna aktualizacja aplikacji!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
    );
  }
}
