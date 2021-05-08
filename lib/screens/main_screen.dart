import 'package:flip_smyrdack/models/user_data.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(
          'F&S',
          style: GoogleFonts.comfortaa(
            wordSpacing: 20.0,
            color: Theme.of(context).textTheme.headline5!.color,
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
          child: FlatButton(
              onPressed: () =>
                  Provider.of<UserData>(context, listen: false).logout(),
              child: Text('Wyloguj się'))),
    );
  }
}
