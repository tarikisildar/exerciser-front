import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_realtime_detection/constants.dart';
import 'package:flutter_realtime_detection/exercises.dart';
import 'package:flutter_realtime_detection/makeExercise.dart';
import 'package:flutter_realtime_detection/savePoints.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:speech_recognition/speech_recognition.dart';


import 'draw.dart';

import 'camera.dart';
import 'bndbox.dart';
import 'models.dart';

class HomePage extends StatefulWidget 
{
  final List<CameraDescription> cameras;

  HomePage(this.cameras);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> 
{
  List<dynamic> _recognitions;


  ScrollController controller = ScrollController();
  List<Widget> exercisesData = [];
  List<dynamic> exercisesDataRaw;



  

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child : 
        Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: Icon(
            Icons.menu,
            color: Colors.black,
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.black),
              onPressed: () {},
            )
          ],
        ),
      body: ExercisesPage(widget.cameras)
      )
    );
  }
}
