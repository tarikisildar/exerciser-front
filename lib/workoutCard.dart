import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_realtime_detection/constants.dart';
import 'package:flutter_realtime_detection/enums/workoutStatus.dart';
import 'package:flutter_realtime_detection/models/workout.dart';
import 'package:flutter_realtime_detection/workoutPlan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

import 'models/user.dart';

class WorkoutCard extends StatefulWidget
{
    final User visitedUser;
    final VoidCallback closeContainer;

    WorkoutCard(this.visitedUser,this.closeContainer);

  get exercise => null;
    @override
    State<StatefulWidget> createState() => new WorkoutCardState();
}

class WorkoutCardState extends State<WorkoutCard>
{

  List<Widget> calendarStates = [];

  DateTime selectedDay;
  DateTime selectedStartingDay;

  bool isCalendarActive = false;
  String workoutName = "";

  TextEditingController textEditingController;

  @override
    void initState(){
      super.initState();
      calendarStates.add(setStartingDateState());
      selectedStartingDay = DateTime.now();
      textEditingController = TextEditingController();
    }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
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
                  mainAxisAlignment: MainAxisAlignment.center,                  
                  children: <Widget>[
                      SizedBox(
                        width: 20,
                      ),
                    Text(
                      "Create A New Workout",
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(width: cardWidth*2/3,
                      child: TextField(
                        controller: textEditingController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Workout Name',
                        
                          ),
                          onChanged: (text){workoutName = text;},
                        ),
                    ),
                    
                    SizedBox(
                        height: 30,
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
                          
                          child: Text("Select Dates",textAlign: TextAlign.center, style : TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),
                    ]
                    )
                  ]
                ),
              ],
            ),
          )
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
                          switch(calendarStates.length){
                            case 1:
                              calendarStates.add(setEndingDateState());
                              break;
                            case 2:
                              addTheWorkout();
                                widget.closeContainer();
                              break;
                          }
                        });
                        
                      },
                      color: Colors.black,
                      
                      child: Text(calendarStates.length < 2 ? "Next" : "OK" , style : TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)
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

    Widget setStartingDateState()
  {
    return Column(
      children: <Widget>[
                Text(
                      "Select The Starting Date",
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                SizedBox(
                  height: 20,
                ),
                WorkoutPlanPage(false,CalendarFormat.month,selectStartingDay,DateTime.now(),widget.visitedUser,null),
      ]
    );
  }

  Widget setEndingDateState()
  {
    return Column(
      children: <Widget>[
                Text(
                      "Select The Ending Date",
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                SizedBox(
                  height: 20,
                ),
                WorkoutPlanPage(false,CalendarFormat.month,selectDay,selectedStartingDay,widget.visitedUser,null),
      ]
    );
  }
  

  void addTheWorkout()
  async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userResp = await http.get(Constants.webPath + "users/users/me"
                ,headers: {
              'Content-type': 'application/json',
              'Accept': 'application/json',
              'Authorization' : prefs.getString("token")
            });
    User user = User.fromJson(jsonDecode(userResp.body));


    Workout workout = Workout(workoutName, user.userId, widget.visitedUser.userId, selectedStartingDay, selectedDay);
    var headers = {
              'Content-type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
              'authorization' : prefs.getString("token")
            };
    var request = http.post(Constants.webPath + "workouts",
    headers: headers,
    body: jsonEncode(workout.toJson()));

  }
  @override
  Widget build(BuildContext context) {
    return
    SafeArea(child: AnimatedSwitcher(
      duration: Duration(seconds: 1),
      child: isCalendarActive ?  addToPlan() : card()
      )
    );
  }
  void selectStartingDay(DateTime day)
  {
    selectedStartingDay = day;
    selectedDay = selectedStartingDay;
  }
  void selectDay(DateTime day)
  {
    selectedDay = day;
  }
}