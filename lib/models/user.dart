import 'package:flutter_realtime_detection/enums/userRole.dart';

class User
{
  String userId;
  String userName;
  List roles;
  User(this.userId,this.userName,this.roles);

  User.fromJson(Map<String, dynamic> json) : 
    userId = json["id"],
    userName = json["username"],
    roles = [userRoleMap[json["roles"][0]]];
  Map<String, dynamic> toJson() => {
    'id' : userId,
    'userName' : userName,
    'roles': [userRoleParser[roles[0]]] 
  };
  
}