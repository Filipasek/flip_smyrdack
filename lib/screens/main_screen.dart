import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: FlatButton(onPressed: () => Provider.of<UserData>(context, listen: false).logout(), child: Text('Wyloguj się'))),
    );
  }
}