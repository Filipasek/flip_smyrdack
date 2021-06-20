import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class UserScreen extends StatefulWidget {
  String userId;
  UserScreen(this.userId);
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
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
            .doc(widget.userId)
            .get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            dynamic data = snapshot.data!.data();
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
                        color: Theme.of(context).textTheme.headline5!.color,
                      ),
                    ),
                  ),
                ),
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
                            color: Theme.of(context).textTheme.headline5!.color,
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
                            color: Theme.of(context).textTheme.headline5!.color,
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
