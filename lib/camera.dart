import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'models.dart';

typedef void Callback(List<dynamic> list, int h, int w);

class Input extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final Function posenetOver;
  final Function checkRecord;
  final String model;
  bool isRecording = false;

  
  Input(this.cameras, this.model, this.checkRecord,this.setRecognitions,this.posenetOver);

  @override
  _CameraState createState() => new _CameraState();
}

class _CameraState extends State<Input> {
  CameraController controller;
  bool isDetecting = false;

  List<CameraImage> frames = new List<CameraImage>();

  @override
  void initState() {
    super.initState();

    if (widget.cameras == null || widget.cameras.length < 1) {
      print('No camera is found');
    } else {
      controller = new CameraController(
        widget.cameras[0],
        ResolutionPreset.high
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller.startImageStream((CameraImage img) {

            if(widget.checkRecord() != widget.isRecording)
            {
              record(widget.isRecording);
              print(widget.isRecording);
              print(widget.checkRecord());
              widget.isRecording = widget.checkRecord();
              
            }
            if (widget.isRecording) 
            {
              if(!isDetecting)
                {
                 //startTime = new DateTime.now().millisecondsSinceEpoch;
                  isDetecting = true;
                  Tflite.runPoseNetOnFrame(
                          bytesList: img.planes.map((plane) {
                            return plane.bytes;
                          }).toList(),
                          imageHeight: img.height,
                          imageWidth: img.width,
                          numResults: 1,
                          asynch: true,
                          threshold: 0.7,
                          nmsRadius: 20
                        ).then((recognitions) {
                          int endTime = new DateTime.now().millisecondsSinceEpoch;
                          //print("Detection took ${endTime - startTime}");
                          widget.setRecognitions(recognitions, img.height, img.width);
                          isDetecting = false;
                          
                        });
                    
                }
              frames.add(img); 
            }
          
        });
      });
    }
  }

  void record(bool isRec)
  async{
    print(widget.isRecording);
    if(isRec)
    {
      
      await finishRecord();
      widget.posenetOver();
      frames.clear();
    }
    //widget.isRecording =! widget.isRecording;
    
  }
   Future<void>  finishRecord() async{
    int ix = 0;
    int startTime = new DateTime.now().millisecondsSinceEpoch;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = tmp.height;
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(controller),
    );
  }
}
