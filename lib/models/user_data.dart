import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserData extends ChangeNotifier {
  //Logout
  String? currentUserId;
  Future<void> logout() async {
    GoogleSignIn().signOut();
    FirebaseAuth.instance.signOut();
  }

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
