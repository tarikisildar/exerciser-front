
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';

import 'package:speech_recognition/speech_recognition.dart';



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



class SpeechRecog extends StatefulWidget
{
  
 
  final Function onStart;
  final Function onFinish;
  SpeechRecog(this.onStart,this.onFinish);

  @override
  RecordState createState() => RecordState();
}
class RecordState extends State<SpeechRecog>
{

  SpeechRecognition _speech;
  bool _speechRecognitionAvailable = false;
  bool _isListening = false;

  Language selectedLang = languages.first;

  String transcription = '';

  
  final String startingWord = "start";
  final String finishWord = "finish";
  final String finishWordAlternative = "bitir";
  final String startWordAlternative = "başla";


  @override
  initState() {
    super.initState();
    activateSpeechRecognizer();
  }

  @override
  void dispose() {
    super.dispose();
    stop();
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
    
    setState(
        ()=>print('_MyAppState.onCurrentLocale... $locale'));
  }

  void onRecognitionStarted() => setState(() => _isListening = true);

  void onRecognitionResult(String text) 
  { 
    setState(() => transcription = text);
    var words = text.split(" ");
    String lastWord = words[words.length-1].toLowerCase();
    if(lastWord == startingWord || lastWord == startWordAlternative)
    {
      widget.onStart();
    }
    if(lastWord == finishWord || lastWord == finishWordAlternative)
    {
      widget.onFinish();
    }
    
  }

  void onRecognitionComplete() => setState(() => _isListening = false);

  void errorHandler() => activateSpeechRecognizer();
}

