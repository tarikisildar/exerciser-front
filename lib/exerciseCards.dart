import 'dart:math';

import 'package:better_player/better_player.dart';
import 'package:day_selector/day_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_realtime_detection/enums/cardType.dart';
import 'package:flutter_realtime_detection/workoutPlan.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:weekday_selector/weekday_selector.dart';

class ExerciseCard extends StatefulWidget{
  final CardType cardType;
  final dynamic exercise;
  final VoidCallback closeContainer;

  ExerciseCard(this.cardType,this.exercise,this.closeContainer);
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
      calendarStates.add(setStartingDateState());
      repeatCount = int.parse(widget.exercise["repeat"]);
      setCount = 1;
    }

    void configureVideo()
    {
      BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      );
      BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.NETWORK,
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
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
    final cardWidth = min(deviceSize.width * 0.75, 360.0);
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
                      widget.exercise["name"],
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      widget.exercise["difficulty"],
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
                        width: 160,
                        child:  RaisedButton(
                          onPressed: () {widget.closeContainer();},
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.black)
                          ),
                          child: Text("Back", style : TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),
                      
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 160,
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
                          
                          child: Text("Add To Schedule", style : TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)
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
                calendarStates.length > 2 ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    
                      repCountButton(),
                      setCountButton()
                    ],      
                  ) : SizedBox(width:1),
            
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
                    width: 160,
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
                      child: Text("Back", style : TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                  
                  SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 160,
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
                              calendarStates.add(setDays());
                              break;
                            case 3:
                              widget.closeContainer();
                              break;
                          }
                        });
                        
                      },
                      color: Colors.black,
                      
                      child: Text(calendarStates.length < 3 ? "Next" : "Add To Plan" , style : TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)
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
                WorkoutPlanPage(false,CalendarFormat.month,selectStartingDay,DateTime.now()),
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
                WorkoutPlanPage(false,CalendarFormat.month,selectDay,selectedStartingDay),
      ]
    );
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
                      final index = day % 7;
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
  }

  

}
