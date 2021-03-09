import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';

class UserHistoryPage extends StatefulWidget
{
  @override
  State<StatefulWidget> createState() => new UserHistoryState();
  
}

class UserHistoryState extends State<UserHistoryPage>{
  
  ScrollController controller = ScrollController();
  bool closeTopContainer = false;
  double topContainer = 0;

  List<Widget> exercisesData = [];
  List<Widget> statsData = [];
  
  void getHistoryData()
  {
    var stat = {'name' : 'Exercises','count': 4};
    var stat1 = {'name' : 'Correct','count': 3};
    var stat2 = {'name' : 'False','count': 1};
    List<Widget> listItems = [];
    List<dynamic> responseList = new List();

    responseList.add(stat);
    responseList.add(stat1);
    responseList.add(stat2);
    responseList.forEach((post) {
      listItems.add(Container(
          height: 150,
          width: 120,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.0)), color: Colors.white, boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
          ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      post["name"],
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      post["count"].toString(),
                      style: const TextStyle(fontSize: 35, color: Colors.black,fontWeight: FontWeight.bold),
                    ),

                  ],
                ),
                /*Image.asset(
                  "assets/exerciseImages/${post["image"]}",
                  height: double.infinity,
                )*/
              ],
            ),
          ))); 
    });
    setState(() {
      statsData = listItems;
    });
  }

  void getExerciseData() async
  {
    
    var history = {'name' : 'Lateral Raise', 'date' : DateTime.now(), 'reps' : 5 , 'isCorrect' : true };
    var history1 = {'name' : 'Squat', 'date' : DateTime.now(), 'reps' : 10 , 'isCorrect' : false };
    var history2 = {'name' : 'Jumping Jack', 'date' : DateTime.now(), 'reps' : 10 , 'isCorrect' : true };
    var history3 = {'name' : 'Lateral Raise', 'date' : DateTime.now(), 'reps' : 8 , 'isCorrect' : true };
    //var response = await getExercises();
    List<dynamic> responseList = new List();
    responseList.add(history);
    responseList.add(history1);
    responseList.add(history2);
    responseList.add(history3);
    //exercisesDataRaw = jsonDecode(response.body) as List;

    //exercisesDataRaw.forEach((element) {
    //  responseList.add(element);
    // });


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
                post["isCorrect"] ? Icon ( Icons.check, color: Colors.green) : Icon(Icons.cancel, color: Colors.red),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      post["name"],
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      formatDate(post["date"],[d, '-', M, '-', yyyy, '  ', HH, ':', nn]),
                      style: const TextStyle(fontSize: 17, color: Colors.grey),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "${post["reps"]} Repeat",
                      style: const TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
                    ),

                  ],
                ),
                /*Image.asset(
                  "assets/exerciseImages/${post["image"]}",
                  height: double.infinity,
                )*/
              ],
            ),
          )));
    });
    setState(() {
      exercisesData = listItems;
    });
  }

  @override
  void initState() {
    getExerciseData();
    getHistoryData();
    controller.addListener(() {

      double value = controller.offset/119;

      setState(() {
        topContainer = value;
        closeTopContainer = controller.offset > 50;
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
                    child:  ListView.builder(
                    scrollDirection: Axis.horizontal,
                      itemCount: statsData.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        double scale = 1.0;
                        return GestureDetector(
                          onTap : () {  
                            setState(() {
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
                                    child: statsData[index]),
                                ),
                              ),
                        );
                      }),
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
                        return GestureDetector(
                          onTap : () {  
                            setState(() {
                              //onSelect(exercisesDataRaw[index]);
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
                      })),
            ],
          ),
        );
  }
  

}