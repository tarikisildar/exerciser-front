import 'package:flutter_realtime_detection/models/workout.dart';

enum WorkoutState{
  Active,Completed
}

const workoutStateParser = {
  WorkoutState.Active : "Active",
  WorkoutState.Completed : "Completed"
};

const workoutStateMap = {
  "Active" : WorkoutState.Active ,
  "Completed" : WorkoutState.Completed 
};