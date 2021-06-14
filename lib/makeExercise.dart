import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_realtime_detection/constants.dart';
import 'package:flutter_realtime_detection/models/exerciseDetails.dart';
import 'package:flutter_realtime_detection/speechRecognititon.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bndbox.dart';
import 'camera.dart';
import 'dart:math' as math;

import 'customDialogBox.dart';
import 'models/point.dart';
import 'models/userExercise.dart';
import 'models/videoSimilarityRequest.dart';
import 'models/workout.dart';




class CameraPage extends StatefulWidget
{
  final ExerciseDetails exercise;
  final Workout workout;
  final Function nextExercise;


  CameraPage(this.exercise,this.nextExercise,this.workout);

  @override
  _CameraPageState createState() => new _CameraPageState();

}

class _CameraPageState extends State<CameraPage>
{
  List<dynamic> _recognitions;
  bool isDebug = false;

  List<List<Point>> resultsList = [];
  bool isRecording = false;
  int recordCounter = 0;

  int _imageHeight = 0;
  int _imageWidth = 0;
  int currentSet = 1;

  int cameraIx = 0;
  Input cameraInput;


    @override
  void initState() 
  {
    super.initState();
    cameraInput = Input(
                  checkRecording,
                  setRecognitions,
                );
  }


  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  void changeCam(){
    setState(() {
      cameraIx = cameraIx == 0 ? 1: 0;
      cameraInput.changeCamera();
    });
  }

  bool checkRecording()
  {
    return isRecording;
  }

  posenetOver(){
    onRecord(context);
  }


  
  
  exitToMenu() => 
  {
      Navigator.pop(context)
  };

  nextExercise() =>{
    //widget.nextExercise(),
    exitToMenu()
  };

  nextSet() =>{
    currentSet++
  };

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  Future get _localPath async {
    final externalDirectory = await getExternalStorageDirectory();

    return externalDirectory.path;
  }
  
  Future _localFile(filename) async {
    final path = await _localPath;

    return File('$path/' + filename);
  }


  Future _writeToFile(String text,String filename) async {
    
    final file = await _localFile(filename);
    await file.writeAsString('$text');
  }

  Future<http.Response> getDistance(List<List<Point>> resultsList) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("userId");
    
    ExerciseDetails curEx = widget.exercise;

    List<KeyPoints> keypoints = [];
    for(int i = 0; i < resultsList.length; i++){
      keypoints.add(KeyPoints(resultsList[i]));
    }

    KeyPointSequence sequence =  KeyPointSequence(_imageWidth, _imageHeight, keypoints);

    if(Constants.isDebug)
      _writeToFile(jsonEncode(sequence), recordCounter.toString()+ ".json");


    String exerciseName = curEx.exercise.name;
    VideoSimilarityRequest videoSim = VideoSimilarityRequest(_imageWidth,_imageHeight,keypoints);

    return http.post("${Constants.webPath}workouts/${widget.workout.id}/exerciseSets/${widget.exercise.id}:addHistory",
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'authorization' : prefs.getString("token")
    },
    body: jsonEncode(videoSim)
    );
  }


  Future<http.Response> getDistanceOfCurrent(List<List<Point>> resultsList)
  {
      return getDistance(resultsList);
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
        int count = 0;
        int repeat = 0;


        count = jsonDecode(response.body)["count"];
        bool isCorrect = widget.exercise.repeat <= count;

        String title;
        if(isCorrect) title = "Nice Work!"; else title = "You Failed";
        

        showDialog(context: context,
                    builder: (BuildContext context){
                    return CustomDialogBox(
                      title: title,
                      descriptions: "You have made $count/${widget.exercise.repeat} repeats",
                      text1: "Try again",
                      text2: currentSet == widget.exercise.setCount ? "Finish Move" : "Next Set",
                      exitFunction: currentSet == widget.exercise.setCount ? nextExercise : nextSet,
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
      resultsList.clear();
    }
  }



  void startRecording()
  {
    isRecording = true;
  }

  void stopRecording()
  {
    isRecording = false;
    onRecord(context);

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
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.flip_camera_android, color: Colors.white),
                onPressed: () {
                    changeCam();
                },
              ),
            ],
        ),
        body: 
          Stack(
              children: [
                cameraInput,
                SpeechRecog(startRecording, stopRecording),
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
                      
                      onPressed:() => setState(() => isRecording ? stopRecording() : startRecording())
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