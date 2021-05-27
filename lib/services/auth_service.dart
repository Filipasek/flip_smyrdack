import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../main.dart';
// ignore: unused_import
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final _firestore = FirebaseFirestore.instance;
  // var admin = require('firebase-admin');
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

  static Future<File?> compressImage(String photoId, File image) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    File? compressedImageFile = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      '$path/img_$photoId.jpg',
      quality: 40,
    );
    return compressedImageFile;
  }
  
  // static Future<void> getUserNamesFromList(List<String> _idList) async {
  //   try {
  //     for (var item in _idList) {
  //       await _firestore.collection('/users').doc(item).get();
  //     }
  //   } catch (e) {
  //   }
  // }

  static Future<bool> addUserToTrip(String _id, String _userId) async {
    try {
      await _firestore.collection('/trips').doc(_id.toString()).update({
        "eagers": FieldValue.arrayUnion([_userId]),
      });
    } catch (e) {
      return Future.error(e);
    }
    return true;
  }
  static Future<bool> removeUserFromTrip(String _id, String _userId) async {
    try {
      await _firestore.collection('/trips').doc(_id.toString()).update({
        "eagers": FieldValue.arrayRemove([_userId]),
      });
    } catch (e) {
      return Future.error(e);
    }
    return true;
  }

  static Future<bool> addTripToDatabase(
      String name,
      int transportCost,
      int otherCosts,
      String description,
      DateTime date,
      TimeOfDay startTime,
      TimeOfDay endTime,
      List<File> photos,
      String difficulty,
      int elevation,
      int elev_differences,
      int trip_length) async {
    Future<bool> uploadFile(File file, String _id, int index) async {
      // File file = File(filePath);

      try {
        await FirebaseStorage.instance
            .ref('photos/${_id}_$index.${file.path.split(".").last}')
            .putFile((await compressImage('${_id}_$index', file))!);
      } on FirebaseException catch (e) {
        // e.g, e.code == 'canceled'
        return false;
      }
      return true;
    }

    int _id = DateTime.now().microsecondsSinceEpoch;

    for (int i = 0; i < photos.length; i++) {
      if (!(await uploadFile(photos[i], _id.toString(), i))) return false;
    }
    try {
      _firestore.collection('/trips').doc(_id.toString()).set({
        'name': name,
        'transportCost': transportCost,
        'otherCosts': otherCosts,
        'description': description,
        'date': date,
        'startTime':
            '${startTime.hour < 10 ? '0${startTime.hour}' : startTime.hour}:${startTime.minute < 10 ? '0${startTime.minute}' : startTime.minute}',
        'endTime':
            '${endTime.hour < 10 ? '0${endTime.hour}' : endTime.hour}:${endTime.minute < 10 ? '0${endTime.minute}' : endTime.minute}',
        'createdTimestamp': _id,
        'photosCount': photos.length,
        'photo0': await FirebaseStorage.instance
            .ref('photos/${_id}_0.${photos[0].path.split(".").last}')
            .getDownloadURL(),
        'photo1': await FirebaseStorage.instance
            .ref('photos/${_id}_1.${photos[1].path.split(".").last}')
            .getDownloadURL(),
        'photo2': await FirebaseStorage.instance
            .ref('photos/${_id}_2.${photos[2].path.split(".").last}')
            .getDownloadURL(),
        'photo3': photos.length >= 4
            ? await FirebaseStorage.instance
                .ref('photos/${_id}_3.${photos[3].path.split(".").last}')
                .getDownloadURL()
            : 'none',
        'photo4': photos.length >= 5
            ? await FirebaseStorage.instance
                .ref('photos/${_id}_4.${photos[4].path.split(".").last}')
                .getDownloadURL()
            : 'none',
        'difficulty': difficulty,
        'elevation': elevation,
        'elevation_differences': elev_differences,
        'trip_length': trip_length,
        'showable': true,
        'verified': true, //TODO: check
        // 'transportCost': transportCost,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      return false;
    }
    return true;
  }

  static Future addUserToDatabase(
    userId,
    String? name,
    String? contactData,
    String? avatar,
    bool isVerified,
    String phoneNumber,
  ) async {
    _firestore.collection('/users').doc(userId).set({
      'name': name,
      'contactData': contactData,
      'avatar': avatar,
      'last_login': DateTime.now(),
      'first_login': DateTime.now(),
      'verified': false,
      'admin': false,
      'phoneNumber': phoneNumber,
      'hasBeenVerifiedByGoogleOrSomethingIdk': isVerified,
    }, SetOptions(merge: false));
  }

  static Future updateUserInDatabase(
    userId,
    String? name,
    String? contactData,
    String? avatar,
    bool isVerified,
    String phoneNumber,
  ) async {
    _firestore.collection('/users').doc(userId).update({
      'name': name,
      'contactData': contactData,
      'avatar': avatar,
      'last_login': DateTime.now(),
      'phoneNumber': phoneNumber,
      'hasBeenVerifiedByGoogleOrSomethingIdk': isVerified,
    });
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

    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User? user = authResult.user;

    assert(!user!.isAnonymous);
    // assert(await user!.getIdToken() != null);

    final User? currentUser = _auth.currentUser;
    assert(user!.uid == currentUser!.uid);
    //needs to be checked if user exists
    if (authResult.additionalUserInfo!.isNewUser) {
      await addUserToDatabase(
        user!.uid,
        user.displayName,
        user.email,
        user.photoURL,
        user.emailVerified,
        user.phoneNumber ?? 'none',
      );
    } else {
      await updateUserInDatabase(
        user!.uid,
        user.displayName,
        user.email,
        user.photoURL,
        user.emailVerified,
        user.phoneNumber ?? 'none',
      );
    }
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
