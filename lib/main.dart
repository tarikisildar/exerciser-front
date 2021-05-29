import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:flutter_realtime_detection/login.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      title: 'tflite real-time detection',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFFFFF),
        brightness: Brightness.light,
      ),
      home: LoginScreen()
    );
  }
}
