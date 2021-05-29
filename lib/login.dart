import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_realtime_detection/constants.dart';
import 'package:flutter_realtime_detection/doctorDashboard.dart';
import 'package:flutter_realtime_detection/enums/userRole.dart';
import 'package:flutter_realtime_detection/home.dart';
import 'package:flutter_realtime_detection/patients.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toggle_switch/toggle_switch.dart';

import 'models/exerciseModel.dart';
import 'models/user.dart';



class LoginScreen extends StatelessWidget {
  Duration get loginTime => Duration(milliseconds: 2250);
  UserRole role = UserRole.user;
  User user;

  Future<String> _authUser(LoginData data) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = await http.post(Constants.webPath + "/users/login"
                ,headers: {
              'Content-type': 'application/json',
              'Accept': 'application/json'
            },
            body: jsonEncode(data.toJson()));


    try
    {
      prefs.setString("token", "Bearer " + jsonDecode(response.body)["access_token"]);
    }
    catch(e)
    {
      return "Bad Login";
    }

    var userResponse = await http.get(Constants.webPath + "/users"
                ,headers: {
              'Content-type': 'application/json',
              'Accept': 'application/json',
              'Authorization' : prefs.getString("token")
            });
            
    prefs.setString("userId",jsonDecode(userResponse.body)["logged_in_as"]["_id"]);
    prefs.setInt("role", role.index);
    user = new User(prefs.getString("userId"),"");
  }

   Future<String> _register(LoginData data) async
   {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    var response = await http.post(Constants.webPath + "/users/register"
                ,headers: {
              'Content-type': 'application/json',
              'Accept': 'application/json'
            },
            body: jsonEncode(data.toJson()));
    print(response.body);
    _authUser(data);

   }

  Future<String> _recoverPassword(String name) {
    print('Name: $name');
    return Future.delayed(loginTime).then((_) 
    {
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
        height: size.height,
        child: 
        Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
          child: 
          FlutterLogin(
            title: 'EXERCISER',
            //logo: 'assets/logo.png',
            theme: LoginTheme(
              
              primaryColor: Colors.white,
              accentColor: Colors.black,
              
              titleStyle: TextStyle(
                color: Colors.black,
                fontFamily: 'Quicksand',
                letterSpacing: 4,
              ),
              bodyStyle: TextStyle(
                fontStyle: FontStyle.italic,
                decoration: TextDecoration.underline,
              ),
              textFieldStyle: TextStyle(color: Colors.black),
              buttonStyle: TextStyle(color: Colors.black),
              buttonTheme: LoginButtonTheme(
                splashColor: Colors.white,
                backgroundColor: Colors.white,
                highlightColor: Colors.teal
              ),
            ),
            userRoleWidget: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.0)), color: Colors.white, boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),  ]),

              child: ToggleSwitch(
                minWidth: size.width/3,
                initialLabelIndex: 0,
                cornerRadius: 20.0,
                activeFgColor: Colors.white,
                inactiveBgColor: Colors.white,
                inactiveFgColor: Colors.black,
                labels: ['User', 'Doctor'],
                icons: [Icons.person, Icons.badge],
                activeBgColor: Colors.black,
                onToggle: (index) {
                  role = UserRole.values[index];
                },
              ),
            ),
            
            onLogin: _authUser,
            onSignup: _register,
            onSubmitAnimationCompleted: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => role == UserRole.user? HomePage(user) : DoctorPage(),
              ));
            },
            onRecoverPassword: _recoverPassword,
            ),
          ),
          

           
        ]
      )
     
    );
  }
}