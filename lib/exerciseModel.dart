
import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:flutter_realtime_detection/enums/ExerciseHistoryType.dart';

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
class UserExercise
{
  String id;
  DateTime creationDate;
  final DateTime startDate;
  final DateTime endDate;
  final String userId;
  final String asignerId;
  final ExerciseDetails exerciseDetails;
  List<History> history;
  final List recurrentDays;

  UserExercise(this.startDate, this.endDate, this.asignerId,this.userId, this.exerciseDetails, this.recurrentDays);

  UserExercise.fromJson(Map<String, dynamic> json)
    : creationDate = HttpDate.parse(json['creationDate']),
      id = json['_id'],
      startDate = HttpDate.parse(json['startDate']),
      endDate = HttpDate.parse(json['endDate']),
      userId = json['userId'],
      asignerId = json['asignerId'],
      exerciseDetails = ExerciseDetails.fromJson(json['exerciseDetails']),
      history = json['history'] != null ? json['history'].map<History>((e) => History.fromJson(e)).toList() : null,
      recurrentDays = json['recurrentDays'];

  Map<String, dynamic> toJson() => 
  {
    'startDate' : formatDate(startDate,[yyyy, '-', mm, '-', d, ' ', HH, ':', nn, ':', ss]),
    'endDate' : formatDate(endDate,[yyyy, '-',mm, '-', d, ' ', HH, ':', nn, ':', ss]),
    'userId' : userId,
    'asignerId' : asignerId,
    'repeat' : exerciseDetails.repeat,
    'setCount' : exerciseDetails.setCount,
    'exerciseId' : exerciseDetails.exercise.id,
    'recurrentDays' : recurrentDays
  };
}
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

class ClientExercise
{
  final String name;
  final String difficulty;
  final int repCount;
  final int setCount;
  final History history;
  final DateTime date;
  
  ClientExercise(this.name,this.difficulty,this.repCount,this.setCount,this.date,{this.history});
}

class User
{
  String userId;
  String userName;
  User(this.userId,this.userName);

  User.fromJson(Map<String, dynamic> json) : 
    userId = json["_id"],
    userName = json["username"];
  Map<String, dynamic> toJson() => {
    '_id' : userId,
    'userName' : userName
  };
  
}
class Doctor extends User
{
  List<User> patients;
  Doctor(userId, userName,this.patients) : super(userId, userName);

}

