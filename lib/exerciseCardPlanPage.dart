
import 'dart:math';

import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'enums/cardType.dart';
import 'exerciseModel.dart';

class ExerciseCardPlan extends StatefulWidget{
  final CardType cardType;
  final UserExercise exercise;
  final VoidCallback closeContainer;

  ExerciseCardPlan(this.cardType,this.exercise,this.closeContainer);
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

  void configureVideo()
    {
      BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      );
      BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.NETWORK,
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
        cacheConfiguration: BetterPlayerCacheConfiguration(useCache: true),
      );
      _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
      _betterPlayerController.setupDataSource(dataSource);
    }

  Widget card(){
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = min(deviceSize.width * 0.75, 360.0);
    return Container(
          height: deviceSize.height * 0.9,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.0)), color: Colors.white, boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
          ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
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
                      widget.exercise.exerciseDetails.exercise.name,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      widget.exercise.exerciseDetails.exercise.difficulty,
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
                      widget.exercise.exerciseDetails.setCount.toString() + " Sets",
                      style: const TextStyle(fontSize: 27, color: Colors.grey),
                    ),
                    Text(
                      widget.exercise.exerciseDetails.repeat.toString() + " Repeats Each",
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
                        width: 160,
                        child:  RaisedButton(
                          onPressed: () {widget.closeContainer();},
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.black)
                          ),
                          child: Text("Back", style : TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)
                          ),
                        ),
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