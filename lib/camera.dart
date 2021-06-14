import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:tflite/tflite.dart';
import 'dart:math' as math;


typedef void Callback(List<dynamic> list, int h, int w);

class Input extends StatefulWidget {
  
  final Callback setRecognitions;
  final Function checkRecord;
  bool isRecording = false;

  _CameraState camState = new _CameraState();

  void changeCamera(){
    camState.changeCamera();
  }
  
  Input(  this.checkRecord,this.setRecognitions);

  @override
  _CameraState createState() => camState;
}

class _CameraState extends State<Input> {
  CameraController controller;
  bool isDetecting = false;
  List<CameraDescription> cameras;
  //List<CameraImage> frames = new List<CameraImage>();

  int camIx = 1;
  int frameOrder = 0;
  Uint8List _imageFile;


  void setCamera() async{
    try {
    cameras = await availableCameras();
    } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
     }
     if (cameras == null || cameras.length < camIx +1) {
      print('No camera is found');
    } else {
      controller = new CameraController(
        cameras[camIx],
        ResolutionPreset.high,
        enableAudio: true
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller.startImageStream((CameraImage img) {
            
            if (widget.checkRecord()) 
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
                          rotation: camIx == 0 ? 90 : -90,
                          numResults: 1,
                          asynch: false,
                          threshold: 0.1,
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

  void changeCamera(){
    try{
      controller.stopImageStream();

    }
    catch(e){
      print("error");
    }
    camIx = camIx == 0 ? 1: 0;
    setCamera();
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
        child: Transform(
            alignment: Alignment.center,
            transform: camIx == 1 ? Matrix4.rotationY(math.pi):Matrix4.rotationY(0),
            child: CameraPreview(controller),
          ),
    );
  }
}
