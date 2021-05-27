import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/add_trip.dart';
import 'package:flip_smyrdack/screens/details_screen.dart';
import 'package:flip_smyrdack/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    String? name = Provider.of<UserData>(context, listen: false).name;
    String begginingOfEmergencyText = name != null ? ", tutaj $name" : '';
    Future firebaseData = FirebaseFirestore.instance
        .collection('trips')
        .where("showable", isEqualTo: true)
        .get();
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0.0,
        leading: Provider.of<UserData>(context).isAdmin!
            ? IconButton(
                tooltip: 'Dodaj wstawkę',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return AddTripScreen();
                    },
                  ),
                ),
                icon: Icon(Icons.add_location_alt_outlined),
              )
            : null,
        actions: [
          Tooltip(
            message: 'Numer wersji',
            // padding: EdgeInsets.all(15.0),
            showDuration: Duration(seconds: 2),
            child: Text('v7'),
          ),
          Container(
            padding: EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: PopupMenuButton(
                enableFeedback: true,
                tooltip: 'Opcje',
                itemBuilder: (context) {
                  List<PopupMenuEntry> list = [
                    PopupMenuItem(
                      child: Text("Pokazuj tylko zweryfikowane wstawki"),
                      value: 0,
                      enabled: !Provider.of<UserData>(context, listen: false)
                          .isVerified!,
                    ),
                    PopupMenuItem(
                      child: Provider.of<UserData>(context, listen: false)
                              .isVerified!
                          ? Text('Konto zweryfikowane')
                          : Text("Zweryfikuj konto"),
                      value: 1,
                      enabled: !Provider.of<UserData>(context, listen: false)
                          .isVerified!,
                    ),
                    PopupMenuItem(
                      child: Text("Wyloguj się"),
                      value: 2,
                      enabled: true,
                    ),
                    // PopupMenuItem(
                    //   child: Text("Setting Language"),
                    //   value: 1,
                    // ),
                    // PopupMenuDivider(
                    //   height: 10,
                    // ),
                    // CheckedPopupMenuItem(
                    //   child: Text(
                    //     "Nie zweryfikowano",
                    //     style: TextStyle(color: Colors.black),
                    //   ),
                    //   value: 2,
                    //   checked: false,

                    // ),
                  ];
                  return list;
                },
                onSelected: (value) {
                  switch (value) {
                    case 2:
                      UserData().logout().then((value) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                              return HomeScreen();
                            },
                          ),
                        );
                      });

                      break;
                    default:
                  }
                },
                child: Image.network(
                  Provider.of<UserData>(context).currentUserPhoto!,
                ),
                // icon: Icon(
                //   Icons.settings,
                // ),
              ),
            ),
          ),
        ],
        title: Text(
          'Flip&Smyrdack',
          style: GoogleFonts.comfortaa(
            wordSpacing: 20.0,
            color: Theme.of(context).textTheme.headline5!.color,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100.0),
          child: PopupMenuButton(
            enableFeedback: true,
            tooltip: 'Opcje',
            itemBuilder: (context) {
              List<PopupMenuEntry> list = [
                PopupMenuItem(
                  child: Text("Zadzwoń do: Smyrdack"),
                  value: 0,
                  enabled: true,
                ),
                PopupMenuItem(
                  child: Text("Wyślij SMS-a do: Smyrdack"),
                  value: 1,
                  enabled: true,
                ),
                PopupMenuDivider(
                  height: 10,
                ),
                PopupMenuItem(
                  child: Text("Zadzwoń do: Flip"),
                  value: 2,
                  enabled: true,
                ),
                PopupMenuItem(
                  child: Text("Wyślij SMS-a do: Flip"),
                  value: 3,
                  enabled: true,
                ),
                // PopupMenuItem(
                //   child: Text("Setting Language"),
                //   value: 1,
                // ),
                // PopupMenuDivider(
                //   height: 10,
                // ),
                // CheckedPopupMenuItem(
                //   child: Text(
                //     "Nie zweryfikowano",
                //     style: TextStyle(color: Colors.black),
                //   ),
                //   value: 2,
                //   checked: false,

                // ),
              ];
              return list;
            },
            onSelected: (value) {
              switch (value) {
                case 0:
                  launch(Uri(
                    scheme: 'tel',
                    path: '+48518669037',
                    // queryParameters: {'body': 'Panie Przewodniku$begginingOfEmergencyText. Potrzebuję pilnego kontaktu.'},
                  ).toString());
                  break;
                case 1:
                  launch(Uri(
                    scheme: 'sms',
                    path: '+48518669037',
                    queryParameters: {
                      'body':
                          'Panie Przewodniku$begginingOfEmergencyText. Potrzebuję pilnego kontaktu.'
                    },
                  ).toString());
                  break;
                case 2:
                  launch(Uri(
                    scheme: 'tel',
                    path: '+48692847356',
                    // queryParameters: {'body': 'Panie Przewodniku$begginingOfEmergencyText. Potrzebuję pilnego kontaktu.'},
                  ).toString());
                  break;
                case 3:
                  launch(Uri(
                    scheme: 'sms',
                    path: '+48692847356',
                    queryParameters: {
                      'body':
                          'Panie Przewodniku$begginingOfEmergencyText. Potrzebuję pilnego kontaktu.'
                    },
                  ).toString());
                  break;
                default:
              }
            },
            child: Container(
              height: 60.0,
              width: 60.0,
              color: Theme.of(context).accentColor,
              child: Icon(
                Icons.call_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: firebaseData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List data = snapshot.data.docs;
            int length = data.length;

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  firebaseData =
                      FirebaseFirestore.instance.collection('trips').get();
                });
                return firebaseData;
              },
              child: length > 0
                  ? ListView.builder(
                      itemCount: length + 1,
                      itemBuilder: (context, index) {
                        if (index == length + 1) return SizedBox(height: 70.0);
                        dynamic info = data[index];
                        List<String> photosList = [];
                        for (int i = 0; i < info['photosCount']; i++) {
                          photosList = [
                            ...photosList,
                            ...[info['photo$i']]
                          ];
                        }
                        return Destinations(
                          index,
                          info['name'],
                          info['date'],
                          info['difficulty'],
                          info['transportCost'],
                          photosList,
                          info['description'],
                          info['endTime'],
                          info['otherCosts'],
                          info['startTime'],
                          info.data().containsKey('eagers')
                              ? info['eagers']
                              : [],
                          info['createdTimestamp'],
                          info['elevation'],
                          info['elevation_differences'],
                          info['trip_length'],
                        );
                      },
                    )
                  : Center(
                      child: Container(
                        margin: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.hiking_rounded,
                              size: 100.0,
                              color: Colors.black,
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              'Nie ma żadnych nadchodzących wypraw',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24.0,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 20.0),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  firebaseData = FirebaseFirestore.instance
                                      .collection('trips')
                                      .get();
                                });
                              },
                              icon: Icon(
                                Icons.refresh_rounded,
                                size: 30.0,
                              ),
                            ),
                          ],
                        ),
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

