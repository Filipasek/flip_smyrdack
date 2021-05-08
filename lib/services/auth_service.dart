import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../main.dart';
// ignore: unused_import
import 'package:provider/provider.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final _firestore = FirebaseFirestore.instance;
  static void signUpUser(
      BuildContext context, String name, String email, String password) async {
    name = name.trim();
    email = email.trim();
    password = password.trim();

    UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User? signedInUser = authResult.user;
    if (signedInUser != null) {
      // Provider.of<UserData>(context, listen: false).currentUserId =
      //     signedInUser.uid;
      Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => MyApp()));
    }
  }

  static Future addUserToDatabase(
      userId, String? name, String? contactData, String? avatar) async {
    _firestore.collection('/users').doc(userId).set({
      'name': name,
      'contactData': contactData,
      'avatar': avatar,
    }, SetOptions(merge: true));
  }

  static void signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult = await _auth.signInWithCredential(credential);
    final User? user = authResult.user;

    assert(!user!.isAnonymous);
    // assert(await user!.getIdToken() != null);

    final User? currentUser = _auth.currentUser;
    assert(user!.uid == currentUser!.uid);

    await addUserToDatabase(
        user!.uid, user.displayName, user.email, user.photoURL);
    //needs to be checked if user exists
  }

  static void logout(context) async {
    // await Provider.of<UserData>(context, listen: false).logout();
    _auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => MyApp()));

    // Navigator.pushReplacementNamed(context, LoginScreen.id);
  }

  static void login(BuildContext context, String email, String password) async {
    email = email.trim();
    password = password.trim();
    try {
      UserCredential authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      // ignore: unused_local_variable
      User? signedInUser = authResult.user;
      // Provider.of<UserData>(context, listen: false).currentUserId =
      //     signedInUser.uid;
      // Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => MyApp()));
    } on Exception catch (e) {
      print(e);
    }
  }
}
