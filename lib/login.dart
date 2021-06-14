import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_realtime_detection/constants.dart';
import 'package:flutter_realtime_detection/doctorDashboard.dart';
import 'package:flutter_realtime_detection/enums/userRole.dart';
import 'package:flutter_realtime_detection/models/registerData.dart';
import 'package:flutter_realtime_detection/workoutDashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toggle_switch/toggle_switch.dart';

import 'models/user.dart';



class LoginScreen extends StatelessWidget {
  Duration get loginTime => Duration(milliseconds: 2250);
  UserRole role = UserRole.Patient;
  User user;

  Future<String> _authUser(LoginData data) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String,dynamic> body = data.toJson();   
    var response = await http.post(Constants.webPath + "users/token"
                ,headers: {
              'Content-type': 'application/x-www-form-urlencoded',
              'Accept': 'application/json'
            },
            body: body);

    try
    {
      prefs.setString("token", "Bearer " + jsonDecode(response.body)["access_token"]);
    }
    catch(e)
    {
      return "Bad Login";
    }

    var userResponse = await http.get(Constants.webPath + "users/users/me"
                ,headers: {
              'Content-type': 'application/json',
              'Accept': 'application/json',
              'Authorization' : prefs.getString("token")
            });
            
    
    user = User.fromJson(jsonDecode(userResponse.body));
    prefs.setString("userId",user.userId);
    prefs.setInt("role", user.roles[0].index);
  }

  postData(Map<String, dynamic> body,String url)async{    
    var dio = Dio();
    try {
          FormData formData = new FormData.fromMap(body);
          var response = await dio.post(url, data: formData);
          return response.data;
        } catch (e) {
          print(e);
        }
  }

   Future<String> _register(LoginData data) async
   {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();

    RegisterData registerData = RegisterData(loginData: data,roles: [userRoleParser[role]]);

    var response = await http.post(Constants.webPath + "users"
                ,headers: {
              'Content-type': 'application/json',
              'Accept': 'application/json'
            },
            body: jsonEncode(registerData));
    var auth = await _authUser(data);

    return auth;

   }

  Future<String> _recoverPassword(String name) {
    print('Name: $name');
    return Future.delayed(loginTime).then((_) 
    {
      return null;
    });
  }

  Widget toggle(Size size){

    return ToggleSwitch(
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
              );

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

              child: toggle(size)
            ),
            
            onLogin: _authUser,
            onSignup: _register,
            onSubmitAnimationCompleted: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => role == UserRole.Patient? WorkoutDashBoard(user) : DoctorPage(),
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