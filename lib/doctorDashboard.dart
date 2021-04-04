import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_realtime_detection/patients.dart';

class DoctorPage extends StatefulWidget{

  DoctorPage();

  @override
  State<StatefulWidget> createState() => new DoctorPageState(); 

}

class DoctorPageState extends State<DoctorPage>{
  bool isSideBarActive = false;
  double screenHeight;
  double screenWidth;
  String currentPageName = "My Patients";
  Widget currentPage = PatientsPage();
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
                          currentPageName = "My Patients";
                          isSideBarActive = false;
                          currentPage = PatientsPage();
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