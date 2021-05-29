import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UsersToBeVerifiedScreen extends StatefulWidget {
  @override
  _UsersToBeVerifiedScreenState createState() =>
      _UsersToBeVerifiedScreenState();
}

class _UsersToBeVerifiedScreenState extends State<UsersToBeVerifiedScreen> {
  @override
  Widget build(BuildContext context) {
    List usersList = Provider.of<UserData>(context, listen: false).usersList!;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Wybierz użytkownika'),
      ),
      body: ListView.builder(
          itemCount: usersList.length,
          itemBuilder: (BuildContext context, int index) {
            String name = Provider.of<UserData>(context, listen: false)
                .usersToBeVerified[usersList[index].toString()]['name'];
            String userId = Provider.of<UserData>(context, listen: false)
                .usersToBeVerified[usersList[index].toString()]['userId'];
            return FlatButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return UserScreen(userId);
                    },
                  ),
                );
              },
              height: 60.0,
              icon: Icon(
                Icons.face,
                size: 35.0,
                color: Color.fromRGBO(255, 182, 185, 1),
              ),
              label: Text(
                name,
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
            );
          }),
    );
  }
}
