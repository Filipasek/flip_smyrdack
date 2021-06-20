import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/user_screen.dart';
import 'package:flip_smyrdack/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EagersListScreen extends StatefulWidget {
  String tripId;
  List eagers;
  EagersListScreen(this.eagers, this.tripId);

  @override
  _EagersListScreenState createState() => _EagersListScreenState();
}

class _EagersListScreenState extends State<EagersListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Chętne osoby'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: widget.eagers.length,
          itemBuilder: (BuildContext context, int index) {
            return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.eagers[index])
                  .get(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  dynamic data = snapshot.data!.data();

                  if (data != null) {
                    return FlatButton(
                      onPressed:
                          Provider.of<UserData>(context, listen: false).isAdmin ??
                                  false
                              ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) {
                                        return UserScreen(widget.eagers[index]);
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
                      child: Text(
                        data.containsKey('realName')
                            ? data['realName']
                            : data['name'],
                        // 'nice',
                        style: TextStyle(
                          fontSize: 25.0,
                          color: Theme.of(context).textTheme.headline5!.color,
                        ),
                      ),
                    );
                  } else {
                    AuthService.removeUserFromTrip(
                      widget.tripId,
                      widget.eagers[index],
                    );
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
