import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_realtime_detection/enums/workoutStatus.dart';
import 'package:flutter_realtime_detection/workoutCard.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_realtime_detection/models/workout.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'home.dart';
import 'models/user.dart';

class UserWorkoutPlans extends StatefulWidget
{
  final User visitedUser;
  UserWorkoutPlans(this.visitedUser);

  @override
  State<StatefulWidget> createState() => new UserWorkoutPlanState();
}

class UserWorkoutPlanState extends State<UserWorkoutPlans>
{
  List<Workout> workouts = [];
  List<Widget> workoutsData = [];
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    getWorkoutData();
  }



  Future<http.Response> getWorkouts() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var userResp = await http.get(Constants.webPath + "users/users/me"
                ,headers: {
              'Content-type': 'application/json',
              'Accept': 'application/json',
              'Authorization' : prefs.getString("token")
            });
    User user = User.fromJson(jsonDecode(userResp.body));
    if(user.userId == widget.visitedUser.userId)
    {
      return http.get(Constants.webPath + "workouts?assigneeId=${widget.visitedUser.userId}",
      headers: {
                'Content-type': 'application/json',
                'Accept': 'application/json',
                'authorization' : prefs.getString("token")
              });
    }

    return http.get(Constants.webPath + "workouts?assigneeId=${widget.visitedUser.userId}&assignerId=${user.userId}",
      headers: {
                'Content-type': 'application/json',
                'Accept': 'application/json',
                'authorization' : prefs.getString("token")
              },
              );

    
  }



  void getWorkoutData() async
  {
    var response = await getWorkouts();
    
    //var patientsDataRaw = jsonDecode(response.body)["data"] as List;
    
    //Workout workout = Workout("wegkaut","606a0108a66a3b2a24ab6d1c","606892f2a66a3b2a24ab6ced",DateTime.now().subtract(Duration(days: 4)),DateTime.now().add(Duration(days: 3)),WorkoutState.active);
    //Workout workout1 = Workout("wegkaut1","606a0108a66a3b2a24ab6d1c","606892f2a66a3b2a24ab6ced",DateTime.now().subtract(Duration(days: 5)),DateTime.now().add(Duration(days: 5)),WorkoutState.active);
    //workout.id  = "asd";
    var workoutDataRaw = jsonDecode(response.body) as List;
    workouts.clear();
    workoutDataRaw.forEach((element) {
      var workout  = Workout.fromJson(element);
      workouts.add(workout);
     });



    List<Widget> listItems = [];
    workouts.forEach((post) {
      listItems.add(
        Container(
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
                Expanded(
                  child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[    
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          post.workoutName,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          post.state == WorkoutState.Active ? post.endingDate.difference(DateTime.now()).inDays.toString() + " Days Left" : "Completed",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
                Icon(Icons.fitness_center_outlined, size: 120)
              ],
            ),
          )));
    });
    setState(() {
      workoutsData = listItems;
    });
  }

  Widget floatingButton(){
    return OpenContainer(closedBuilder: (_, openContainer)
    {
      return FloatingActionButton(onPressed: openContainer,
      child: const Icon(Icons.add));
    }, 
    openBuilder: (_, closeContainer)
    {
      close(){
        closeContainer();
        setState(() {
          getWorkoutData();
        });
      }
      return WorkoutCard(widget.visitedUser, close);
    });
  }
  

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: floatingButton(),
      body: Container(
        height: size.height,
        child: Column(
          children: <Widget>[
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: 0,
              child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: size.width,
                  alignment: Alignment.topCenter,
                  height: 0,
                  ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
                child: ListView.builder(
                  shrinkWrap: true,

                  controller: controller,
                    itemCount: workoutsData.length,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      double scale = 1.0;
                        return GestureDetector(
                        onTap : () {  
                          setState(() {
                            Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => HomePage(widget.visitedUser,workouts[index])
                                ));
                          });
                          },
                          child: Opacity(
                            opacity: scale,
                            child:
                        
                            Transform(
                              transform:  Matrix4.identity()..scale(scale,scale),
                              alignment: Alignment.bottomCenter,
                              child: Align(
                                  heightFactor: 1,
                                  alignment: Alignment.topCenter,
                                  child: workoutsData[index]),
                              ),
                            ),
                      );
                      
                      }
                      ),

                  ),
          ],
        ),
        
      ),
    );
      
  }
}