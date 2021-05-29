import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_realtime_detection/constants.dart';
import 'package:flutter_realtime_detection/main.dart';
import 'package:flutter_realtime_detection/savePoints.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
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

  int cameraIx = 0;
  Input cameraInput;

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
    Future get _localPath async {
    // Application documents directory: /data/user/0/{package_name}/{app_name}
    //final applicationDirectory = await getApplicationDocumentsDirectory();
 
    // External storage directory: /storage/emulated/0
    final externalDirectory = await getExternalStorageDirectory();
 
    // Application temporary directory: /data/user/0/{package_name}/cache
    //final tempDirectory = await getTemporaryDirectory();
 
    return externalDirectory.path;
  }
  Future _localFile(filename) async {
    final path = await _localPath;

    return File('$path/' + filename);
  }
Future _writeToFile(String text,String filename) async {
    
 
    final file = await _localFile(filename);
 
    // Write the file
    File result = await file.writeAsString('$text');
  }

  Future<http.Response> getDistance(List<List<Point>> resultsList) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("userId");
    

    UserExercise curEx = widget.exercise;

    var exerciseId = curEx.id;
    List<KeyPoints> keypoints = [];
    for(int i = 0; i < resultsList.length; i++){
      keypoints.add(KeyPoints(resultsList[i]));
    }
    

    KeyPointSequence sequence =  KeyPointSequence(_imageWidth, _imageHeight, keypoints);

    //printWrapped(jsonEncode(keypoints));
    if(Constants.isDebug)
      _writeToFile(jsonEncode(sequence), recordCounter.toString()+ ".json");


    String exerciseName = curEx.exerciseDetails.exercise.name;
    VideoSimilarityRequest videoSim = VideoSimilarityRequest(0,_imageWidth,_imageHeight,keypoints,15,15,exerciseName);
    print(jsonEncode(videoSim));

    //print("${Constants.webPath}users/$userId/exercises/$exerciseId");
    return http.post("${Constants.gwPath}similarities/video",
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
  @override
  void initState() 
  {
    //setSavePoints(SavePoints());
    super.initState();
    cameraInput = Input(
                  checkRecording,
                  setRecognitions,
                );
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
                      
                      onPressed:() => setState(() { isRecording = !isRecording;
                        if(!isRecording){
                          onRecord(context);
                        }
                      })
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