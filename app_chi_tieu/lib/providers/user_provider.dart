import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _userId;

  String? get userId => _userId;

  void setUserId(String id) {
    _userId = id;
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    notifyListeners();
  }
}
