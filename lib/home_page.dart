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

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: isMobile
          ? _getPage(_selectedIndex)
          : Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onDestinationSelected,
                  groupAlignment: 0.0,
                  labelType: NavigationRailLabelType.all,
                  destinations: const <NavigationRailDestination>[
                    NavigationRailDestination(
                      icon: Icon(Icons.draw),
                      label: Text('Draw'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.folder),
                      label: Text('Saved Items'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.account_circle),
                      label: Text('Account'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: _getPage(_selectedIndex),
                ),
              ],
            ),
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: const <NavigationDestination>[
                NavigationDestination(
                  icon: Icon(Icons.draw),
                  label: 'Draw',
                ),
                NavigationDestination(
                  icon: Icon(Icons.folder),
                  label: 'Saved Items',
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_circle),
                  label: 'Account',
                ),
              ],
            )
          : null,
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
