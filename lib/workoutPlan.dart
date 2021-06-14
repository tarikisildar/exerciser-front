import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_realtime_detection/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:tflite/tflite.dart';

import 'enums/cardType.dart';
import 'exerciseCardPlanPage.dart';
import 'makeExercise.dart';
import 'models/filteredExercise.dart';
import 'models/exerciseDetails.dart';
import 'models/history.dart';
import 'models/user.dart';
import 'models/userExercise.dart';
import 'models/workout.dart';

class WorkoutPlanPage extends StatefulWidget 
{
  final bool isEventListActive;
  final CalendarFormat calendarFormat;
  final Function selectDay;
  final DateTime startDay;
  final User visitedUser;
  final Workout visitedWorkout;
  WorkoutPlanPage(this.isEventListActive,this.calendarFormat,this.selectDay,this.startDay,this.visitedUser,this.visitedWorkout);
  @override
  State<StatefulWidget> createState() => new WorkoutPlanState();
}

class WorkoutPlanState extends State<WorkoutPlanPage> with TickerProviderStateMixin
{
  ScrollController controller = ScrollController();
  double topContainer = 0;
  String userId;
  
  bool closeTopContainer = false;
  
  List<Widget> exercisesData = [];

  CalendarController calendarController;
  Map<DateTime, List<dynamic>> events;
  List<dynamic> selectedEvents;
  AnimationController animationController;
  
  List<DateTime> startingEndingDates = new List(2);
  List<ClientExercise> responseList = new List();

  ExerciseDetails currentExercise;
  List<ExerciseDetails> userExercises = [];
  List<ExerciseDetails> userExercisesToday = [];
  DateTime selectedDate = DateTime.now();


 @override
  void initState(){
      super.initState();
      if(widget.visitedWorkout != null)
        getExerciseData(DateTime.now().subtract(Duration(days: 7)),DateTime.now().add(Duration(days: 7)));
      
      calendarController = CalendarController();
      //calendarController.setCalendarFormat(CalendarFormat.week);
      events = {};
      selectedEvents = [];

      final selectedDay = new DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      selectedDate = selectedDay;
      //events[selectedDay] = [exercisesData[0],exercisesData[1],exercisesData[2]];
      //events[selectedDay.subtract(Duration(days: 2))] = [exercisesData[3],exercisesData[2],exercisesData[1]];

      addCurrentWindowEvents();
      
      selectedEvents = events[selectedDay];
      animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );


      for (int i = 0; i < userExercisesToday.length; i++)
      {
        var now =DateTime.now();
        DateTime todayFirst = new DateTime(now.year, now.month, now.day);
        DateTime todayLast =  new DateTime(now.year, now.month, now.day,23,59,59);
        var histories = findHistories(userExercisesToday[i], todayFirst, todayLast);
      }


