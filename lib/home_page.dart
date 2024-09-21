import 'package:flutter/material.dart';
import 'drawing_board.dart';
import 'saved_items_page.dart';
import 'saved_whiteboard.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<SavedWhiteboard> savedWhiteboards = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
