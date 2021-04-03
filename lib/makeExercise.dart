import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_realtime_detection/constants.dart';
import 'package:flutter_realtime_detection/main.dart';
import 'package:flutter_realtime_detection/savePoints.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'bndbox.dart';
import 'camera.dart';
import 'dart:math' as math;

import 'customDialogBox.dart';
import 'exerciseModel.dart';




class CameraPage extends StatefulWidget
{
  final UserExercise exercise;
  final Function nextExercise;


  CameraPage(this.exercise,this.nextExercise);

  @override
  _CameraPageState createState() => new _CameraPageState();

}

class _CameraPageState extends State<CameraPage>
{
  //SavePoints savePoints;
  List<dynamic> _recognitions;
  bool isDebug = false;

  List<List<Point>> resultsList = [];
  bool isRecording = false;
  int recordCounter = 0;

  int _imageHeight = 0;
  int _imageWidth = 0;
  int currentSet = 1;

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  bool checkRecording()
  {
    return isRecording;
  }

  posenetOver(){
    onRecord(context);
  }

  setSavePoints(SavePoints svPoints){
    //savePoints = svPoints;
  }
  
  
  exitToMenu() => 
  {
      Navigator.pop(context)
  };

  nextExercise() =>{
    widget.nextExercise(),
    exitToMenu()
  };

  nextSet() =>{
    currentSet++
  };

    void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

  Future<http.Response> getDistance(List<List<Point>> resultsList) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("userId");
    

    UserExercise curEx = widget.exercise;

    var exerciseId = curEx.id;
    printWrapped(jsonEncode(resultsList));
    print("${Constants.webPath}users/$userId/exercises/$exerciseId");
    return http.post("${Constants.webPath}users/$userId/exercises/$exerciseId",
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'authorization' : prefs.getString("token")
    },
    body: jsonEncode(resultsList)
    );
  }


  Future<http.Response> getDistanceOfCurrent(List<List<Point>> resultsList)
  {
      return getDistance(resultsList);
  }
  @override
  void initState() 
  {
    //setSavePoints(SavePoints());
    super.initState();
  }

    
  

  void addResults(List<Point> frameResults)
  {

    resultsList.add(frameResults);
  }



  void onRecord(BuildContext context) async
  {
    if(!isRecording)
    {
      recordCounter++;
      http.Response response = await getDistanceOfCurrent(resultsList);
      try{
        print("current set:" + currentSet.toString());
        print("set count:" + widget.exercise.exerciseDetails.setCount.toString());
        printWrapped(response.body);
        dynamic matches;
        
        matches = jsonDecode(response.body)["data"]["match"];

        bool isCorrect = false;
        int count = 0;
        int repeat = 0;

        for(var match in matches)
        {
          isCorrect = match["isCorrect"];
          count = match["count"];
          repeat = match["repeat"];
        }


        String title;
        if(isCorrect) title = "Congratulations"; else title = "You Failed";
        

        showDialog(context: context,
                    builder: (BuildContext context){
                    return CustomDialogBox(
                      title: title,
                      descriptions: "You have made $count repeats",
                      text1: "Try again",
                      text2: currentSet == widget.exercise.exerciseDetails.setCount ? "Finish Move" : "Next Set",
                      exitFunction: currentSet == widget.exercise.exerciseDetails.setCount ? nextExercise : nextSet,
                    );
                    }
                  );
      }
      catch(e)
      {
        print(e);
        showDialog(context: context,
                  builder: (BuildContext context){
                  return CustomDialogBox(
                    title: "Oops!",
                    descriptions: "We couldn't see you there? Maybe you hit the finish by mistake?",
                    text1: "Try again",
                    text2: "Main Menu",
                    exitFunction: exitToMenu
                  );
                  }
                );
      }
      //_writeToFile(jsonEncode(resultsList), recordCounter.toString()+ ".json");
      //_writeToFile(response.body, recordCounter.toString()+ ".txt");
      resultsList.clear();
    }
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
                  checkRecording,
                  setRecognitions,
                  posenetOver
                ),
                //savePoints,
                BndBox(
                    _recognitions == null ? [] : _recognitions,
                    math.max(_imageHeight, _imageWidth),
                    math.min(_imageHeight, _imageWidth),
                    size.height,
                    size.width,
                    addResults),
                Container(
                  alignment: Alignment(0.0, 0.9),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    RaisedButton(
                      elevation: 5.0,
                      padding: EdgeInsets.all(15.0),
                      color: isRecording ? Colors.red : Colors.blue,
                      shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.black)
                          ),
                      child: Text(isRecording ? "Finish" : "Start", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                      
                      onPressed:() => setState(() { isRecording = !isRecording;})
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