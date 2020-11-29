
import 'dart:convert';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;

import 'customDialogBox.dart';
import 'home.dart';


class Point
{
  final dynamic name;
  final dynamic x;
  final dynamic y;
  Point(this.name,this.x,this.y);

  Map toJson() => {
        'name': name,
        'x': x,
        'y': y,
      };
}

class SavePoints extends StatefulWidget
{
  
  final Function exitFunction;
  final Future<http.Response> Function(List<List<Point>>) finishExercise;
  SavePoints({this.exitFunction,this.finishExercise});

  List<List<Point>> resultsList = [];
  bool isRecording = false;
  int recordCounter = 0;
  
  

  void addResults(List<Point> frameResults)
  {

    resultsList.add(frameResults);
  }

  

  void onRecord(BuildContext context) async
  {
    print(isRecording);
    if(isRecording)
    {
      recordCounter++;
      double score = 0;
      http.Response response = await finishExercise(resultsList);
      if(response.statusCode != 200){
        showDialog(context: context,
                  builder: (BuildContext context){
                  return CustomDialogBox(
                    title: "Oops!",
                    descriptions: "We couldn't see you there? Maybe you hit the finish by mistake?",
                    text1: "Try again",
                    text2: "Main Menu",
                    exitFunction: exitFunction,
                  );
                  }
                );
            
      }
      else
      {
        print(response.body);
        score = jsonDecode(response.body)["match"][0]["distance"];
        showDialog(context: context,
                    builder: (BuildContext context){
                    return CustomDialogBox(
                      title: "Congratulations",
                      descriptions: "You finished the exercise with the distance of $score",
                      text1: "Try again",
                      text2: "Ok",
                      exitFunction: exitFunction,
                    );
                    }
                  );
      }
      //_writeToFile(jsonEncode(resultsList), recordCounter.toString()+ ".json");
      resultsList.clear();
    }
    isRecording = !isRecording;
  }





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

  

  @override
  RecordState createState() => RecordState();
}
class RecordState extends State<SavePoints>
{
  bool _isRecording = false;
  @override
    Widget build(BuildContext context) {
      return Container(
        alignment: Alignment(0.0, 0.9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    RaisedButton(
                      elevation: 5.0,
                      padding: EdgeInsets.all(15.0),
                      color: _isRecording ? Colors.red : Colors.blue,
                      child: Text(_isRecording ? "Finish" : "Start"),
                      
                      onPressed:() => setState(() {widget.onRecord(context); _isRecording = !_isRecording;} )
                    ),
                  ],
                ),
      );
    }
    
}

