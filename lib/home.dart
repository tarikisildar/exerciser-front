

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_realtime_detection/exercises.dart';
import 'package:flutter_realtime_detection/history.dart';
import 'package:flutter_realtime_detection/historyPage.dart';
import 'package:flutter_realtime_detection/workoutPlan.dart';
import 'package:table_calendar/table_calendar.dart';


class HomePage extends StatefulWidget 
{

  HomePage();

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> 
{
  bool isSideBarActive = false;
  double screenHeight;
  double screenWidth;
  String currentPageName = "My Workout Plan";
  Widget currentPage = WorkoutPlanPage(true,CalendarFormat.week,(){},DateTime.now());


  final Duration duration = const Duration(milliseconds: 100);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;
    return Scaffold(
      backgroundColor : Colors.white,
      body: Stack(
        children: <Widget>[
          sideBarMenu(context),
          dashboard(context),
        ],
      ),
    );
    
  }
  Widget dashboard(context){
    
    return AnimatedPositioned(
      duration: duration,
      top: 0,
      bottom: 0,
      left: isSideBarActive ? 0.15 * screenWidth : 0,
      right: isSideBarActive ? -0.15 *screenWidth : 0,
      child: SafeArea(
        child : 
          Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            
            title: new Text(currentPageName, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.black,),
                onPressed: () {setState(() {
                  isSideBarActive = !isSideBarActive;
                }); }
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
        body: currentPage
        )
      )
    );
  }

  Widget sideBarMenu(context)
    {
      return SafeArea(
        child:
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16),
            child:Align(
              alignment: Alignment.topLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.person_outlined, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          currentPageName = "My Profile";
                          isSideBarActive = false;
                        });
                        
                      }
                    ),
                    SizedBox(height:10),
                    IconButton(
                      icon: Icon(Icons.calendar_today_outlined, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          currentPageName = "My Workout Plan";
                          isSideBarActive = false;
                          currentPage = WorkoutPlanPage(true,CalendarFormat.week,(){},DateTime.now());
                        });
                      }
                    ),
                    SizedBox(height:10),
                    IconButton(
                      icon: Icon(Icons.history_outlined, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          currentPageName = "My Workout History";
                          isSideBarActive = false;
                          currentPage = HistoryPage(true,CalendarFormat.week,(){},DateTime.utc(2020));
                        });
                        
                      }
                    ),
                    SizedBox(height:10),
                    
                    IconButton(
                      icon: Icon(Icons.fitness_center_outlined, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          currentPageName = "Explore";
                          isSideBarActive = false;
                          currentPage = ExercisesPage();
                        });
                        
                      }
                    ),
                  ]
                )
            )
          )
      );
    }
}

