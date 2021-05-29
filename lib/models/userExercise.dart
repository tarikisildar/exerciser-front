import 'dart:io';
import 'package:date_format/date_format.dart';

import 'exerciseModel.dart';
import 'exercisedetails.dart';
import 'history.dart';

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