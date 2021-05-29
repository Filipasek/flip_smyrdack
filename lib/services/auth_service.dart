import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flip_smyrdack/main.dart';
// import 'package:provider/provider.dart';
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
  // String generateRandomString(int len) {
  //   var r = Random();
  //   const _chars = 'ABCDEFGHKLMNPQRSTUVWXYZ112233445566778899';
  //   return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
  //       .join();
  // }

  static Future sendVerificationRequest(String _userId, String _name) async {
    bool good = false;
    String generateRandomString(int len) {
      var r = Random();
      const _chars = 'ABCDEFGHKLMNPQRSTUVWXYZ112233445566778899';
      return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
          .join();
    }

    try {
      Map<String, dynamic> userData = {
        'name': _name,
        'userId': _userId,
      };
      await _firestore.collection('/users').doc(_userId).update({
        'verificationCode': generateRandomString(6),
      }).then((value) {
        good = true;
      }).onError((error, stackTrace) {
        return Future.error(
            error ?? 'Coś poszło nie tak podczas generowania kodu.');
      });

      await _firestore
          .collection('/appInfo')
          .doc('users to be verified')
          .update({
        'usersList': FieldValue.arrayUnion([_userId]),
      }).then((value) {
        good = true;
      }).onError((error, stackTrace) {
        return Future.error(
            error ?? 'Coś poszło nie tak podczas generowania kodu.');
      });

      await _firestore.collection('/appInfo').doc('users to be verified').set({
        _userId: userData,
      }, SetOptions(merge: true)).then((value) {
        good = true;
      }).onError((error, stackTrace) {
        return Future.error(error ??
            'Coś poszło nie tak podczas ustawiania powiadomienia dla adminów.');
      });
      if (good) return true;
    } catch (e) {
      return Future.error(e);
    }
    return false;
  }

  static Future<bool> verifyUser(String _id, String _verCode) async {
    try {
      DocumentSnapshot<Map<dynamic, dynamic>> docs =
          await _firestore.collection('/users').doc(_id.toString()).get();
      Map result = docs.data()!;
      String code = result.containsKey('verificationCode')
          ? result['verificationCode'].toString()
          : '';
      if (code == _verCode) {
        bool good = false;
        await _firestore.collection('/users').doc(_id.toString()).update({
          "verified": true,
        }).then((value) {
          good = true;
        }).onError((error, stackTrace) {
          return Future.error(error ?? 'Coś poszło nie tak');
        });
        await _firestore
            .collection('/appInfo')
            .doc('users to be verified')
            .update({
          'usersList': FieldValue.arrayRemove([_id]),
        }).then((value) {
          good = true;
        }).onError((error, stackTrace) {
          return Future.error(
              error ?? 'Coś poszło nie tak podczas generowania kodu.');
        });

        if (good) return true;
      } else
        return Future.error('Kod nie jest poprawny!');
    } catch (e) {
      return Future.error(e);
    }
    return false;
  }

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
    int elevDifferences,
    int tripLength,
    bool isAdmin,
  ) async {
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
        'elevation_differences': elevDifferences,
        'trip_length': tripLength,
        'showable': true,
        'verified': isAdmin, //TODO: check
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
