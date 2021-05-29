
import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:flutter_realtime_detection/enums/ExerciseHistoryType.dart';

import 'exercisedetails.dart';


class Exercise
{
  DateTime creationDate;
  final String id;
  final String name;
  final String difficulty;
  final double p;

  Exercise(this.id,this.name,this.difficulty,this.p);

  Exercise.fromJson(Map<String, dynamic> json)
    : creationDate = HttpDate.parse(json['creationDate']),
      id = json['_id'],
      name = json['name'],
      difficulty = json['difficulty'],
      p = json['p'];

  Map<String, dynamic> toJson() => 
  {
    '_id' : id,
    'name' : name,
    'difficulty' : difficulty,
    'p' : p
  };

}







