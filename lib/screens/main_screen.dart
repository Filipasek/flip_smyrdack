// import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/add_trip.dart';
import 'package:flip_smyrdack/screens/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  
  @override
  Widget build(BuildContext context) {
    Future firebaseData = FirebaseFirestore.instance.collection('trips').get();
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        // elevation: 0.0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return AddTripScreen();
              },
            ),
          ),
          icon: Icon(Icons.add_location_alt_outlined),
        ),
        actions: [
          Container(
            padding: EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: GestureDetector(
                //TODO: animation
                onTap: () => UserData().logout(),
                child: Image.network(
                  Provider.of<UserData>(context).currentUserPhoto!,
                ),
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
              child: ListView.builder(
                itemCount: length,
                itemBuilder: (context, index) {
                  dynamic info = data[index];
                  List<String> photosList = [];
                  for(int i = 0; i< info['photosCount']; i++){
                    photosList = [...photosList, ...[info['photo$i']]];
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
                  );
                },
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
  List<String> imageUrl; //TODO: list

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
              Hero(
                tag: 'image${index}0',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image(
                    image: NetworkImage(
                      imageUrl[0],
                    ),
                    height: 300.0,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
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
                          Text(
                            '${otherCosts + transportCost}zł',
                            style: TextStyle(
                              color: Colors.transparent,
                            ),
                          ),
                          Text(
                              "Kiedy: ${DateFormat('EEEE, dd MMM', 'pl_PL').format(date.toDate().toLocal())}"),
                          Text('${otherCosts + transportCost}zł'),
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
