import 'dart:io';
import 'exerciseModel.dart';

class ExerciseDetails
{
  DateTime creationDate;
  String id;
  final Exercise exercise;
  final int repeat;
  final int setCount;

  ExerciseDetails(this.exercise,this.repeat,this.setCount);

  ExerciseDetails.fromJson(Map<String, dynamic> json)
    : creationDate = HttpDate.parse(json['creationDate']),
      id = json['_id'],
      exercise = Exercise.fromJson(json['exercise']),
      repeat = json['repeat'],
      setCount = json['setCount'];

  Map<String, dynamic> toJson() => 
  {
    'exercise' : exercise,
    'repeat' : repeat,
    'setCount' : setCount
  };
}