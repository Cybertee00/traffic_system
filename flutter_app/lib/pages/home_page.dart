import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dashboard_frontend.dart';
import 'parallel_parking_frontend.dart';
import 'alleyDocking_frontend.dart';
import 'hillStart_frontend.dart';
import 'turnInTheRoad_frontend.dart';
import 'leftTurn_frontend.dart';
import 'pretrip_frontend.dart';
import 'straight_reverse_frontend.dart';
import 'road_trip_frontend.dart';
import 'theme_backend.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages =  [
    Page1(),
    PretripInspectionPage(),
    ParallelParkingPage(),
    AlleyDockingPage(),
    HillStartPage(),
    TurnInTheRoadPage(),
    LeftTurnPage(),
    StraightReversePage(),
    RoadTripPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home, color: Colors.orange), label: 'Dashboard', ),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Pre-Trip'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Parallel Parking'),
    BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Alley Docking'),
    BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Hill Start'),
    BottomNavigationBarItem(icon: Icon(Icons.u_turn_right), label: '3 Point turn'),
    BottomNavigationBarItem(icon: Icon(Icons.turn_left), label: 'Left Turn'),
    BottomNavigationBarItem(icon: Icon(Icons.traffic_rounded), label: 'Straight Reverse'),
    BottomNavigationBarItem(icon: Icon(Icons.traffic_rounded), label: 'Road Trip'),
    //BottomNavigationBarItem(icon: Icon(Icons.traffic_rounded), label: 'Road Trip'),
  ];

  @override
  Widget build(BuildContext context) {
    final themeBackend = Provider.of<ThemeBackend>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMART Licence APP'),
        actions: [
          IconButton(
            icon: Icon(
              themeBackend.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeBackend.toggleTheme();
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
