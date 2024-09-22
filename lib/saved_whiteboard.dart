import 'dart:ui';

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
