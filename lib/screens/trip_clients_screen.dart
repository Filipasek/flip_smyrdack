import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/user_screen.dart';
import 'package:flip_smyrdack/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TripClientsScreen extends StatefulWidget {
  List clients;
  String tripId;
  String transportId;
  TripClientsScreen(this.clients, this.tripId, this.transportId);

  @override
  _TripClientsScreenState createState() => _TripClientsScreenState();
}

class _TripClientsScreenState extends State<TripClientsScreen> {
  bool isMaster = false;
  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < widget.clients.length; i++) {
      if (widget.clients[i]['id'] == widget.transportId) isMaster = true;
    }
    if (!kIsWeb)
      FirebaseCrashlytics.instance.setCustomKey("screen name", 'Eagers List');
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0.0,
        title: Text(isMaster ? "Klienci" : 'Towarzysze dojazdu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: widget.clients.length,
          itemBuilder: (BuildContext context, int index) {
            return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.clients[index]['id'])
                  .get(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  dynamic data = snapshot.data!.data();

                  if (data != null) {
                    return FlatButton(
                      onPressed: Provider.of<UserData>(context, listen: false)
                                  .isAdmin ??
                              false
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) {
                                    return UserScreen(
                                        widget.clients[index]['id']);
                                  },
                                ),
                              );
                            }
                          : () {},
                      height: 60.0,
                      // icon: Icon(
                      //   Icons.portrait_outlined,
                      //   size: 35.0,
                      //   color: Theme.of(context).accentColor,
                      // ),
                      child: Column(
                        children: [
                          Text(
                            data.containsKey('realName')
                                ? data['realName']
                                : data['name'],
                            // 'nice',
                            style: TextStyle(
                              fontSize: 25.0,
                              color:
                                  Theme.of(context).textTheme.headline5!.color,
                            ),
                          ),
                          (Provider.of<UserData>(context, listen: false)
                                          .isAdmin ??
                                      false) ||
                                  widget.clients[index]['id'] ==
                                      widget.transportId
                              ? Text(
                                  'z: ${widget.clients[index]['where']}',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .color,
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    );
                  } else {
                    AuthService.removeUserFromTransport(
                        widget.tripId,
                        widget.clients[index]['id'],
                        widget.transportId,
                        widget.clients[index]['id']);
                    return SizedBox();
                  }
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
            );
          },
        ),
      ),
    );
  }
}
