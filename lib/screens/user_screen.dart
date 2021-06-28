import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flip_smyrdack/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ndialog/ndialog.dart';
import 'package:url_launcher/url_launcher.dart';

class UserScreen extends StatefulWidget {
  String userId;
  UserScreen(this.userId);
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _formKey = GlobalKey<FormState>();
  String? newName;
  Future<DocumentSnapshot<Map<String, dynamic>>>? futData;
  @override
  Widget build(BuildContext context) {
    futData =
        FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    if (!kIsWeb)
      FirebaseCrashlytics.instance.setCustomKey("screen name", 'User Screen');
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Konto użytkownika'),
      ),
      body: FutureBuilder(
        future: futData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            dynamic data = snapshot.data!.data();
            return SingleChildScrollView(
              child: Column(
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
                        data.containsKey('realName')
                            ? data['realName']
                            : data['name'],
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.headline5!.color,
                        ),
                      ),
                    ),
                  ),
                  FlatButton.icon(
                    onPressed: () {
                      
                      DialogBackground(
                        blur: 15.0,
                        color: Theme.of(context).primaryColor,
                        dialog: AlertDialog(
                          backgroundColor: Theme.of(context).primaryColor,
                          title: Text(
                            "Zmień nazwę",
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .color),
                          ),
                          content: Container(
                            height: 250,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'Podaj prawidłowe imię i nazwisko tego użytkownika, żeby można było go zidentyfikować, a nie patrzeć na jakieś głupie FishFucker_69 czy inne ${data['name']}',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .color,
                                  ),
                                ),
                                Form(
                                  key: _formKey,
                                  child: TextFormField(
                                    // enabled: !widget.loading,
                                    // keyboardType:
                                    //     widget.type == 'int' ? TextInputType.number : TextInputType.text,
                                    style: TextStyle(
                                      // color: Theme.of(context).textTheme.headline5!.color,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color,
                                    ),
                                    showCursor: true,
                                    autocorrect: true,
                                    autofocus: false,
                                    // initialValue:
                                    //     widget.initialValue != null ? widget.initialValue.toString() : null,
                                    maxLines: null,
                                    cursorColor: Theme.of(context).accentColor,
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                        // color: Theme.of(context).textTheme.headline5!.color,
                                        // color: Theme.of(context).accentColor,
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .color,
                                      ),
                                      // labelText: widget.nazwa,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          // color: Theme.of(context).textTheme.headline5!.color!,
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline5!
                                              .color!,
                                          width: 2.0,
                                        ),
                                      ),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Wpisz dane";
                                      } else if (value.length < 5) {
                                        return 'Coś za krótkie';
                                      }
                                      return null;
                                    },
                                    onChanged: (text) {
                                      setState(() {
                                        newName = text;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                                child: Text(
                                  "Zapisz",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .color,
                                  ),
                                ),
                                onPressed: () async {
                                  // await AuthService.changeRealName(
                                  //     widget.userId, newName!);
                                  if (_formKey.currentState!.validate()) {
                                    await AuthService.changeRealName(
                                        widget.userId, newName!);
                                    if (mounted)
                                      setState(() {
                                        futData = FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(widget.userId)
                                            .get();
                                      });
                                  }
                                  // print('---------- $newName');
                                }),
                          ],
                        ),
                      ).show(context);
                    },
                    splashColor: Theme.of(context).accentColor,
                    label: Text(
                      'Zła nazwa? Ustaw poprawną',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.headline5!.color,
                      ),
                    ),
                    icon: Icon(
                      Icons.build_rounded,
                      color: Color.fromRGBO(249, 101, 116, 1),
                    ),
                  ),
                  data.containsKey('realName')
                      ? Center(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                            child: Text(
                              'Pierwotna nazwa: ${data['name']}',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .color,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
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
                        'Ilość wykopanych diamentów: ${data.containsKey('verificationCode') ? data['diamonds'] ?? 'błąd' : 'brak'} 💎',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Theme.of(context).textTheme.headline5!.color,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(
                            'Adres e-mail: ${data['contactData']}',
                            style: TextStyle(
                              fontSize: 14.0,
                              color:
                                  Theme.of(context).textTheme.headline5!.color,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            launch(Uri(
                              scheme: 'mailto',
                              path: data['contactData'],
                              queryParameters: {
                                'subject':
                                    'Administracja Flip&Smyrdack w sprawie weryfikacji konta'
                              },
                            ).toString());
                          },
                          icon: Icon(
                            Icons.mail_outline,
                            color: Theme.of(context).textTheme.headline5!.color,
                          ),
                        )
                      ],
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(
                            'Kod weryfikacyjny: ${data.containsKey('verificationCode') ? data['verificationCode'] : 'brak'}',
                            style: TextStyle(
                              fontSize: 14.0,
                              color:
                                  Theme.of(context).textTheme.headline5!.color,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: data['verificationCode']));
                          },
                          icon: Icon(
                            Icons.content_copy_rounded,
                            color: Theme.of(context).textTheme.headline5!.color,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
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
