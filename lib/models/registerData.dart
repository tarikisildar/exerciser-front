import 'package:flutter/foundation.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_realtime_detection/enums/userRole.dart';

class RegisterData {
  final LoginData loginData;
  final List roles;

  RegisterData({
    @required this.loginData,
    @required this.roles,
  });

  Map<String, dynamic> toJson() => 
  {
    'username' : loginData.name,
    'password' : loginData.password,
    'roles' : roles
  };


  bool operator ==(Object other) {
    if (other is LoginData) {
      return loginData.name == other.name && loginData.password == other.password;
    }
    return false;
  }
}

