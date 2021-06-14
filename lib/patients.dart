

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_realtime_detection/enums/userRole.dart';
import 'package:flutter_realtime_detection/userWorkoutPlans.dart';
import 'package:flutter_realtime_detection/workoutDashboard.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'home.dart';
import 'models/user.dart';

class PatientsPage extends StatefulWidget

{

  PatientsPage();

  @override
  State<StatefulWidget> createState() => new PatientsState();
}

class PatientsState extends State<PatientsPage>
{
  List<User> patients = [];
  List<Widget> patientsData = [];
  ScrollController controller = ScrollController();

 @override
  void initState(){
      super.initState(); 
      getPatientData();
      
  }

  Future<http.Response> getPatients() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return http.get(Constants.webPath + "exercises",
    headers: {
              'Content-type': 'application/json',
              'Accept': 'application/json',
              'authorization' : prefs.getString("token")
            });
  }

  void getPatientData() async
  {
    //var response = await getPatients();
    
    //var patientsDataRaw = jsonDecode(response.body)["data"] as List;
    
    User user1 = User("60c601f2388c23614c780869","test@user.com",[UserRole.Patient]);
    User user2 = User("606892f2a66a3b2a24ab6ced", "Fatih@bisey.com",[UserRole.Patient]);
    User user3 = User("606892f2a66a3b2a24ab6ced", "Tarik@bisey.com",[UserRole.Patient]);
    var patientsDataRaw = [user1,user2,user3];
    patientsDataRaw.forEach((element) {
      //var exer  = User.fromJson(element);
      patients.add(element);
     });



    List<Widget> listItems = [];
    patients.forEach((post) {
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
                            post.userName.split("@")[0],
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                    ],
                  ),
                ),
                /*Image.asset(
                  "assets/exerciseImages/${post["image"]}",
                  height: double.infinity,
                )*/
                Icon(Icons.person, size: 120)
              ],
            ),
          )));
    });
    setState(() {
      patientsData = listItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height*0.30;
    return Container(
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
                controller: controller,
                  itemCount: patientsData.length,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    double scale = 1.0;
                      return GestureDetector(
                      onTap : () {  
                        setState(() {
                          Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => WorkoutDashBoard(patients[index])
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
                                child: patientsData[index]),
                            ),
                          ),
                    );
                    
                    }
                    ),

                ),
        ],
      ),
    );
  }
  
}