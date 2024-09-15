import 'package:flutter/material.dart';

void main() => runApp(DrawingBoardApp());

class DrawingBoardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DrawingBoard(),
    );
  }
}

class DrawingBoard extends StatefulWidget {
  @override
  _DrawingBoardState createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  // List to store drawing points
  List<Offset> points = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Drawing Board')),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            // Add the exact position of the user's touch or mouse movement to the points list
            points.add(details.localPosition);
          });
        },
        onPanEnd: (details) {
          setState(() {
            points.add(Offset(-1, -1)); // Mark end of stroke with a sentinel value
          });
        },
        child: CustomPaint(
          painter: DrawingPainter(points),
          size: Size.infinite, // The drawing area is as large as the screen
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    // Loop through the points and draw
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != const Offset(-1, -1) && points[i + 1] != const Offset(-1, -1)) {
        // Draw a line between consecutive points if they're not end-of-stroke markers
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Redraw whenever new points are added
  }
}
