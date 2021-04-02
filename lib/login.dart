import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_realtime_detection/constants.dart';
import 'package:flutter_realtime_detection/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;



class LoginScreen extends StatelessWidget {
  Duration get loginTime => Duration(milliseconds: 2250);

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

    var user = await http.get(Constants.webPath + "/users"
                ,headers: {
              'Content-type': 'application/json',
              'Accept': 'application/json',
              'Authorization' : prefs.getString("token")
            });
            
    prefs.setString("userId",jsonDecode(user.body)["logged_in_as"]["_id"]);
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
    return SafeArea(
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
      
      onLogin: _authUser,
      onSignup: _register,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => HomePage(),
        ));
      },
      onRecoverPassword: _recoverPassword,
      )
    );
  }
}