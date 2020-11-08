import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:tuple/tuple.dart';

import 'models.dart';

class Point
{
  final dynamic x;
  final dynamic y;
  Point(this.x,this.y);

  Map toJson() => {
        'x': x,
        'y': y,
      };
}

class SavePoints extends StatefulWidget
{
  
  List<List<Point>> resultsList = [];
  bool isRecording = false;
  int recordCounter = 0;
  void addResults(List<Point> frameResults)
  {

    resultsList.add(frameResults);
  }

  void onRecord()
  {
    if(isRecording)
    {
      recordCounter++;
      _writeToFile(jsonEncode(resultsList), recordCounter.toString()+ ".json");
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
                      color: widget.isRecording ? Colors.red : Colors.blue,
                      child: Text("Rec: " +(widget.recordCounter+1).toString()),
                      
                      onPressed: () => setState(() => widget.onRecord()),
                    ),
                  ],
                ),
      );
    }
}