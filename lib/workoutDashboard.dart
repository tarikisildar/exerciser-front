import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_realtime_detection/userWorkoutPlans.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'login.dart';
import 'models/user.dart';

class WorkoutDashBoard extends StatefulWidget
{
  final User visitedUser;
  WorkoutDashBoard(this.visitedUser);

  @override
  State<StatefulWidget> createState() => new WorkoutDashboardState(); 
}

class WorkoutDashboardState extends State<WorkoutDashBoard>
{

  bool isSideBarActive = false;
  double screenHeight;
  double screenWidth;
  String currentPageName = "My Workouts";
  Widget currentPage;

  User user;
  String name;
  final Duration duration = const Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    currentPage = UserWorkoutPlans(widget.visitedUser);
    setUser();

  }


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
                          currentPageName = "$name Profile";
                          isSideBarActive = false;
                        });
                        
                      }
                    ),
                    SizedBox(height:10),
                    IconButton(
                      icon: Icon(Icons.calendar_today_outlined, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          currentPageName = "$name Workout Plan";
                          isSideBarActive = false;
                          currentPage = UserWorkoutPlans(widget.visitedUser);
                        });
                      }
                    ),
                    Spacer(),
                    IconButton(icon: Icon(Icons.subdirectory_arrow_left, color: Colors.black), 
                      onPressed: () {setState(() {
                        goBack();
                      });}
                    ),
                  ]
                )
            )
          )
      );
    }
    void goBack(){
      if(Navigator.of(context).canPop())
      {
        Navigator.of(context).pop();
      }
      else
      {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    }
    void setUser() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var response = await http.get("${Constants.webPath}users/users/me",
      headers: {
                'Content-type': 'application/json',
                'Accept': 'application/json',
                'authorization' : prefs.getString("token")
              });
      user = User.fromJson(jsonDecode(response.body));
      name = (widget.visitedUser.userName == user.userName || widget.visitedUser.userName == "")  ? "My" : widget.visitedUser.userName.split("@")[0] + "'s";
      currentPageName = "$name Workout Plan";
  }

}