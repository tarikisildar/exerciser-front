import 'package:flutter_realtime_detection/models/exerciseDetails.dart';

import 'history.dart';

class ClientExercise
{
  final ExerciseDetails exerciseDetails;
  final History history;
  final DateTime date;
  
  ClientExercise(this.exerciseDetails,this.date,{this.history});
}