import 'dart:convert';
import 'package:flutter_realtime_detection/savePoints.dart';
import 'package:http/http.dart' as http;


import 'package:flutter/material.dart';


class ExercisesPage extends StatefulWidget

{

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

  String _currentExcersise = "";




  @override
  void initState() {
    getExerciseData();
    setSavePoints(SavePoints(exitFunction: exitToMenu,finishExercise: getDistanceOfCurrent));
    controller.addListener(() {

      double value = controller.offset/119;

      setState(() {
        topContainer = value;
        //closeTopContainer = controller.offset > 50;
      });
    });
    super.initState();
  }
  Future<http.Response> getDistanceOfCurrent(List<List<Point>> resultsList)
  {
      return getDistance(_currentExcersise, resultsList);
  }

  Future<http.Response> getDistance(String jsonName,List<List<Point>> resultsList)
  {


    var name = _currentExcersise.substring(0, _currentExcersise.length - 5);
    var repeat = curExerciseFull["repeat"];
    print(repeat);
    return http.post("http://157.230.108.121:8080/similarity-single/$name?repeat=$repeat&p=0.3",
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(resultsList)
    );
  }


  setSavePoints(SavePoints svPoints){
    savePoints = svPoints;
  }

  exitToMenu() => _currentExcersise = "";


  Future<http.Response> getExercises()
  async {
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
      listItems.add(Container(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      post["name"],
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      post["difficulty"],
                      style: const TextStyle(fontSize: 17, color: Colors.grey),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "${post["repeat"]} Repeat",
                      style: const TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                Image.asset(
                  "assets/exerciseImages/${post["image"]}",
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}