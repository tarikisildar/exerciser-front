import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_realtime_detection/main.dart';
import 'package:flutter_realtime_detection/savePoints.dart';
import 'package:http/http.dart' as http;

import 'bndbox.dart';
import 'camera.dart';
import 'dart:math' as math;




class CameraPage extends StatefulWidget
{
  final dynamic currentExercise;

  final String model;

  CameraPage(this.currentExercise,this.model);

  @override
  _CameraPageState createState() => new _CameraPageState();

}

class _CameraPageState extends State<CameraPage>
{
  SavePoints savePoints;
  List<dynamic> _recognitions;
  bool isDebug = false;



  int _imageHeight = 0;
  int _imageWidth = 0;

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  bool checkRecording()
  {
    return savePoints.isRecording;
  }

  posenetOver(){
    savePoints.onRecord(context);
  }

  setSavePoints(SavePoints svPoints){
    savePoints = svPoints;
  }
  
  
  exitToMenu() => Navigator.pop(context);

  Future<http.Response> getDistance(String jsonName,List<List<Point>> resultsList)
  {


    var name = widget.currentExercise["points"].substring(0, widget.currentExercise["points"].length - 5);
    var repeat = widget.currentExercise["repeat"];
    print(repeat);
    return http.post("http://157.230.108.121:8080/similarity-single/$name?repeat=$repeat&p=0.3",
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(resultsList)
    );
  }


  Future<http.Response> getDistanceOfCurrent(List<List<Point>> resultsList)
  {
      return getDistance(widget.currentExercise["points"], resultsList);
  }
  @override
  void initState() 
  {
    setSavePoints(SavePoints(exitFunction: exitToMenu,finishExercise: getDistanceOfCurrent));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child:
      Scaffold(
          backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
              icon : Icon(
                Icons.arrow_back_ios_outlined,
                color: Colors.white,
              ),
              onPressed: () => {
                Navigator.pop(context)
              },
            ),
        ),
        body: 
          Stack(
              children: [
                Input(
                  widget.model,
                  checkRecording,
                  setRecognitions,
                  posenetOver
                ),
                savePoints,
                BndBox(
                    _recognitions == null ? [] : _recognitions,
                    math.max(_imageHeight, _imageWidth),
                    math.min(_imageHeight, _imageWidth),
                    size.height,
                    size.width,
                    widget.model,
                    savePoints),
                Container(
                  alignment: Alignment(0.0, 0.9),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Switch(
                    value: isDebug,
                    onChanged: (value){
                      setState(() {
                        isDebug=value;
                      });
                    },
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                ),
                  ],
                  ),
                ),
              ],
            ),
       )
      );
    }
}