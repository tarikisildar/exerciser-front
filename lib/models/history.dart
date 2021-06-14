import 'dart:io';

import 'package:flutter_realtime_detection/enums/ExerciseHistoryType.dart';

class History
{
  String id;
  DateTime creationDate;
  int repeat;
  ExerciseHistoryType status;


  History(this.id, this.creationDate,this.status, this.repeat);

  History.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      creationDate = DateTime.parse(json['creationDate']),
      repeat = json['repetitionCount'],
      status = exerciseHistoryMap[json['status']];


  Map<String, dynamic> toJson() => {
    'id' : id,
    'creationDate' : creationDate,
    'repetitionCount' : repeat,
    'status' : exerciseHistoryParser[status]
  };
}