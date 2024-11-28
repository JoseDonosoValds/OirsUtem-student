import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  String? displayName;
  String? email;
  String? photoUrl;
  String? idToken;
  String? accessToken;

  void updateUser(
      String? newDisplayName, String? newEmail, String? newPhotoUrl, String? newIdToken, String? newAccessToken) {
    displayName = newDisplayName;
    email = newEmail;
    photoUrl = newPhotoUrl;
    idToken = newIdToken;
    accessToken = newAccessToken;
    notifyListeners();
  }
}
