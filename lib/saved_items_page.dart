import 'package:flutter/material.dart';
import 'package:intelliscribble/drawing_board.dart';
import 'package:intelliscribble/saved_whiteboard.dart';

class SavedItemsPage extends StatelessWidget {
  final List<SavedWhiteboard> savedWhiteboards;

  SavedItemsPage({required this.savedWhiteboards});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Whiteboards'),
      ),
      body: ListView.builder(
        itemCount: savedWhiteboards.length,
        itemBuilder: (context, index) {
          final savedWhiteboard = savedWhiteboards[index];
          return Card(
            child: ListTile(
              title: Text('Saved on: ${savedWhiteboard.timestamp}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DrawingBoard(
                      savedWhiteboard: savedWhiteboard,
                      savedWhiteboards: savedWhiteboards,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
