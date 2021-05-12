import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/add_trip.dart';
import 'package:flip_smyrdack/screens/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
                  return Destinations(index, info['name'], info['date'],
                      info['difficulty'], info['cost'], info['image']);
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
  Timestamp date;
  int cost;
  String imageUrl;
  Destinations(this.index, this.name, this.date, this.difficulty, this.cost,
      this.imageUrl);
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
                tag: 'image$index',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image(
                    image: NetworkImage(
                      imageUrl,
                    ),
                    height: 300.0,
                    fit: BoxFit.fitHeight,
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
                            name, index, date, difficulty, cost, imageUrl);
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
                      Text("Trudność: łatwa"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${cost}zł',
                            style: TextStyle(
                              color: Colors.transparent,
                            ),
                          ),
                          Text("Kiedy: niedziela, 16 maja"),
                          Text('${cost}zł'),
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
