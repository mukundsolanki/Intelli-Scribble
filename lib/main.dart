import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/rendering.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'supabase_credentials.dart';
import 'saved_items_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseCredentials.url,
    anonKey: SupabaseCredentials.anonKey,
  );

  runApp(DrawingBoardApp());
}

class DrawingBoardApp extends StatefulWidget {
  @override
  _DrawingBoardAppState createState() => _DrawingBoardAppState();
}

class _DrawingBoardAppState extends State<DrawingBoardApp> {
  int _selectedIndex = 0;
  final List<SavedWhiteboard> savedWhiteboards = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _selectedIndex == 0
            ? DrawingBoard(savedWhiteboards: savedWhiteboards)
            : SavedItemsPage(savedWhiteboards: savedWhiteboards),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.draw),
              label: 'Draw',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              label: 'Saved Items',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class DrawingBoard extends StatefulWidget {
  final SavedWhiteboard? savedWhiteboard;
  final List<SavedWhiteboard> savedWhiteboards;

  DrawingBoard({this.savedWhiteboard, required this.savedWhiteboards});

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

  @override
  void initState() {
    super.initState();
    if (widget.savedWhiteboard != null) {
      strokes = List.from(widget.savedWhiteboard!.strokes);
      strokeColors = List.from(widget.savedWhiteboard!.strokeColors);
      strokeWidths = List.from(widget.savedWhiteboard!.strokeWidths);
      responses = List.from(widget.savedWhiteboard!.responses);
    }
  }

  void _onColorSelected(Color color) {
    setState(() {
      currentColor = color;
    });
  }

  Future<void> _sendDrawingToServer() async {
    final supabase = Supabase.instance.client;

    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();

      // Create a new image with white background
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..color = Colors.white;

      canvas.drawRect(
          Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble()),
          paint);
      canvas.drawImage(image, Offset.zero, Paint());

      final newImage =
          await recorder.endRecording().toImage(image.width, image.height);

      ByteData? byteData =
          await newImage.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final uuid = Uuid();
      final imageId = uuid.v4();
      final fileName = '$imageId.png';

      const bucketName = 'drawings';

      await supabase.storage.from(bucketName).uploadBinary(
            fileName,
            pngBytes,
            fileOptions: FileOptions(contentType: 'image/png'),
          );

      final imageUrl = supabase.storage.from(bucketName).getPublicUrl(fileName);

      var response = await http.post(
        Uri.parse('http://192.168.29.192:5000/process_image'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'image_id': imageId,
          'image_url': imageUrl,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          responses.add({
            'text': jsonResponse['analysis'] ?? "No response received",
            'position': Offset(100, 100 + responses.length * 50),
          });
        });
        print('Drawing processed successfully!');
      } else {
        print(
            'Failed to process the drawing. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error capturing, uploading, or processing the drawing: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process drawing. Please try again.')),
      );
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

  void _saveWhiteboard() {
    final savedWhiteboard = SavedWhiteboard(
      strokes: List.from(strokes),
      strokeColors: List.from(strokeColors),
      strokeWidths: List.from(strokeWidths),
      responses: List.from(responses),
      timestamp: DateTime.now(),
    );

    setState(() {
      widget.savedWhiteboards.add(savedWhiteboard);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Whiteboard saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drawing Board'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveWhiteboard,
          ),
        ],
      ),
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
                    value: Colors.purple,
                    child: Container(
                      width: 30,
                      height: 30,
                      color: Colors.purple,
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
                ],
              ).then((color) {
                if (color != null) {
                  _onColorSelected(color);
                }
              });
            },
            child: Icon(Icons.color_lens),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _clearCanvas,
            child: Icon(Icons.clear),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _undoLastStroke,
            child: Icon(Icons.undo),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                showSlider = !showSlider;
              });
            },
            child: Icon(Icons.brush),
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
      final stroke = strokes[i];
      final color = strokeColors[i];
      final strokeWidth = strokeWidths[i];
      final paint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      for (int j = 0; j < stroke.length - 1; j++) {
        if (stroke[j] != Offset(-1, -1) && stroke[j + 1] != Offset(-1, -1)) {
          canvas.drawLine(stroke[j], stroke[j + 1], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SavedWhiteboard {
  final List<List<Offset>> strokes;
  final List<Color> strokeColors;
  final List<double> strokeWidths;
  final List<Map<String, dynamic>> responses;
  final DateTime timestamp;

  SavedWhiteboard({
    required this.strokes,
    required this.strokeColors,
    required this.strokeWidths,
    required this.responses,
    required this.timestamp,
  });
}
