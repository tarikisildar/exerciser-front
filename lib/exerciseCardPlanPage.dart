
import 'dart:math';

import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_realtime_detection/models/exerciseDetails.dart';
import 'package:flutter_realtime_detection/models/workout.dart';
import 'package:tflite/tflite.dart';

import 'enums/cardType.dart';
import 'makeExercise.dart';
import 'models/userExercise.dart';

class ExerciseCardPlan extends StatefulWidget{
  final CardType cardType;
  final ExerciseDetails exercise;
  final VoidCallback closeContainer;
  final bool isToday;
  final Workout visitedWorkout;

  ExerciseCardPlan(this.cardType,this.exercise,this.closeContainer,this.isToday,this.visitedWorkout);
  @override
  State<StatefulWidget> createState() => new ExerciseCardPlanState();

}

class ExerciseCardPlanState extends State<ExerciseCardPlan>
{
  BetterPlayerController _betterPlayerController;

  @override
    void initState(){
      super.initState();
      configureVideo();
    }

  onSelect() {

    loadModel();
    //DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
    Navigator.push(context, MaterialPageRoute(builder: (context) => CameraPage(widget.exercise,null,widget.visitedWorkout)));
    
  }
  loadModel() async {
    String res;
        res = await Tflite.loadModel(
            model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
            numThreads: 4
            );
  }

  void configureVideo()
    {
      //"https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
      String lowerName = widget.exercise.exercise.name.toLowerCase();
      lowerName = lowerName.replaceAll(' ', '');
      BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      );
      BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.NETWORK,
        widget.exercise.exercise.videoUrl,
        cacheConfiguration: BetterPlayerCacheConfiguration(useCache: true),
      );
      _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
      _betterPlayerController.setupDataSource(dataSource);
    }

  Widget card(){
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = deviceSize.width * 0.75;
    return Container(
          height: deviceSize.height * 0.9,
          width: deviceSize.width * 0.9,
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.0)), color: Colors.white, boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
          ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,                  
                  children: <Widget>[
                    Expanded(child: 
                      SizedBox(
                        width: 20,
                      ),
                    ),

                    Text(
                      widget.exercise.exercise.name,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      widget.exercise.exercise.difficulty,
                      style: const TextStyle(fontSize: 17, color: Colors.grey),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  SizedBox(
                    width: cardWidth,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: 
                        BetterPlayer(controller: _betterPlayerController)
                    ),
                  ),
                    SizedBox(
                      height: 20,
                    ),

                    Text(
                      widget.exercise.setCount.toString() + " Sets",
                      style: const TextStyle(fontSize: 27, color: Colors.grey),
                    ),
                    Text(
                      widget.exercise.repeat.toString() + " Repeats Each",
                      style: const TextStyle(fontSize: 27, color: Colors.grey),
                    ),
                    Expanded(child: 
                      SizedBox(
                        width: 20,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>
                      [
                      SizedBox(
                        width: cardWidth/2-5,
                        child:  RaisedButton(
                          onPressed: () {widget.closeContainer();},
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.black)
                          ),
                          child: Text("Back", style : TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold)
                          ),
                        ),
                        
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: cardWidth/2-5,
                        child:  widget.isToday ? RaisedButton(
                          onPressed: () {
                            onSelect();
                            },
                          color:  Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.black)
                          ),
                          child: Text("Start The Exercise",textAlign: TextAlign.center, style : TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold)
                          ),
                        ) : SizedBox(),
                      ),
                      
                    ]
                    )
                  ]
                ),
                
                /*Image.asset(
                  "assets/exerciseImages/${post["image"]}",
                  height: double.infinity,
                )*/

              ],
            ),
          )
        );
  }
  
  @override
  Widget build(BuildContext context) {
    
    return SafeArea(child: AnimatedSwitcher(
      duration: Duration(seconds: 1),
      child: card()
      )
    );
  }

}