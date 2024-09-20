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
  List<double> strokeWidths = [];
  List<Offset>? currentStroke;
  Color currentColor = Colors.black;
  double currentStrokeWidth = 5.0;

  GlobalKey _globalKey = GlobalKey();
  List<Map<String, dynamic>> responses = [];

  bool showSlider = false;

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
        final responseData = await http.Response.fromStream(response);
        final jsonResponse = json.decode(responseData.body);
        setState(() {
          responses.add({
            'text': jsonResponse['analysis'] ?? "No response received",
            'position': Offset(100, 100 + responses.length * 50),
          });
        });
        print('Drawing sent successfully!');
      } else {
        print('Failed to send the drawing.');
      }
    } catch (e) {
      print('Error capturing or sending the drawing: $e');
    }
  }

  void _removeResponse(int index) {
    setState(() {
      responses.removeAt(index);
    });
  }

  void _clearCanvas() {
    setState(() {
      strokes.clear();
      strokeColors.clear();
      strokeWidths.clear();
    });
  }

  void _undoLastStroke() {
    setState(() {
      if (strokes.isNotEmpty) {
        strokes.removeLast();
        strokeColors.removeLast();
        strokeWidths.removeLast();
      }
    });
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
                    strokeWidths.add(currentStrokeWidth);
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
                painter: DrawingPainter(strokes, strokeColors, strokeWidths),
                size: Size.infinite,
              ),
            ),
          ),
          for (int i = 0; i < responses.length; i++)
            Positioned(
              left: responses[i]['position'].dx,
              top: responses[i]['position'].dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    responses[i]['position'] += details.delta;
                  });
                },
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.0),
                      color: Colors.blueAccent.withOpacity(0.7),
                      child: Text(
                        responses[i]['text'],
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => _removeResponse(i),
                        child: Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (showSlider)
            Positioned(
              bottom: 120,
              right: 20,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(8),
                  width: 200,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          'Stroke Width: ${currentStrokeWidth.toStringAsFixed(1)}'),
                      Slider(
                        value: currentStrokeWidth,
                        min: 1,
                        max: 20,
                        onChanged: (value) {
                          setState(() {
                            currentStrokeWidth = value;
                          });
                        },
                      ),
                    ],
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
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _clearCanvas,
            backgroundColor: Colors.red,
            child: Icon(Icons.clear),
          ),
          SizedBox(height: 16),
          // Undo Button
          FloatingActionButton(
            onPressed: _undoLastStroke,
            backgroundColor: Colors.orange,
            child: Icon(Icons.undo),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                showSlider = !showSlider;
              });
            },
            backgroundColor: Colors.purple,
            child: Icon(showSlider ? Icons.close : Icons.brush),
          ),
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Color> strokeColors;
  final List<double> strokeWidths;

  DrawingPainter(this.strokes, this.strokeColors, this.strokeWidths);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < strokes.length; i++) {
      Paint paint = Paint()
        ..color = strokeColors[i]
        ..strokeWidth = strokeWidths[i]
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
