import 'package:flutter/material.dart';
import 'drawing_board.dart';
import 'saved_items_page.dart';
import 'saved_whiteboard.dart';
import 'account_page.dart';

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
      body: _getPage(_selectedIndex),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return DrawingBoard(savedWhiteboards: savedWhiteboards);
      case 1:
        return SavedItemsPage(savedWhiteboards: savedWhiteboards);
      case 2:
        return AccountPage(); 
      default:
        return DrawingBoard(savedWhiteboards: savedWhiteboards);
    }
  }
}
