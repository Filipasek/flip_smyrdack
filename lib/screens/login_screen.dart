import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    // return GestureDetector(
    //   onTap: () {
    //     FocusScopeNode currentFocus = FocusScope.of(context);
    //     if (!currentFocus.hasPrimaryFocus) {
    //       currentFocus.unfocus();
    //     }
    //   },
    //   child: Scaffold(
    //     backgroundColor: Theme.of(context).primaryColor,
    //     body: Container(
    //       child: LoginForm(),
    //     ),
    //   ),
    // );
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 150.0, left: 15.0),
            child: Text(
              'Flip&\nSmyrdack',
              style: GoogleFonts.comfortaa(
                wordSpacing: 20.0,
                color: Theme.of(context).textTheme.headline5!.color,
                fontSize: 60.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 0.0, width: double.infinity),
          Container(
            padding: EdgeInsets.only(bottom: 20.0),
            child: FlatButton(
              onPressed: () {
                //TODO: maybe show loading
                AuthService.signInWithGoogle();
              },
              child: Text(
                'Zaloguj się poprzez Google',
                style: TextStyle(
                  // color: Provider.of<ColorData>(context).secondaryTextColor,
                  color: Theme.of(context).textTheme.bodyText2!.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
