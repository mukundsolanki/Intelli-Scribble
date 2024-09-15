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
  List<List<Offset>> strokes = [];
  List<Color> strokeColors = [];
  List<Offset>? currentStroke;
  Color currentColor = Colors.black; // Default color is black

  void _onColorSelected(Color color) {
    setState(() {
      currentColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Drawing Board')),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            if (currentStroke == null) {
              // Start a new stroke
              currentStroke = [];
              strokes.add(currentStroke!);
              strokeColors.add(currentColor);
            }
            currentStroke!.add(details.localPosition);
          });
        },
        onPanEnd: (details) {
          setState(() {
            if (currentStroke != null) {
              currentStroke!.add(Offset(-1, -1)); // End of stroke
              currentStroke = null; // Ready for new stroke
            }
          });
        },
        child: CustomPaint(
          painter: DrawingPainter(strokes, strokeColors),
          size: Size.infinite,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              MediaQuery.of(context).size.width - 100,
              MediaQuery.of(context).size.height - 100,
              0,
              0,
            ),
            items: [
              PopupMenuItem<Color>(
                value: Colors.red,
                child: Container(
                  width: 30,
                  height: 30,
                  color: Colors.red,
                ),
              ),
              PopupMenuItem<Color>(
                value: Colors.green,
                child: Container(
                  width: 30,
                  height: 30,
                  color: Colors.green,
                ),
              ),
              PopupMenuItem<Color>(
                value: Colors.blue,
                child: Container(
                  width: 30,
                  height: 30,
                  color: Colors.blue,
                ),
              ),
              PopupMenuItem<Color>(
                value: Colors.yellow,
                child: Container(
                  width: 30,
                  height: 30,
                  color: Colors.yellow,
                ),
              ),
              PopupMenuItem<Color>(
                value: Colors.purple,
                child: Container(
                  width: 30,
                  height: 30,
                  color: Colors.purple,
                ),
              ),
            ],
          ).then((selectedColor) {
            if (selectedColor != null) {
              _onColorSelected(selectedColor);
            }
          });
        },
        child: Icon(Icons.color_lens),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Color> strokeColors;

  DrawingPainter(this.strokes, this.strokeColors);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < strokes.length; i++) {
      Paint paint = Paint()
        ..color = strokeColors[i]
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round;

      List<Offset> stroke = strokes[i];
      for (int j = 0; j < stroke.length - 1; j++) {
        if (stroke[j] != const Offset(-1, -1) && stroke[j + 1] != const Offset(-1, -1)) {
          canvas.drawLine(stroke[j], stroke[j + 1], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
