import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
      }).onError((error, stackTrace) async {
        await FirebaseCrashlytics.instance.recordError(e, stackTrace,
            reason: 'Sending verification request', fatal: true);
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
      }).onError((error, stackTrace) async {
        await FirebaseCrashlytics.instance.recordError(e, stackTrace,
            reason: 'Sending verification request', fatal: true);
        return Future.error(
            error ?? 'Coś poszło nie tak podczas generowania kodu.');
      });

      await _firestore.collection('/appInfo').doc('users to be verified').set({
        _userId: userData,
      }, SetOptions(merge: true)).then((value) {
        good = true;
      }).onError((error, stackTrace) async {
        await FirebaseCrashlytics.instance.recordError(e, stackTrace,
            reason: 'Sending verification request', fatal: true);
        return Future.error(error ??
            'Coś poszło nie tak podczas ustawiania powiadomienia dla adminów.');
      });
      if (good) return true;
    } catch (e, stacktrace) {
      await FirebaseCrashlytics.instance.recordError(e, stacktrace,
          reason: 'Sending verification request', fatal: true);
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
        }).onError((error, stackTrace) async {
          await FirebaseCrashlytics.instance.recordError(e, stackTrace,
              reason: 'Verifying user', fatal: true);
          return Future.error(error ?? 'Coś poszło nie tak');
        });
        await _firestore
            .collection('/appInfo')
            .doc('users to be verified')
            .update({
          'usersList': FieldValue.arrayRemove([_id]),
        }).then((value) {
          good = true;
        }).onError((error, stackTrace) async {
          await FirebaseCrashlytics.instance.recordError(e, stackTrace,
              reason: 'Verifying user', fatal: true);
          return Future.error(
              error ?? 'Coś poszło nie tak podczas generowania kodu.');
        });

        if (good) return true;
      } else
        return Future.error('Kod nie jest poprawny!');
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance
          .recordError(e, stackTrace, reason: 'Verifying user', fatal: true);
      return Future.error(e);
    }
    return false;
  }

  static Future<bool> hideTrip(String _id) async {
    try {
      await _firestore.collection('/trips').doc(_id.toString()).update({
        "showable": false,
      });
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance
          .recordError(e, stackTrace, reason: 'Hiding a trip', fatal: false);
      return Future.error(e);
    }
    return true;
  }

  static Future<bool> changeRealName(String _id, String _name) async {
    try {
      await _firestore.collection('/users').doc(_id.toString()).set({
        "realName": _name,
      }, SetOptions(merge: true));
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(e, stackTrace,
          reason: 'Adding new name to $_name', fatal: false);
      return Future.error(e);
    }
    return true;
  }

  static Future<bool> joinTransport(
      String _tripId, String _userId, String _transportId, String place) async {
        
    try {
      Map _clientInfo = {
        'id': _userId,
        'where': place,
      };
      await _firestore
          .collection('/trips')
          .doc(_tripId.toString())
          .collection('transport')
          .doc(_transportId)
          .update({
        "clients": FieldValue.arrayUnion([_clientInfo]),
      });
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(e, stackTrace,
          reason: 'Joining transport', fatal: false);
      return Future.error(e);
    }
    return true;
  }

  static Future<bool> addTransport(
    String _tripId,
    String _transportId,
    int availableSeats,
    bool calculatePerPerson,
    int costs,
    String from,
    TimeOfDay leaving,
    String name,
    String pickup,
  ) async {

    try {
      await _firestore
          .collection('/trips')
          .doc(_tripId.toString())
          .collection('transport')
          .doc(_transportId)
          .set({
        'availableSeats': availableSeats,
        'calculatePerPerson': calculatePerPerson,
        'costs': costs,
        'from': from,
        'leaving':
            '${leaving.hour < 10 ? '0${leaving.hour}' : leaving.hour}:${leaving.minute < 10 ? '0${leaving.minute}' : leaving.minute}',
        'name': name,
        'pick-up': pickup,
        'userId': _transportId,
        'clients': [
          {
            'id': _transportId,
            'where': from,
          }
        ],
      });
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(e, stackTrace,
          reason: 'Deleting a transport', fatal: false);
      return Future.error(e);
    }
    return true;
  }

  static Future<bool> removeTransport(
      String _tripId, String _transportId) async {
    try {
      await _firestore
          .collection('/trips')
          .doc(_tripId.toString())
          .collection('transport')
          .doc(_transportId)
          .delete();
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(e, stackTrace,
          reason: 'Deleting a transport', fatal: false);
      return Future.error(e);
    }
    return true;
  }

  static Future<bool> removeUserFromTransport(
      String _tripId, String _userId, String _transportId, String place) async {
    try {
      Map _clientInfo = {
        'id': _userId,
        'where': place,
      };
      await _firestore
          .collection('/trips')
          .doc(_tripId.toString())
          .collection('transport')
          .doc(_transportId)
          .update({
        "clients": FieldValue.arrayRemove([_clientInfo]),
      });
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(e, stackTrace,
          reason: 'Removing from transport', fatal: false);
      return Future.error(e);
    }
    return true;
  }

  static Future<bool> addUserToTrip(String _id, String _userId) async {
    try {
      await _firestore.collection('/trips').doc(_id.toString()).update({
        "eagers": FieldValue.arrayUnion([_userId]),
      });
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(e, stackTrace,
          reason: 'Adding user to trip', fatal: false);
      return Future.error(e);
    }
    return true;
  }

  static Future<bool> removeUserFromTrip(String _id, String _userId) async {
    try {
      await _firestore.collection('/trips').doc(_id.toString()).update({
        "eagers": FieldValue.arrayRemove([_userId]),
      });
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(e, stackTrace,
          reason: 'Removing user from trip', fatal: false);
      return Future.error(e);
    }
    return true;
  }

  static Future<bool> addTripToDatabase(
    int _id,
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
    bool sendPhotos,
  ) async {
    Future<bool> uploadFile(File file, String _id, int index) async {
      // File file = File(filePath);

      try {
        await FirebaseStorage.instance
            .ref('photos/${_id}_$index.${file.path.split(".").last}')
            .putFile((await compressImage('${_id}_$index', file))!);
      } on FirebaseException catch (e, stackTrace) {
        await FirebaseCrashlytics.instance.recordError(e, stackTrace,
            reason: 'Uploading images', fatal: true);
        // e.g, e.code == 'canceled'
        return false;
      }
      return true;
    }

    if (sendPhotos)
      for (int i = 0; i < photos.length; i++) {
        if (!(await uploadFile(photos[i], _id.toString(), i))) return false;
      }
    try {
      if (sendPhotos) {
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
      } else {
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
          'difficulty': difficulty,
          'elevation': elevation,
          'elevation_differences': elevDifferences,
          'trip_length': tripLength,
          'showable': true,
          'verified': isAdmin, //TODO: check
          // 'transportCost': transportCost,
        }, SetOptions(merge: true));
      }
    } on FirebaseException catch (e, stackTrace) {
      await FirebaseCrashlytics.instance
          .recordError(e, stackTrace, reason: 'Adding trip', fatal: true);
      return false;
    }
    return true;
  }

  static Future<bool> deleteMyAccount(String _userId) async {
    try {
      await _firestore.collection('/users').doc(_userId).set({
        'accountDeleted': true,
      }, SetOptions(merge: true));
      await _auth.currentUser!.delete();
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(e, stackTrace,
          reason: 'Deleting an account', fatal: true);
      return Future.error(e);
    }
    return true;
  }

  static Future<bool> incrementDiamonds(userId, int amount) async {
    try {
      await _firestore.collection('/users').doc(userId).set({
        'diamonds': FieldValue.increment(amount),
      }, SetOptions(merge: true));
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance
          .recordError(e, stackTrace, reason: 'Adding diamonds', fatal: false);
      return Future.error(e);
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
      'last_login': DateTime.now().toUtc(),
      'first_login': DateTime.now().toUtc(),
      'verified': false,
      'admin': false,
      'phoneNumber': phoneNumber,
      'hasBeenVerifiedByGoogleOrSomethingIdk': isVerified,
      'diamonds': 0,
    }, SetOptions(merge: false)).onError((error, stackTrace) async {
      await FirebaseCrashlytics.instance.recordError(e, stackTrace,
          reason: 'Adding user to database', fatal: true);
    });
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
    }).onError((error, stackTrace) async {
      await FirebaseCrashlytics.instance.recordError(e, stackTrace,
          reason: 'Updating user in database', fatal: true);
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
    _auth.signOut().onError((error, stackTrace) async {
      await FirebaseCrashlytics.instance
          .recordError(e, stackTrace, reason: 'On signing out', fatal: true);
    });
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
    } on Exception catch (e, stackTrace) {
      await FirebaseCrashlytics.instance
          .recordError(e, stackTrace, reason: 'Signing in', fatal: true);
      print(e);
    }
  }

  static Future<bool> signInWithPhoneNumber(
      String smsCode, verId, phoneNumber) async {
    final AuthCredential credential =
        PhoneAuthProvider.credential(verificationId: verId, smsCode: smsCode);
    // UserCredential _authResult = await _auth.signInWithCredential(credential).then((value) => null);

    // _auth.verifyPhoneNumber(phoneNumber: phoneNumber, verificationCompleted: verificationCompleted, verificationFailed: verificationFailed, codeSent: codeSent, codeAutoRetrievalTimeout: codeAutoRetrievalTimeout)
    // if (_authResult.additionalUserInfo!.isNewUser) {
    //   //TODO: handle
    // } else {
    //   Navigator.pushReplacement(
    //       context, MaterialPageRoute(builder: (_) => MyApp()));
    // }
    return true;
  }
}
