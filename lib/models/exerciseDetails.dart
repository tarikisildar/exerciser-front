import 'dart:io';
import 'package:flutter_realtime_detection/models/history.dart';

import 'exerciseModel.dart';

class ExerciseDetails
{
  String id;
  final Exercise exercise;
  final int repeat;
  final int setCount;
  List<History> history;
  final List recurrentDays;



  ExerciseDetails(this.exercise,this.repeat,this.setCount,this.recurrentDays);

  ExerciseDetails.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      exercise = Exercise.fromJson(json['exercise']),
      repeat = json['repetitionCount'],
      setCount = json['setCount'],
      recurrentDays = json['recurrentDays'],
      history = json['history'] != null ? json['history'].map<History>((e) => History.fromJson(e)).toList() : null;

  Map<String, dynamic> toJson() => 
  {
    'exerciseId' : exercise.id,
    'repetitionCount' : repeat,
    'setCount' : setCount,
    'recurrentDays' : recurrentDays,
  };
}