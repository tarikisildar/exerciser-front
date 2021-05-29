import 'history.dart';

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