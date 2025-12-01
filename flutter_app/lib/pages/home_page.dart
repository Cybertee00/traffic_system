import 'package:flutter/material.dart';
import 'dart:async';
import 'dashboard_frontend.dart';
import 'parallel_parking_frontend.dart';
import 'alleyDocking_frontend.dart';
import 'hillStart_frontend.dart';
import 'turnInTheRoad_frontend.dart';
import 'leftTurn_frontend.dart';
import 'pretrip_frontend.dart';
import 'straight_reverse_frontend.dart';
import 'road_trip_frontend.dart';
import 'dashboard_backend.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late Timer _testStateTimer;

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

  @override
  void initState() {
    super.initState();
    // Start timer to check test state every second
    _testStateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Force rebuild to update navigation state
        });
      }
    });
  }

  @override
  void dispose() {
    _testStateTimer.cancel();
    super.dispose();
  }

  String? _getPageName(int index) {
    const pageNames = {
      0: 'Dashboard',
      1: 'Pre-Trip',
      2: 'Parallel Parking',
      3: 'Alley Docking',
      4: 'Hill Start',
      5: '3 Point Turn',
      6: 'Left Turn',
      7: 'Straight Reverse',
      8: 'Road Trip',
    };
    return pageNames[index];
  }

  void _onItemTapped(int index) {
    // Check if the page should be disabled based on test state and license code
    final disableReason = _getPageDisableReason(index);
    if (disableReason != null) {
      // Show a snackbar with the appropriate message
      final pageName = _getPageName(index) ?? 'this page';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(disableReason.replaceAll('[page]', pageName)),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.orange,
        ),
      );
      return; // Don't allow navigation to disabled pages
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  String? _getPageDisableReason(int index) {
    // Dashboard (index 0) is always enabled
    if (index == 0) return null;
    
    // If test has ended, disable all test pages
    if (isTestEnded) {
      return 'The test has ended. Please start a new test before accessing [page].';
    }
    
    // Field test pages (indices 1-7): Pretrip, Parallel Parking, Alley Docking, Hill Start, 3 Point Turn, Left Turn, Straight Reverse
    if (index >= 1 && index <= 7) {
      // If field test hasn't started, disable field test pages
      if (!isFieldRunning && fieldTestDuration == Duration.zero) {
        return 'Please start the field test before accessing [page].';
      }
      // If road test has started, disable field test pages
      if (isRoadRunning) {
        return 'Road test is in progress. You cannot access field test pages like [page] during a road test.';
      }
    }
    
    // Road test page (index 8): Road Trip
    if (index == 8) {
      // If field test hasn't been completed, disable road test page
      if (fieldTestDuration == Duration.zero) {
        return 'Please complete the field test before accessing [page].';
      }
      // If road test hasn't started, disable road test page
      if (!isRoadRunning && roadTestDuration == Duration.zero) {
        return 'Please start the road test before accessing [page].';
      }
    }
    
    // Get the current learner's license code
    String? currentLicenseCode;
    try {
      // Access the selected learner from the dashboard
      final dashboardState = context.findAncestorStateOfType<Page1State>();
      if (dashboardState != null && dashboardState.selectedLearner != null) {
        currentLicenseCode = dashboardState.selectedLearner!.code;
        print('Current license code: $currentLicenseCode for page index: $index');
      }
    } catch (e) {
      print('Error getting license code: $e');
    }
    
    // Check if page is enabled for current learner's license code (check this LAST, as it's less common)
    bool isEnabledForLicense = isPageEnabledForCurrentLearner(index, currentLicenseCode);
    print('Page $index enabled for license $currentLicenseCode: $isEnabledForLicense');
    
    if (!isEnabledForLicense) {
      print('Page $index is DISABLED due to license code restrictions');
      return 'This page ([page]) is not available for the current learner\'s license code.';
    }
    
    return null; // Page is enabled
  }
  
  bool _isPageDisabled(int index) {
    return _getPageDisableReason(index) != null;
  }

  List<BottomNavigationBarItem> _buildNavigationItems() {
    // Get the current learner's license code
    String? currentLicenseCode;
    try {
      final dashboardState = context.findAncestorStateOfType<Page1State>();
      if (dashboardState != null && dashboardState.selectedLearner != null) {
        currentLicenseCode = dashboardState.selectedLearner!.code;
      }
    } catch (e) {
      // If we can't get the license code, continue
    }
    
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard, color: Colors.orange), 
        label: 'Dashboard'
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.checklist, 
          color: _isPageDisabled(1) ? Colors.grey : 
                 (isPageEnabledForCurrentLearner(1, currentLicenseCode) ? null : Colors.red.withOpacity(0.5))
        ), 
        label: 'Pre-Trip'
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.local_parking, 
          color: _isPageDisabled(2) ? Colors.grey : 
                 (isPageEnabledForCurrentLearner(2, currentLicenseCode) ? null : Colors.red.withOpacity(0.5))
        ), 
        label: 'Parallel Parking'
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.directions_car_filled, 
          color: _isPageDisabled(3) ? Colors.grey : 
                 (isPageEnabledForCurrentLearner(3, currentLicenseCode) ? null : Colors.red.withOpacity(0.5))
        ), 
        label: 'Alley Docking'
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.trending_up, 
          color: _isPageDisabled(4) ? Colors.grey : 
                 (isPageEnabledForCurrentLearner(4, currentLicenseCode) ? null : Colors.red.withOpacity(0.5))
        ), 
        label: 'Hill Start'
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.rotate_right, 
          color: _isPageDisabled(5) ? Colors.grey : 
                 (isPageEnabledForCurrentLearner(5, currentLicenseCode) ? null : Colors.red.withOpacity(0.5))
        ), 
        label: '3 Point turn'
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.turn_left, 
          color: _isPageDisabled(6) ? Colors.grey : 
                 (isPageEnabledForCurrentLearner(6, currentLicenseCode) ? null : Colors.red.withOpacity(0.5))
        ), 
        label: 'Left Turn'
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.keyboard_backspace, 
          color: _isPageDisabled(7) ? Colors.grey : 
                 (isPageEnabledForCurrentLearner(7, currentLicenseCode) ? null : Colors.red.withOpacity(0.5))
        ), 
        label: 'Straight Reverse'
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.route, 
          color: _isPageDisabled(8) ? Colors.grey : 
                 (isPageEnabledForCurrentLearner(8, currentLicenseCode) ? null : Colors.red.withOpacity(0.5))
        ), 
        label: 'Road Trip'
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _buildNavigationItems(),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 11,
      ),
    );
  }
}
