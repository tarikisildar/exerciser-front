import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'models.dart';

typedef void Callback(List<dynamic> list, int h, int w);

class Input extends StatefulWidget {
  
  final Callback setRecognitions;
  final Function posenetOver;
  final Function checkRecord;
  bool isRecording = false;

  
  Input(  this.checkRecord,this.setRecognitions,this.posenetOver);

  @override
  _CameraState createState() => new _CameraState();
}

class _CameraState extends State<Input> {
  CameraController controller;
  bool isDetecting = false;
  List<CameraDescription> cameras;
  //List<CameraImage> frames = new List<CameraImage>();
  
  

  void setCamera() async{
    try {
    cameras = await availableCameras();
    } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
     }
     if (cameras == null || cameras.length < 1) {
      print('No camera is found');
    } else {
      controller = new CameraController(
        cameras[0],
        ResolutionPreset.high
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller.startImageStream((CameraImage img) {
            //print(widget.checkRecord().toString() + "vs" + widget.isRecording.toString());
            if(widget.checkRecord() != widget.isRecording)
            {
              print("checkRecord:" + widget.isRecording.toString());
              record(widget.isRecording);
              widget.isRecording = widget.checkRecord();
              
            }
            if (widget.isRecording) 
            {
              if(!isDetecting)
                {
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
                          widget.setRecognitions(recognitions, img.height, img.width);
                          isDetecting = false;
                          
                        });
                    
                }
              //frames.add(img); 
            }
          
        });
      });
    }

  }

  @override
  void initState() {
    super.initState();
    setCamera();
    
  }

  void record(bool isRec)
  async{
    //print(widget.isRecording);
    if(isRec)
    {
      
      //await finishRecord();
      widget.posenetOver();
      //frames.clear();
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
