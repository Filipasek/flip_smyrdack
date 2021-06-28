import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserData extends ChangeNotifier {
  //Logout
  String? currentUserId, currentUserPhoto, name, mail;
  int minimumVersion = 0, workingVersion = 0, currentVersion = 0, thisVersion = 0;
  bool? isAdmin, isVerified, isVerCodeSet, isPhoneVerified, showAds;
  Future<bool> logout() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    return true;
  }

  //Admin tools
  dynamic usersToBeVerified;
  List? usersList;

  //User Location
  // Position _userLocation;
  // Position get userLocation => _userLocation;

  // Stream<Position> get streamPosition => getPositionStream(distanceFilter: 10);

  // Future<void> getLocation() async {
  //   await getCurrentPosition().then((Position position) {
  //     _userLocation = position;
  //   });
  //   notifyListeners();
  // }
}
