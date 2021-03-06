import 'package:flutter/material.dart';

final Color backgroundColor = Color(0xFF4A4A58);

class MenuDashboardPage extends StatelessWidget 
{
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor : backgroundColor,
        body: Stack(
          children: <Widget>[
            sideBarMenu(context),
          ],
        ),

      );
  }
  

}

Widget sideBarMenu(context)
{
  return Padding(
    padding: const EdgeInsets.only(left: 16.0),
    child:Align(
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Profile",
              style: TextStyle(color : Colors.white, fontSize: 22),
            ),
            Text(
              "Workout Plan",
              style: TextStyle(color : Colors.white, fontSize: 22),
            ),
            Text(
              "History",
              style: TextStyle(color : Colors.white, fontSize: 22),
            ),
            Text(
              "Explore",
              style: TextStyle(color : Colors.white, fontSize: 22),
            ),
          ]
        )
    )
  );
}