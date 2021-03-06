
import 'dart:convert';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;
import 'package:speech_recognition/speech_recognition.dart';

import 'customDialogBox.dart';
import 'home.dart';
import 'camera.dart';

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

const languages = const [
  const Language('English', 'en_US'),
  const Language('Francais', 'fr_FR'),
  const Language('Pусский', 'ru_RU'),
  const Language('Italiano', 'it_IT'),
  const Language('Español', 'es_ES'),
];

class Language {
  final String name;
  final String code;

  const Language(this.name, this.code);
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
    if(!isRecording)
    {
      recordCounter++;
      String score = "";
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
        var matches = jsonDecode(response.body)["match"];

        bool isCorrect = false;
        int count = 0;
        int repeat = 0;

        for(var match in matches)
        {
          isCorrect = match["isCorrect"];
          count = match["count"];
          repeat = match["repeat"];
        }

        //score = jsonDecode(response.body)["match"][0]["distance"];
        //var scoreLis = jsonDecode(response.body)["match"][0]["distance"];
        //String scoreSt = scoreLis.toString();

        String title;
        if(isCorrect) title = "Congratulations"; else title = "You Failed";
        

        showDialog(context: context,
                    builder: (BuildContext context){
                    return CustomDialogBox(
                      title: title,
                      descriptions: "You have made $count repeats",
                      text1: "Try again",
                      text2: "Ok",
                      exitFunction: exitFunction,
                    );
                    }
                  );
      }
      _writeToFile(jsonEncode(resultsList), recordCounter.toString()+ ".json");
      _writeToFile(response.body, recordCounter.toString()+ ".txt");
      resultsList.clear();
    }
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

  SpeechRecognition _speech;
  bool _speechRecognitionAvailable = false;
  bool _isListening = false;

  Language selectedLang = languages.first;

  String transcription = '';

  
  final String startingWord = "başla";
  final String finishWord = "bitir";

  @override
  initState() {
    super.initState();
    activateSpeechRecognizer();
   
  }

  void activateSpeechRecognizer() {
    print('_MyAppState.activateSpeechRecognizer... ');
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setCurrentLocaleHandler(onCurrentLocale);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech
        .activate()
        .then((res) { setState(() => _speechRecognitionAvailable = res);
        start();
        });
  }



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
                      child: Text(widget.isRecording ? "Finish" : "Start"),
                      
                      onPressed:() => setState(() { widget.isRecording = !widget.isRecording;})
                    ),
                    
                  ],
                ),
      );
    }

  Widget _buildButton({String label, VoidCallback onPressed}) => new Padding(
      padding: new EdgeInsets.all(12.0),
      child: new RaisedButton(
        color: Colors.cyan.shade600,
        onPressed: onPressed,
        child: new Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ));


  void start() => _speech
    .listen(locale: selectedLang.code)
    .then((result) => print('_MyAppState.start => result $result'));

  void cancel() =>
      _speech.cancel().then((result) => setState(() => _isListening = result));

  void stop() => _speech.stop().then((result) {
        setState(() => _isListening = result);
      });

  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  void onCurrentLocale(String locale) {
    print('_MyAppState.onCurrentLocale... $locale');
    setState(
        () => selectedLang = languages.firstWhere((l) => l.code == locale));
  }

  void onRecognitionStarted() => setState(() => _isListening = true);

  void onRecognitionResult(String text) { 
    setState(() => transcription = text);
    var words = text.split(" ");
    String lastWord = words[words.length-1].toLowerCase();
    if(lastWord == startingWord)
    {
      widget.isRecording = true;
    }
    if(lastWord == finishWord)
    {
      widget.isRecording = false;
    }
    
  }

  void onRecognitionComplete() => setState(() => _isListening = false);

  void errorHandler() => activateSpeechRecognizer();
}