class Destinations extends StatelessWidget {
  int index;
  String name;
  String difficulty;
  String description;
  Timestamp date;
  int transportCost;
  int otherCosts;
  String startTime;
  String endTime;
  List eager;
  List<String> imageUrl; //TODO: list
  int _id;
  int elevation, elev_difference, trip_length;

  Destinations(
    this.index,
    this.name,
    this.date,
    this.difficulty,
    this.transportCost,
    this.imageUrl,
    this.description,
    this.endTime,
    this.otherCosts,
    this.startTime,
    this.eager,
    this._id,
    this.elevation,
    this.elev_difference,
    this.trip_length,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      margin: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
      height: 400.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          child: Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Hero(
                  tag: imageUrl[0],
                  child: Image.network(
                    imageUrl[0],
                    height: 300.0,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(10.0),
              //   child: Container(
              //     alignment: Alignment.topRight,
              //     child: Icon(Icons.verified_rounded),
              //   ),
              // ),
              Container(
                width: double.infinity,
                child: FlatButton(
                  disabledColor: Theme.of(context).accentColor,
                  disabledTextColor: Colors.black,
                  textColor: Theme.of(context).textTheme.headline5!.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  // splashColor: Color.fromRGBO(120, 254, 224, 1),
                  color: Colors.white.withOpacity(0.0001),
                  padding: EdgeInsets.fromLTRB(10.0, 300.0, 10.0, 5.0),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        return DetailsScreen(
                          index,
                          name,
                          date,
                          difficulty,
                          transportCost,
                          imageUrl,
                          description,
                          endTime,
                          otherCosts,
                          startTime,
                          elev_difference,
                          elevation,
                          trip_length,
                          eager,
                          _id,
                        );
                        // return DetailsScreen(
                        //     name, index, date, difficulty, cost, imageUrl);
                      },
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0,
                            ),
                          ),
                        ),
                      ),
                      Text("Trudność: $difficulty"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Text(
                          //   '${otherCosts + transportCost}zł',
                          //   style: TextStyle(
                          //     color: Colors.transparent,
                          //   ),
                          // ),
                          Tooltip(
                            message:
                                'Wstawka została zweryfikowana przez Zespół Flip&Smyrdack',
                            padding: EdgeInsets.all(15.0),
                            showDuration: Duration(seconds: 3),
                            child: Icon(
                              Icons.verified_rounded,
                              color: Colors.blue,
                              // color: Color.fromRGBO(65, 211, 189, 1),
                            ),
                          ),
                          Text(
                              "Kiedy: ${DateFormat('EEEE, dd MMM', 'pl_PL').format(date.toDate().toLocal())}"),
                          Tooltip(
                            message:
                                'Łączne koszty transportu i innych dodatków typu opłaty za wstęp. Po więcej informacji wejdź we wstawkę.',
                            padding: EdgeInsets.all(15.0),
                            showDuration: Duration(seconds: 4),
                            child: Text('${otherCosts + transportCost}zł'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
