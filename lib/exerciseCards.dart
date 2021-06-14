import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:better_player/better_player.dart';
import 'package:date_format/date_format.dart';
import 'package:day_selector/day_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_realtime_detection/enums/cardType.dart';
import 'package:flutter_realtime_detection/models/exerciseModel.dart';
import 'package:flutter_realtime_detection/models/workout.dart';
import 'package:flutter_realtime_detection/workoutPlan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:weekday_selector/weekday_selector.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'models/exerciseDetails.dart';
import 'models/user.dart';
import 'models/userExercise.dart';


class ExerciseCard extends StatefulWidget{
  final User visitedUser;
  final Workout visitedWorkout;
  final CardType cardType;
  final Exercise exercise;
  final VoidCallback closeContainer;

  ExerciseCard(this.cardType,this.exercise,this.closeContainer,this.visitedUser,this.visitedWorkout);
  @override
  State<StatefulWidget> createState() => new ExerciseCardState();

}

class ExerciseCardState extends State<ExerciseCard>
{
  BetterPlayerController _betterPlayerController;

  bool isCalendarActive = false;

  int repeatCount;
  int setCount;

  DateTime selectedDay;
  DateTime selectedStartingDay;

  List<Widget> calendarStates = [];

  List<bool> values = List.filled(7, false);
  

  @override
    void initState(){
      super.initState();
      configureVideo();
      calendarStates.add(setDays());
      repeatCount = 5;
      setCount = 1;
      selectedStartingDay = DateTime.now();
    }

