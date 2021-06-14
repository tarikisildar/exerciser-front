
import 'package:flutter_realtime_detection/models/user.dart';

class Doctor extends User
{
  List<User> patients;
  Doctor(userId, userName,roles,this.patients) : super(userId, userName,roles);

}