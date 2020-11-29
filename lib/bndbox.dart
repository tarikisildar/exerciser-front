import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_realtime_detection/home.dart';
import 'package:flutter_realtime_detection/savePoints.dart';
import 'package:tuple/tuple.dart';
import 'dart:math' as math;
import 'models.dart';
import 'draw.dart';


class BndBox extends StatelessWidget {
  final List<dynamic> results;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;
  final String model;
  final SavePoints savePoints;

  Map pointCoordinates = Map<String, List<double>>();

  Map pointLinks = { "nose" : ["leftEye","rightEye","leftShoulder","rightShoulder"] , "leftEye" : ["leftEar"] , "rightEye": ["rightEar"],
   "leftEar" : [], "rightEar" : [], "leftShoulder" : ["leftHip","leftElbow"], "leftElbow": ["leftWrist"], "leftWrist" : [], 
   "leftHip" : ["leftKnee"], "leftKnee" : ["leftAnkle"],
   "rightShoulder" : ["rightHip","rightElbow"], "rightElbow": ["rightWrist"], "rightWrist" : [], 
   "rightHip" : ["rightKnee"], "rightKnee" : ["rightAnkle"] };

  BndBox(this.results, this.previewH, this.previewW, this.screenH, this.screenW,
      this.model,this.savePoints);

  T cast<T>(x) => x is T ? x : null;

  @override
  Widget build(BuildContext context) {
    List<Widget> _renderBoxes() {
      return results.map((re) {
        var _x = re["rect"]["x"];
        var _w = re["rect"]["w"];
        var _y = re["rect"]["y"];
        var _h = re["rect"]["h"];
        var scaleW, scaleH, x, y, w, h;

        if (screenH / screenW > previewH / previewW) {
          scaleW = screenH / previewH * previewW;
          scaleH = screenH;
          var difW = (scaleW - screenW) / scaleW;
          x = (_x - difW / 2) * scaleW;
          w = _w * scaleW;
          if (_x < difW / 2) w -= (difW / 2 - _x) * scaleW;
          y = _y * scaleH;
          h = _h * scaleH;
        } else {
          scaleH = screenW / previewW * previewH;
          scaleW = screenW;
          var difH = (scaleH - screenH) / scaleH;
          x = _x * scaleW;
          w = _w * scaleW;
          y = (_y - difH / 2) * scaleH;
          h = _h * scaleH;
          if (_y < difH / 2) h -= (difH / 2 - _y) * scaleH;
        }

        var container = Container(
            padding: EdgeInsets.only(top: 5.0, left: 5.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                width: 3.0,
              ),
            ),
            child: Text(
              "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            
          );
        return Positioned(
          left: math.max(0, x),
          top: math.max(0, y),
          width: w,
          height: h,
          child: container,
        );
      }).toList();
    }

    List<Widget> _renderStrings() {
      double offset = -10;
      return results.map((re) {
        offset = offset + 14;
        return Positioned(
          left: 10,
          top: offset,
          width: screenW,
          height: screenH,
          child: Text(
            "${re["label"]} ${(re["confidence"] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              color: Color.fromRGBO(37, 213, 253, 1.0),
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList();
    }


    List<Widget> _renderLines(){
      var listWidget =  <Widget>[];
      pointLinks.keys.forEach((element) 
      {

        if(pointCoordinates[element] == null)
        {
          return;
        }
        var list = pointLinks[element].map<Widget>((pointName) 
        {

          var pointTo = pointCoordinates[pointName];
          var pointFrom = pointCoordinates[element];
          return  Positioned(

            width: 100,
            height: 12,           
            child: Container(
              child: CustomPaint(
                painter: DrawLine([pointFrom[0],pointFrom[1],pointTo[0],pointTo[1]]),
              ),
            )
            );
        }).toList();
        listWidget..addAll(list);
        
      });
      return listWidget;
    }

    List<Widget> _renderKeypoints() {
      var lists = <Widget>[];
      var points = [];
      List<Point> framePoints = [];
      results.forEach((re) {
        var list = re["keypoints"].values.map<Widget>((k) {
          var _x = k["x"];
          var _y = k["y"];
          
          var scaleW, scaleH, x, y;
          framePoints.add(Point(k["part"],_x, _y));
          if (screenH / screenW > previewH / previewW) {
            scaleW = screenH / previewH * previewW;
            scaleH = screenH;
            var difW = (scaleW - screenW) / scaleW;
            x = (_x - difW / 2) * scaleW;
            y = _y * scaleH;
          } else {
            scaleH = screenW / previewW * previewH;
            scaleW = screenW;
            var difH = (scaleH - screenH) / scaleH;
            x = _x * scaleW;
            y = (_y - difH / 2) * scaleH;
          }
          pointCoordinates[k["part"]] = [cast<double>(x),cast<double>(y)];
          return Positioned(
            left: x - 6,
            top: y - 6,
            width: 100,
            height: 12,
            child: Container(
              child: Text(
                    "● ${k["part"]}",
                    style: TextStyle(
                    color: Color.fromRGBO(37, 213, 253, 1.0),
                    fontSize: 12.0,
                ),
              ),              
            ),
          );
          
        }).toList();

        lists..addAll(list);
      });
      lists..addAll(_renderLines());
      savePoints.addResults(framePoints);
      return lists;
    }

    
    var keyPoints = _renderKeypoints();

    return Stack(
      children: 
          keyPoints,
          
    );
  }
}
