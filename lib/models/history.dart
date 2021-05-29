import 'dart:io';

import 'package:flutter_realtime_detection/enums/ExerciseHistoryType.dart';

class History
{
  String id;
  DateTime creationDate;
  int repeat;
  ExerciseHistoryType type;


  History(this.id, this.creationDate, this.repeat, this.type);

  History.fromJson(Map<String, dynamic> json)
    : id = json['_id'],
      creationDate = HttpDate.parse(json['creationDate']),
      repeat = json['userRepeat'],
      type = ExerciseHistoryType.values[json['type']];


  Map<String, dynamic> toJson() => {
    'id' : id,
    'creationDate' : creationDate,
    'userRepeat' : repeat
  };
}