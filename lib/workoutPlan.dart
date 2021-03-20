import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class WorkoutPlanPage extends StatefulWidget 
{
  final bool isEventListActive;
  final CalendarFormat calendarFormat;
  final Function selectDay;
  final DateTime startDay;
  WorkoutPlanPage(this.isEventListActive,this.calendarFormat,this.selectDay,this.startDay);
  @override
  State<StatefulWidget> createState() => new WorkoutPlanState();
}

class WorkoutPlanState extends State<WorkoutPlanPage> with TickerProviderStateMixin
{
  ScrollController controller = ScrollController();
  double topContainer = 0;
  
  bool closeTopContainer = false;
  
  List<Widget> exercisesData = [];

  CalendarController calendarController;
  Map<DateTime, List<dynamic>> events;
  List<dynamic> selectedEvents;
  AnimationController animationController;
  

 @override
  void initState(){
      super.initState();
      getExerciseData();
      calendarController = CalendarController();
      //calendarController.setCalendarFormat(CalendarFormat.week);
      events = {};
      selectedEvents = [];

      final selectedDay = DateTime.now();

      events[selectedDay] = [exercisesData[0],exercisesData[1],exercisesData[2]];
      events[selectedDay.subtract(Duration(days: 2))] = [exercisesData[3],exercisesData[2],exercisesData[1]];

      selectedEvents = events[selectedDay];
      animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );

      animationController.forward();

  }

  @override
  void dispose() {
    animationController.dispose();
    calendarController.dispose();
    super.dispose();
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
                Image.asset(
                  "assets/logo.png",
                  height: 100,
                ),
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
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height*0.25;
    return Container(
          //height: size.height,
          child: Column(
            children: <Widget>[
              buildCalendar(),
              widget.isEventListActive ? buildEventList() : SizedBox(height:1)
            ],
          ),
        );
  }
  Widget buildCalendar(){
    return TableCalendar(
      startDay: widget.startDay,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
        holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
      ),

      calendarController: calendarController,
      events: events,
      initialCalendarFormat: widget.calendarFormat,
      availableCalendarFormats: {
        widget.calendarFormat : ''
      },
      onDaySelected: (date, events,holidays) {
        try
        {
          widget.selectDay(date);
        }
        catch(exception)
        {
          print("no selected day event");
        }
        animationController.forward(from: 0.0);
        setState(() {
          selectedEvents = events;
            },
          );
        },
      builders: CalendarBuilders(
      selectedDayBuilder: (context, date, _) {
        return FadeTransition(
          opacity: Tween(begin: 0.0, end: 1.0).animate(animationController),
          child: Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: Colors.deepOrange[300],
            width: 100,
            height: 100,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          ),
        );
      },
      todayDayBuilder: (context, date, _) {
        return Container(
          margin: const EdgeInsets.all(4.0),
          padding: const EdgeInsets.only(top: 5.0, left: 6.0),
          color: Colors.amber[400],
          width: 100,
          height: 100,
          child: Text(
            '${date.day}',
            style: TextStyle().copyWith(fontSize: 16.0),
          ),
        );
      },
      markersBuilder: (context, date, events, holidays) {
        final children = <Widget>[];

        if (events.isNotEmpty) {
          children.add(
            Positioned(
              right: 1,
              bottom: 1,
              child: buildEventsMarker(date, events),
            ),
          );
        }

        return children;
      },
    ),
);
  }
  Widget buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: calendarController.isSelected(date)
            ? Colors.brown[500]
            : calendarController.isToday(date)
                ? Colors.brown[300]
                : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget buildEventList() {
    final Size size = MediaQuery.of(context).size;
    return  Expanded(
      child: ListView.builder(
          controller: controller,
            itemCount: selectedEvents.length,
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
                          child: AnimatedSwitcher(
                              
                            duration: Duration(milliseconds:500),
                            child:selectedEvents[index]),
                      ),
                    ),
              )
              );
        })
      
    );
  }
  
}