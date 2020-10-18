

import 'package:flutter/material.dart';

class Line extends StatefulWidget {
  List<dynamic> points = new List();
  

  Line();
  
  @override
  _LineState createState() => _LineState(this.points);
}
class _LineState extends State<Line>
    with SingleTickerProviderStateMixin {

  List<dynamic> points = new List();

  _LineState(points);
  AnimationController _controller;
@override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync : this);
  }
@override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
@override
  Widget build(BuildContext context) {
    print("1111111111111111111111sss");
    return CustomPaint(
      size: Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height),
      painter: DrawLine(this.points),
    );
  }
}


class DrawLine extends CustomPainter 
{
  List<dynamic> points;
  DrawLine(this.points);
  @override
  void paint(Canvas canvas, Size size) {
    
    Paint line = new Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..strokeWidth = 30;
    print("ssssssssssssssssssssssssssssssss");
    for(var i = 0; i < points.length; i++)
    {
      print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa ${points[i][0]}");
      
      canvas.drawLine(Offset(points[i][0], points[i][1]), Offset(points[i+1][0], points[i+1][1]), line);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    throw true;
  }
}