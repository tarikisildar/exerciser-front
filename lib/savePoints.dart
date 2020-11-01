import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:tuple/tuple.dart';

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

class SavePoints
{

  List<List<Point>> resultsList = [];
  void addResults(List<Point> frameResults)
  {
    
    resultsList.add(frameResults);
    printWrapped(jsonEncode(resultsList));
    
  }
void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}
  
}