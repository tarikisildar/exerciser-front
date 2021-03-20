import 'dart:convert';
import 'package:flutter_realtime_detection/enums/cardType.dart';
import 'package:flutter_realtime_detection/makeExercise.dart';
import 'package:flutter_realtime_detection/models.dart';
import 'package:flutter_realtime_detection/savePoints.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

import 'exerciseCards.dart';
import 'package:animations/animations.dart';




class ExercisesPage extends StatefulWidget

{

  ExercisesPage();

  @override
  State<StatefulWidget> createState() => new ExersisesState();
}

class ExersisesState extends State<ExercisesPage>
{

  List<Widget> exercisesData = [];
  List<dynamic> exercisesDataRaw;
  dynamic curExerciseFull;

  ScrollController controller = ScrollController();
  double topContainer = 0;



  SavePoints savePoints;

  String currentExcersise = "";
  String model = posenet;

  
  bool closeTopContainer = true;


  Future<http.Response> getExercises()
  {
    return http.get("http://157.230.108.121:8080/exercises");
  }

  void getExerciseData() async
  {
    var response = await getExercises();
    List<dynamic> responseList = new List();
    
    exercisesDataRaw = jsonDecode(response.body) as List;
    exercisesDataRaw.forEach((element) {
      responseList.add(element);
     });


    //List<Map<String,String>> responseList = parsed.map<Map<String,String>>((json) => HashMap<String,String>.fromJson(json)).toList();

    List<Widget> listItems = [];
    responseList.forEach((post) {
      listItems.add(
        Container(
          height: 150,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.0)), color: Colors.white, boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
          ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[    
                      SizedBox(
                        height: 10,
                      ),
                        Text(
                            post["name"],
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),

                      Text(
                        post["difficulty"],
                        style: const TextStyle(fontSize: 17, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                /*Image.asset(
                  "assets/exerciseImages/${post["image"]}",
                  height: double.infinity,
                )*/
                Image.asset(
                  "assets/logo.png",
                  height: double.infinity,
                )
              ],
            ),
          )));
    });
    setState(() {
      exercisesData = listItems;
    });
  }

  loadModel() async {
    String res;
        res = await Tflite.loadModel(
            model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
            numThreads: 4
            );
    print(res);
  }

  onSelect(excersise,index) {
    currentExcersise = excersise["points"];
    curExerciseFull = excersise;
    

    //loadModel();
    //Navigator.push(context, MaterialPageRoute(builder: (context) => CameraPage(curExerciseFull,model)));
    
  }


  @override
  void initState() {
    getExerciseData();
    controller.addListener(() {

      double value = controller.offset/119;

      setState(() {
        topContainer = value;
        //closeTopContainer = controller.offset > 50;
      });
    });
    super.initState();
  }
  

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height*0.30;
    return Container(
          height: size.height,
          child: Column(
            children: <Widget>[
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: closeTopContainer?0:1,
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: size.width,
                    alignment: Alignment.topCenter,
                    height: closeTopContainer?0:categoryHeight,
                    ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                  child: ListView.builder(
                    controller: controller,
                      itemCount: exercisesData.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        double scale = 1.0;
                        return OpenContainer(
                          closedBuilder: (_, openContainer){
                          return GestureDetector(
                          onTap : () {  
                            setState(() {
                              openContainer();
                              onSelect(exercisesDataRaw[index], index);
                            });
                            },
                            child: Opacity(
                              opacity: scale,
                              child:
                          
                              Transform(
                                transform:  Matrix4.identity()..scale(scale,scale),
                                alignment: Alignment.bottomCenter,
                                child: Align(
                                    heightFactor: 1,
                                    alignment: Alignment.topCenter,
                                    child: exercisesData[index]),
                                ),
                              ),
                        );
                        
                        },
                          openBuilder: (_, closeContainer)
                          {
                              return ExerciseCard(CardType.exercise,curExerciseFull,closeContainer);
                          },
                        );
                      })),
            ],
          ),
        );
  }

}