    void configureVideo()
    {
      //"https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
      String lowerName = widget.exercise.name.toLowerCase();
      lowerName = lowerName.replaceAll(' ', '');
      BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      );
      BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.NETWORK,
        widget.exercise.videoUrl,
        cacheConfiguration: BetterPlayerCacheConfiguration(useCache: true),
      );
      _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
      _betterPlayerController.setupDataSource(dataSource);
    }

  @override
  Widget build(BuildContext context) 
  {
    
    return
    SafeArea(child: AnimatedSwitcher(
      duration: Duration(seconds: 1),
      child: isCalendarActive ?  addToPlan() : card()
      )
    );
  }
  Widget card(){
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = deviceSize.width * 0.75;
    return Container(
          height: deviceSize.height * 0.9,
          width: deviceSize.width * 0.9,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.0)), color: Colors.white, boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
          ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,                  
                  children: <Widget>[
                    Expanded(child: 
                      SizedBox(
                        width: 20,
                      ),
                    ),

                    Text(
                      widget.exercise.name,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      widget.exercise.difficulty,
                      style: const TextStyle(fontSize: 17, color: Colors.grey),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  SizedBox(
                    width: cardWidth,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: 
                        BetterPlayer(controller: _betterPlayerController)
                    ),
                  ),
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(child: 
                      SizedBox(
                        width: 20,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>
                      [
                      SizedBox(
                        width: cardWidth/2-5,
                        child:  RaisedButton(
                          onPressed: () {widget.closeContainer();},
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.black)
                          ),
                          child: Text("Back", style : TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),
                      
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: cardWidth/2-5,
                        child:  RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.black)
                          ),
                          onPressed: () {
                            setState(() {
                              isCalendarActive = true;
                            });
                          },
                          color: Colors.black,
                          
                          child: Text("Add To Schedule",textAlign: TextAlign.center, style : TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),
                    ]
                    )
                  ]
                ),
                
                /*Image.asset(
                  "assets/exerciseImages/${post["image"]}",
                  height: double.infinity,
                )*/

              ],
            ),
          )
        );
  }
  Widget repCountButton(){
    return Column
          (
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children :<Widget>[
              Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FloatingActionButton(
                    mini: true,
                    onPressed: () {setState(() {
                        if(repeatCount > 1)
                          repeatCount--;
                      });},
                    child: new Icon(
                    Icons.remove,
                      color: Colors.black),
                    backgroundColor: Colors.white,
                  ),
                
                  SizedBox(width:10),
                  Text('$repeatCount',
                      style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold)
                      ),
                  SizedBox(width:10),
                  FloatingActionButton(
                  mini: true,
                  onPressed: () {setState(() {
                    repeatCount++;
                  });},
                  child: Icon(Icons.add, color: Colors.black,),
                  backgroundColor: Colors.white,
                  ),
                ],
              ),
          
              Text(
                  repeatCount == 1 ? "Repeat" : "Repeats",
                  style: const TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
              ),    
            ],
          );
  }

  Widget setCountButton(){
    return Column
          (
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children :<Widget>[
              Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FloatingActionButton(
                    mini: true,
                    onPressed: () {setState(() {
                        if(setCount > 1)
                          setCount--;
                      });},
                    child: new Icon(
                    Icons.remove,
                      color: Colors.black),
                    backgroundColor: Colors.white,
                  ),
                
                  SizedBox(width:10),
                  Text('$setCount',
                      style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold)
                      ),
                  SizedBox(width:10),
                  FloatingActionButton(
                  mini: true,
                  onPressed: () {setState(() {
                    setCount++;
                  });},
                  child: Icon(Icons.add, color: Colors.black,),
                  backgroundColor: Colors.white,
                  ),
                ],
              ),
          
              Text(
                  setCount == 1 ? "Set" : "Sets",
                  style: const TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
              ),    
            ],
          );
  }

  Widget addToPlan()
  { 
    final deviceSize = MediaQuery.of(context).size;
      final cardWidth = deviceSize.width * 0.75;

    return Container(
      height: deviceSize.height * 0.9,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.0)), color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
      ]),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              
              children:
              <Widget>[
                Expanded(child: 
                  SizedBox(
                    width: 20,
                  ),
                ),

                calendarStates.last,
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    
                      repCountButton(),
                      setCountButton()
                    ],      
                  ) ,
            
                Expanded(
                  child:SizedBox(
                    width: 20,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>
                  [
                  SizedBox(
                    width: cardWidth/2-5,
                    child:  RaisedButton(
                      onPressed: () {setState(() {
                          configureVideo();
                          if(calendarStates.length>1){
                            calendarStates.removeLast();
                          }
                          else
                          {
                            isCalendarActive = false;
                          }
                        });},
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.black)
                      ),
                      child: Text("Back", style : TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                  
                  SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: cardWidth/2-5,
                    child:  RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.black)
                      ),
                      onPressed: () {
                        setState(() {
                              addToThePlan();
                              
                              widget.closeContainer();
                        });
                        
                      },
                      color: Colors.black,
                      
                      child: Text("Add To Plan" , style : TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                ]
                )
              ]
            )
          )
          ]
          )
        )
      );  
  }
  void addToThePlan()
  async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

    //Exercise exerciseModel = Exercise(widget.exercise.exercise.id,widget.exercise.exercise.name,widget.exercise.exercise.difficulty,widget.exercise.exercise.);

    List<int> days = [];
    for(int i = 0; i < values.length; i++){
      if(values[i]){
        var map = { "id" : (i-1)%7};
        days.add((i-1)%7);
      }
    }
    ExerciseDetails exerciseDetails = ExerciseDetails(widget.exercise,repeatCount,setCount,days);

    var headers = {
              'Content-type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
              'authorization' : prefs.getString("token")
            };
    var request = http.post(Constants.webPath + "workouts/" + widget.visitedWorkout.id+ ":addExerciseSet",
    headers: headers,
    body: jsonEncode(exerciseDetails.toJson()));

  }



  Widget setDays(){
    return Column(
      children: <Widget>[
                Text(
                      "Select The Repeating Days",
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                SizedBox(
                  height: 20,
                ),
                WeekdaySelector(
                  values: values,
                  onChanged: (int day) {
                    setState(() {
                      int index = day % 7;
          
                      values[index] = !values[index];
                    });
                  },
                ),
                //WorkoutPlanPage(false,CalendarFormat.month,selectDay),
      ]
    );
  }

  void selectDay(DateTime day)
  {
    selectedDay = day;
  }
  void selectStartingDay(DateTime day)
  {
    selectedStartingDay = day;
    selectedDay = selectedStartingDay;
  }

  

}
