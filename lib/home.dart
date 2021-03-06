import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_realtime_detection/constants.dart';
import 'package:flutter_realtime_detection/savePoints.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:speech_recognition/speech_recognition.dart';


import 'draw.dart';

import 'camera.dart';
import 'bndbox.dart';
import 'models.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  

  HomePage(this.cameras);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _currentExcersise = "";
  dynamic curExerciseFull;
  String _model = posenet;
  SavePoints savePoints;
  bool isDebug = false;

  bool closeTopContainer = true;
  double topContainer = 0;
  ScrollController controller = ScrollController();
  List<Widget> exercisesData = [];
  List<dynamic> exercisesDataRaw;
  @override
  void initState() {
    getExerciseData();
    setSavePoints(SavePoints(exitFunction: exitToMenu,finishExercise: getDistanceOfCurrent));
    controller.addListener(() {

      double value = controller.offset/119;

      setState(() {
        topContainer = value;
        //closeTopContainer = controller.offset > 50;
      });
    });
    super.initState();
  }

  loadModel() async {
    String res;
        res = await Tflite.loadModel(
            model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
            numThreads: 4
            );
    print(res);
  }
  setSavePoints(SavePoints svPoints){
    savePoints = svPoints;
  }
  onSelect(excersise) {
    _currentExcersise = excersise["points"];
    curExerciseFull = excersise;
    loadModel();
  }

  exitToMenu() => _currentExcersise = "";

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

  Future<http.Response> getDistanceOfCurrent(List<List<Point>> resultsList)
  {
      return getDistance(_currentExcersise, resultsList);
  }

  Future<http.Response> getDistance(String jsonName,List<List<Point>> resultsList)
  {


    var name = _currentExcersise.substring(0, _currentExcersise.length - 5);
    var repeat = curExerciseFull["repeat"];
    print(repeat);
    return http.post("http://157.230.108.121:8080/similarity-single/$name?repeat=$repeat&p=0.3",
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(resultsList)
    );
  }

  Future<http.Response> getExercises()
  {
    return http.get("http://157.230.108.121:8080/exercises");
  }

  void getExerciseData() async
  {
    var response = await getExercises();
    List<dynamic> responseList = new List();
    exercisesDataRaw = jsonDecode(response.body) as List;
    exercisesDataRaw.forEach((element) {
      responseList.add(element);
     });


    //List<Map<String,String>> responseList = parsed.map<Map<String,String>>((json) => HashMap<String,String>.fromJson(json)).toList();

    List<Widget> listItems = [];
    responseList.forEach((post) {
      listItems.add(Container(
          height: 150,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.0)), color: Colors.white, boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
          ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      post["name"],
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      post["difficulty"],
                      style: const TextStyle(fontSize: 17, color: Colors.grey),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "${post["repeat"]} Repeat",
                      style: const TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                Image.asset(
                  "assets/exerciseImages/${post["image"]}",
                  height: double.infinity,
                )
              ],
            ),
          )));
    });
    setState(() {
      exercisesData = listItems;
    });

  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height*0.30;
    return SafeArea(
      child: _currentExcersise == ""
          ?
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
      body:  Container(
          height: size.height,
          child: Column(
            children: <Widget>[
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: closeTopContainer?0:1,
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: size.width,
                    alignment: Alignment.topCenter,
                    height: closeTopContainer?0:categoryHeight,
                    ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                  child: ListView.builder(
                    controller: controller,
                      itemCount: exercisesData.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        double scale = 1.0;
                        return GestureDetector(
                          onTap : () {  
                            setState(() {
                      
                              onSelect(exercisesDataRaw[index]);
                              
                            });
                            },
                            child: Opacity(
                              opacity: scale,
                              child:
                          
                              Transform(
                                transform:  Matrix4.identity()..scale(scale,scale),
                                alignment: Alignment.bottomCenter,
                                child: Align(
                                    heightFactor: 1,
                                    alignment: Alignment.topCenter,
                                    child: exercisesData[index]),
                                ),
                              ),
                        );
                      })),
            ],
          ),
        ),
        
      )
       :
       Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
              icon : Icon(
                Icons.arrow_back_ios_outlined,
                color: Colors.white,
              ),
              onPressed: () => {_currentExcersise = ""},
            ),
        ),
        body: 
          Stack(
              children: [
                Input(
                  widget.cameras,
                  _model,
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
                    _model,
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
