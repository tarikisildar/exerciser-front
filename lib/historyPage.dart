import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_realtime_detection/enums/ExerciseHistoryType.dart';
import 'package:flutter_realtime_detection/models/exerciseDetails.dart';
import 'package:flutter_realtime_detection/models/workout.dart';
import 'package:flutter_realtime_detection/workoutPlan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'models/filteredExercise.dart';
import 'models/history.dart';
import 'models/user.dart';
import 'models/userExercise.dart';


class HistoryPage extends WorkoutPlanPage
{
  HistoryPage(bool isEventListActive, CalendarFormat calendarFormat, Function selectDay, DateTime startDay,User visitedUser,Workout visitedWorkout) : 
  super(isEventListActive, calendarFormat, selectDay, startDay, visitedUser,visitedWorkout);
  @override
  State<StatefulWidget> createState() => new HistoryState();
  
}

class HistoryState extends WorkoutPlanState
{
  
  @override
  Future<http.Response> getExercises()
  async 
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var headers = {
              'Content-type': 'application/json',
              'Accept': 'application/json',
              'authorization' : prefs.getString("token")
            };
    var url = Constants.webPath + "workouts/" + widget.visitedWorkout.id+ "/exerciseSets";
    //-by-date?startDate=$dateFirst&endDate=$dateLast
    return http.get(url, headers: headers);
  }

  @override
  List<History> findHistories(ExerciseDetails userExercise, DateTime first, DateTime last)
    {
      return super.findHistories(userExercise,first,last);
    }
  
  @override
  void getExerciseData(DateTime first, DateTime last) async
  {
    responseList.clear();
    var getData = (await getExercises()).body;
    var exercisesRaw = jsonDecode(getData) as List;

    userExercises.clear();
    for(int i = 0; i < exercisesRaw.length; i++)
    {
      userExercises.add(ExerciseDetails.fromJson(exercisesRaw[i]));
    } 
    for(int i = 0; i < userExercises.length; i++)
    {
      DateTime todayFirst = new DateTime(first.year, first.month, first.day);
      DateTime todayLast =  new DateTime(last.year, last.month, last.day,23,59,59);
      var histories = super.findHistories(userExercises[i], todayFirst, todayLast);
      for(int j = 0; j < histories.length; j++)
      {
        var exerciseDetails = userExercises[i];
        responseList.add(ClientExercise(exerciseDetails, histories[j].creationDate,history: histories[j]));
      }
    }

    List<Widget> listItems = [];
    responseList.forEach((post) {
      listItems.add(
        
        exerciseItem(post,false)
        
      );
    });
    setState(() {
      exercisesData = listItems;
      addCurrentWindowEvents();

    });
  }
  @override
  bool canStartTheProgram(){
    return false;
  }

  @override
  Widget exerciseItem(ClientExercise post,bool disabled)
  {
    return Container(
          height: 150,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.0)), color: Colors.white, boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
          ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                post.history.status == ExerciseHistoryType.UNCOMPLETED ? Icon ( Icons.remove, color: Colors.black) :
                post.history.status == ExerciseHistoryType.FAILED ? Icon(Icons.cancel, color: Colors.red) : 
                Icon ( Icons.check, color: Colors.green),
                Image.network(post.exerciseDetails.exercise.imageUrl,
                  errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace){
                    return Image.asset(
                    "assets/logo.png",
                    height: double.infinity
                    );
                },),
                Expanded(child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        post.exerciseDetails.exercise.name,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        formatDate(post.date.toLocal(),[d, '-', M, '-', yyyy, ' ', HH, ':', nn]),
                        style: const TextStyle(fontSize: 17, color: Colors.grey),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "${post.history.repeat} / ${post.exerciseDetails.repeat} Repeats",
                        style: const TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.fade
                      ),

                    ],
                  ),
                )
                
              ],
            ),
          ));
    }
}