
import 'package:flutter_realtime_detection/models/user.dart';

class Doctor extends User
{
  List<User> patients;
  Doctor(userId, userName,this.patients) : super(userId, userName);

}