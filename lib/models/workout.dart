import 'dart:io';

import 'package:flutter_realtime_detection/enums/workoutStatus.dart';
import 'package:date_format/date_format.dart';

class Workout
{
  String id;
  String workoutName;
  String assignerId;
  String assigneeId;
  DateTime startingDate;
  DateTime endingDate;
  WorkoutState state;
  Workout(this.workoutName,this.assignerId,this.assigneeId,this.startingDate,this.endingDate);

  Workout.fromJson(Map<String, dynamic> json) : 
    id = json['id'],
    workoutName = json['name'],
    assignerId = json['assignerId'],
    assigneeId = json['assigneeId'],
    startingDate = DateTime.parse(json['startDate']),
    endingDate = DateTime.parse(json['endDate']),
    state = workoutStateMap[json['status']];

  Map<String, dynamic> toJson() => {
    'name' : workoutName,
    'assignerId' : assignerId,
    'assigneeId' : assigneeId,
    'startDate' : formatDate(startingDate,[yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]),
    'endDate' : formatDate(endingDate,[yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]),
  };
  
}