import 'package:anime_discovery/Entities/user_entity.dart';
import 'package:anime_discovery/Services/auth_service.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  UserEntity? _user;
  AuthService authService = AuthService.getAuthService();
  UserEntity? get user {
     if(_user==null){
       // authService.logout();
       return null;
     }
    return _user;
  }

  Future<void> setUser(UserEntity user) async {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}