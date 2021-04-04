import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_realtime_detection/enums/ExerciseHistoryType.dart';
import 'package:flutter_realtime_detection/workoutPlan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'exerciseModel.dart';


class HistoryPage extends WorkoutPlanPage
{
  HistoryPage(bool isEventListActive, CalendarFormat calendarFormat, Function selectDay, DateTime startDay,User visitedUser) : 
  super(isEventListActive, calendarFormat, selectDay, startDay, visitedUser);
  @override
  State<StatefulWidget> createState() => new HistoryState();
  
}

class HistoryState extends WorkoutPlanState
{
  
  @override
  Future<http.Response> getExercises(DateTime first, DateTime last)
  async 
  {
    String dateFirst = formatDate(first,[yyyy, '-', mm, '-', d, ' ', HH, ':', nn, ':', ss]);
    String dateLast = formatDate(last,[yyyy, '-', mm, '-', d, ' ', HH, ':', nn, ':', ss]);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var headers = {
              'Content-type': 'application/json',
              'Accept': 'application/json',
              'authorization' : prefs.getString("token")
            };
    var url = Constants.webPath + "users/" + widget.visitedUser.userId+ "/exercise-history-by-date?startDate=$dateFirst&endDate=$dateLast";
    print(url);
    //-by-date?startDate=$dateFirst&endDate=$dateLast
    return http.get(url, headers: headers);
  }

  @override
  List<History> findHistories(UserExercise userExercise, DateTime first, DateTime last)
    {
      return super.findHistories(userExercise,first,last);
    }
  
  @override
  void getExerciseData(DateTime first, DateTime last) async
  {
    responseList.clear();
    var getData = (await getExercises(first, last)).body;
    print(getData);
    var exercisesRaw = jsonDecode(getData)["data"] as List;
    userExercises.clear();
    for(int i = 0; i < exercisesRaw.length; i++)
    {
      userExercises.add(UserExercise.fromJson(exercisesRaw[i]));
    } 
    for(int i = 0; i < userExercises.length; i++)
    {
      var histories = super.findHistories(userExercises[i], first, last);
      for(int j = 0; j < histories.length; j++)
      {
        var curExercise = userExercises[i].exerciseDetails.exercise;
        var exerciseDetails = userExercises[i].exerciseDetails;
        responseList.add(ClientExercise(curExercise.name, curExercise.difficulty, exerciseDetails.repeat, exerciseDetails.setCount, histories[j].creationDate,history: histories[j]));
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
    });
    addCurrentWindowEvents();
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
                post.history.type == ExerciseHistoryType.uncompleted ? Icon ( Icons.remove, color: Colors.black) :
                (post.history.repeat - post.repCount).abs() > 0.25 * post.repCount ? Icon(Icons.cancel, color: Colors.red) : 
                Icon ( Icons.check, color: Colors.green),
                Image.asset(
                  "assets/logo.png",
                  height: double.infinity,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      post.name,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      formatDate(post.date,[d, '-', M, '-', yyyy, ' ', HH, ':', nn]),
                      style: const TextStyle(fontSize: 17, color: Colors.grey),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "${post.history.repeat} / ${post.repCount} Repeats",
                      style: const TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.bold),
                    ),

                  ],
                ),
                
              ],
            ),
          ));
    }
}