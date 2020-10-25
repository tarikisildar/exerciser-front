

import 'package:flutter/material.dart';



class DrawLine extends CustomPainter 
{
  List<double> points;
  DrawLine(this.points);
  @override
  void paint(Canvas canvas, Size size) {
    
    Paint line = new Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

      
      canvas.drawLine(Offset(points[0], points[1]), Offset(points[2], points[3]), line);

  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
