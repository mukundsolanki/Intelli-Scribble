import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/rendering.dart';

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
  Color currentColor = Colors.black;

  GlobalKey _globalKey = GlobalKey();
  String serverResponse = ""; // Variable to hold the server response
  Offset textPosition =
      Offset(100, 100); // Initial position of the draggable text

  void _onColorSelected(Color color) {
    setState(() {
      currentColor = color;
    });
  }

  Future<void> _sendDrawingToServer() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();

      // Create a new image with white background
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..color = Colors.white;

      canvas.drawRect(
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          paint);
      canvas.drawImage(image, Offset.zero, Paint());

      final newImage =
          await recorder.endRecording().toImage(image.width, image.height);

      ByteData? byteData =
          await newImage.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.29.192:5000/upload'),
      );
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        pngBytes,
        filename: 'drawing.png',
      ));

      var response = await request.send();
      if (response.statusCode == 200) {
        // Parse the response and extract the analysis result
        final responseData = await http.Response.fromStream(response);
        final jsonResponse = json.decode(responseData.body);
        setState(() {
          serverResponse = jsonResponse['analysis'] ?? "No response received";
        });
        print('Drawing sent successfully!');
      } else {
        print('Failed to send the drawing.');
      }
    } catch (e) {
      print('Error capturing or sending the drawing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Drawing Board')),
      body: Stack(
        children: [
          RepaintBoundary(
            key: _globalKey,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  if (currentStroke == null) {
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
                    currentStroke!.add(Offset(-1, -1));
                    currentStroke = null;
                  }
                });
              },
              child: CustomPaint(
                painter: DrawingPainter(strokes, strokeColors),
                size: Size.infinite,
              ),
            ),
          ),
          // Draggable text widget to display server response
          if (serverResponse.isNotEmpty)
            Positioned(
              left: textPosition.dx,
              top: textPosition.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    textPosition += details.delta;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  color: Colors.blueAccent.withOpacity(0.7),
                  child: Text(
                    serverResponse,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _sendDrawingToServer,
            child: Icon(Icons.generating_tokens),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
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
        ],
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
        if (stroke[j] != const Offset(-1, -1) &&
            stroke[j + 1] != const Offset(-1, -1)) {
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