      animationController.forward();
      setUser();


  }

  void setUser() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
  }

  void addCurrentWindowEvents()
  {
    setState(() {
      events.clear();
      print("events: " + exercisesData.length.toString());
      for(int i = 0; i < exercisesData.length; i++){
        addEvent(responseList[i].date, exercisesData[i]);
      }
    });
    
  }
  
  void addEvent(DateTime date,Widget widget)
  {
    DateTime first = new DateTime(date.year, date.month, date.day);
    if(!events.containsKey(first))
    {
      events[first] = [widget];
    }
    else{
      events[first].add(widget);
    }
  }

  loadModel() async {
    String res;
        res = await Tflite.loadModel(
            model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
            numThreads: 4
            );
  }


  onSelect() {

    loadModel();
    //DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
    //Navigator.push(context, MaterialPageRoute(builder: (context) => CameraPage(userExercisesToday[exerciseToMakeIx],nextExercise,widget.visitedWorkout)));
    
  }


  @override
  void dispose() {
    animationController.dispose();
    calendarController.dispose();
    super.dispose();
  }

  List<History> findHistories(ExerciseDetails userExercise, DateTime first, DateTime last)
    {
      var startingDate = widget.visitedWorkout.startingDate.millisecondsSinceEpoch > first.millisecondsSinceEpoch ? widget.visitedWorkout.startingDate : first;
      var endingDate = widget.visitedWorkout.endingDate.millisecondsSinceEpoch > last.millisecondsSinceEpoch ? last : widget.visitedWorkout.endingDate;
     

      List<History> recurrentDates = [];
      for (int i = 0; i <userExercise.history.length; i++){
        
        var history = userExercise.history[i];
        if(history.creationDate.isAfter(startingDate.subtract(startingDate.timeZoneOffset)) && history.creationDate.isBefore(endingDate.toUtc())){
          recurrentDates.add(history);
        }
      }
      return recurrentDates; 

    }

  List<DateTime> findRepetitions(ExerciseDetails userExercise, DateTime first, DateTime last)
    {

      var startingDate = widget.visitedWorkout.startingDate.millisecondsSinceEpoch > first.millisecondsSinceEpoch ? widget.visitedWorkout.startingDate : first;
      var endingDate = widget.visitedWorkout.endingDate.millisecondsSinceEpoch > last.millisecondsSinceEpoch ? last : widget.visitedWorkout.endingDate;
      var currentDate = startingDate;

      List<DateTime> recurrentDates = [];
      while (currentDate.millisecondsSinceEpoch <= endingDate.millisecondsSinceEpoch) 
      {

          if(userExercise.recurrentDays.contains(currentDate.weekday-1))
          {
            recurrentDates.add(currentDate); 
          }
          currentDate = currentDate.add(Duration(days: 1)); 
      }
      return recurrentDates; 
    }


  Future<http.Response> getExercises()
  async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var headers = {
              'Content-type': 'application/json',
              'Accept': 'application/json',
              'authorization' : prefs.getString("token")
            };
    var url = Constants.webPath + "workouts/" + widget.visitedWorkout.id+ "/exerciseSets";
    //-by-date?startDate=$dateFirst&endDate=$dateLast
    return http.get(url, headers: headers);
  }

  void getExerciseData(DateTime first, DateTime last) async
  {
    responseList.clear();
    var getData = (await getExercises()).body;

    var exercisesRaw = jsonDecode(getData) as List;
    userExercises.clear();
    userExercisesToday.clear();
    for(int i = 0; i < exercisesRaw.length; i++)
    {
      userExercises.add(ExerciseDetails.fromJson(exercisesRaw[i]));
    } 
    for(int i = 0; i < userExercises.length; i++)
    {
      DateTime todayFirst = new DateTime(first.year, first.month, first.day);
      DateTime todayLast =  new DateTime(last.year, last.month, last.day,23,59,59);
      var dates = findRepetitions(userExercises[i], todayFirst, todayLast);
      for(int j = 0; j < dates.length; j++)
      {
        var curExercise = userExercises[i].exercise;
        var exerciseDetails = userExercises[i];
        print("setcount: ${exerciseDetails.setCount}");

        if(isSameDay(DateTime.now(), dates[j])){
          userExercisesToday.add(userExercises[i]);
        }

        responseList.add(ClientExercise(exerciseDetails, dates[j]));
      }
    }

    

    List<Widget> listItems = [];
    int index = 0;
    responseList.forEach((post) {
      //bool disabled = index < exerciseToMakeIx && isSameDay(post.date,DateTime.now());
      bool disabled = false;
      listItems.add(
        exerciseItem(post,disabled)
      );
      index++;
    });
    setState(() {
      exercisesData = listItems;
    });
    addCurrentWindowEvents();
    if(selectedDate.compareTo(first) >= 0 && selectedDate.compareTo(last) <=0 )
      selectedEvents = events[selectedDate];
  }

  Widget exerciseItem(ClientExercise post, bool disabled){
    return Container(
          height: 150,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.0)), color: !disabled ? Colors.white : Colors.grey.shade200, boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
          ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Image.network(post.exerciseDetails.exercise.imageUrl,
                  errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace){
                    return Image.asset(
                    "assets/logo.png",
                    height: double.infinity
                    );
                },),
                SizedBox(width:4),
                Expanded(child: 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        post.exerciseDetails.exercise.name,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "${post.exerciseDetails.setCount} Sets \n${post.exerciseDetails.repeat} Repeats",
                        style: const TextStyle(fontSize: 23, color: Colors.black, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.fade,
                      ),
                      disabled ? Text(
                        "Done",
                        style: const TextStyle(fontSize: 25, color: Colors.lightGreen, fontWeight: FontWeight.bold),
                      ) : SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                )
                
                
              ],
            ),
          ));
  }

  bool canStartTheProgram() {
    return selectedEvents != null && selectedEvents.length > 0 && isSameDay(selectedDate, DateTime.now()) && userId == widget.visitedUser.userId;
  }

  bool isSameDay(DateTime date1, DateTime date2){
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  bool isDayBefore(DateTime date1, DateTime date2)
  {
    return date1.year < date2.year || (date1.year == date2.year && date1.month < date2.month) || (date1.year == date2.year && date1.month == date2.month && date1.day < date2.day);
  }

  void selectDay(DateTime date, List<dynamic> events){
    selectedDate = date;
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
              widget.isEventListActive ? buildEventList() : SizedBox(height:1),
              
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
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarController: calendarController,
      initialCalendarFormat: widget.calendarFormat,
      availableCalendarFormats: {
        widget.calendarFormat : ''
      },
      onVisibleDaysChanged: (DateTime first, DateTime last, CalendarFormat format)
      {
        setState(() {
            startingEndingDates[0] = first;
          startingEndingDates[1] = last;
          if(widget.visitedWorkout != null)
            getExerciseData(first, last);
          
        });
        
      },
      events: events,
      onDaySelected: (date, events,holidays) {
        
        selectDay(date,events);
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
    if(selectedEvents == null || selectedEvents.length == 0) return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>
        [
          Text(
          'Day Off!',
          style: TextStyle().copyWith(
            color: Colors.black,
            fontSize: 36.0,
            )
          )
        ],
      ),
    );
    else
    {
      return  Expanded(
        child: ListView.builder(
            controller: controller,
              itemCount: selectedEvents.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                double scale = 1.0;
                return OpenContainer(
                closedBuilder: (_, openContainer){
                  return GestureDetector(
                    onTap : () {  
                        setState(() {
                          openContainer();
                          currentExercise = userExercises[index];
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
            }, openBuilder: (_, closeContainer)
            {
                return ExerciseCardPlan(CardType.exercise,currentExercise,closeContainer,canStartTheProgram(),widget.visitedWorkout);
            });
          }
        
        )
      );
    }
  }
}