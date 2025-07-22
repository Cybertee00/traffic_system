import 'package:flutter/material.dart';
import 'checklist_data.dart';
import 'audio_backend.dart';

Duration fieldTestDuration = Duration.zero;
Duration roadTestDuration = Duration.zero;
Duration totalTestDuration = Duration.zero;

Stopwatch fieldTimer = Stopwatch();
Stopwatch roadTimer = Stopwatch();

bool isFieldRunning = false;
bool isRoadRunning = false;
bool isTestEnded = false; // New state to track if test has been ended

String actionLabel = "Start Field Test";
String endTestButtonLabel = "End Test"; // New label for the combined button

// Pass mark variables - can be adjusted as needed
const double pretripPassMark = 70.0;
const double parallelParkingPassMark = 70.0;
const double alleyDockingPassMark = 70.0;
const double hillStartPassMark = 70.0;
const double threePointTurnPassMark = 70.0;
const double leftTurnPassMark = 70.0;
const double straightReversePassMark = 70.0;
const double roadTripPassMark = 70.0;
const double overallPassMark = 70.0; // Overall pass criteria

// Test durations
const Duration fieldTestTotal = Duration(minutes: 40);
const Duration roadTestTotal = Duration(minutes: 60);

// Calculate progress as remaining time percentage
double getFieldProgress() {
  if (fieldTestDuration > fieldTestTotal) return 0;
  return 1 - (fieldTestDuration.inSeconds / fieldTestTotal.inSeconds);
}

double getRoadProgress() {
  if (roadTestDuration > roadTestTotal) return 0;
  return 1 - (roadTestDuration.inSeconds / roadTestTotal.inSeconds);
}

double getTotalProgress() {
  final totalAllowed = fieldTestTotal + roadTestTotal;
  final totalUsed = fieldTestDuration + roadTestDuration;
  if (totalUsed > totalAllowed) return 0;
  return 1 - (totalUsed.inSeconds / totalAllowed.inSeconds);
}

// Calculate section percentages and overall result
Map<String, double> getSectionPercentages(dynamic page2Backend, dynamic page3Backend, dynamic hillStartBackend) {
  return {
    'Pretrip': _calculateSectionPercentage(['PRETRIP INTERIOR', 'PRETRIP EXTERIOR'], page2Backend),
    'Parallel Parking': _calculateSectionPercentage(['PARALLEL PARKING (Left)', 'PARALLEL PARKING (Right)'], page2Backend),
    'Alley Docking': _calculateSectionPercentage(['ALLEY DOCKING (Left)', 'ALLEY DOCKING (Right)'], page3Backend),
    'Hill Start': _calculateSectionPercentage(['INCLINE START'], hillStartBackend),
    '3 Point Turn': _calculateSectionPercentage(['TURN IN THE ROAD'], page2Backend),
    'Left Turn': _calculateSectionPercentage(['LEFT TURN'], page2Backend),
    'Straight Reverse': _calculateSectionPercentage(['STRAIGHT REVERSING'], page2Backend),
    'Road Trip': _calculateSectionPercentage([
      'STARTING','MOVING OFF','STEERING','CLUTCH','GEAR CHANGING','SIGNALLING','LANE CHANGING','OVERTAKING','INTERSECTION VEHICLE ENTRY/EXIT','SPEED CONTROL','STOPPING','FREEWAYS ENTRY/EXIT',
    ], page2Backend),
  };
}

// Helper to get max penalty for a section
double getMaxPenaltyForSection(String sectionTitle) {
  final section = testSections.firstWhere(
    (s) => s.title == sectionTitle,
    orElse: () => TestSection(title: sectionTitle, checks: []),
  );
  double maxPenalty = 0;
  for (var check in section.checks) {
    maxPenalty += check.penaltyValue;
  }
  return maxPenalty;
}

double getCurrentPenaltyForSection(String sectionTitle, dynamic backend) {
  final section = testSections.firstWhere(
    (s) => s.title == sectionTitle,
    orElse: () => TestSection(title: sectionTitle, checks: []),
  );
  double total = 0;
  for (var check in section.checks) {
    final key = '${section.title}-${check.description}';
    final count = backend.getCheckCount(key);
    total += check.penaltyValue * count;
  }
  return total;
}

double _calculateSectionPercentage(List<String> sectionTitles, dynamic backend) {
  double maxPenalty = 0;
  double currentPenalty = 0;
  
  for (var sectionTitle in sectionTitles) {
    maxPenalty += getMaxPenaltyForSection(sectionTitle);
    currentPenalty += getCurrentPenaltyForSection(sectionTitle, backend);
  }
  
  if (maxPenalty == 0) return 100.0;
  return ((1 - (currentPenalty / maxPenalty)) * 100).clamp(0.0, 100.0);
}

double getOverallPercentage(dynamic page2Backend, dynamic page3Backend, dynamic hillStartBackend) {
  final percentages = getSectionPercentages(page2Backend, page3Backend, hillStartBackend);
  double total = 0;
  percentages.forEach((key, value) {
    total += value;
  });
  return total / percentages.length;
}

bool isOverallPass(dynamic page2Backend, dynamic page3Backend, dynamic hillStartBackend) {
  return getOverallPercentage(page2Backend, page3Backend, hillStartBackend) >= overallPassMark;
}

Map<String, bool> getSectionPassResults(dynamic page2Backend, dynamic page3Backend, dynamic hillStartBackend) {
  final percentages = getSectionPercentages(page2Backend, page3Backend, hillStartBackend);
  final passMarks = {
    'Pretrip': pretripPassMark,
    'Parallel Parking': parallelParkingPassMark,
    'Alley Docking': alleyDockingPassMark,
    'Hill Start': hillStartPassMark,
    '3 Point Turn': threePointTurnPassMark,
    'Left Turn': leftTurnPassMark,
    'Straight Reverse': straightReversePassMark,
    'Road Trip': roadTripPassMark,
  };
  
  Map<String, bool> results = {};
  percentages.forEach((section, percentage) {
    results[section] = percentage >= passMarks[section]!;
  });
  
  return results;
}


void handleTestButton(VoidCallback updateState, {AudioBackend? audioBackend, String? learnerId}) {
  if (!isFieldRunning && !isRoadRunning && fieldTestDuration == Duration.zero) {
    // Start field test
    fieldTimer.start();
    isFieldRunning = true;
    actionLabel = "Stop Field Test";
    
    // Start audio recording if available
    if (audioBackend != null && learnerId != null) {
      audioBackend.startRecording(learnerId);
    }
  } else if (isFieldRunning) {
    // Stop field test
    fieldTimer.stop();
    fieldTestDuration = fieldTimer.elapsed;
    isFieldRunning = false;
    actionLabel = "Start Road Test";
  } else if (!isRoadRunning && roadTestDuration == Duration.zero) {
    // Start road test
    roadTimer.start();
    isRoadRunning = true;
    actionLabel = "Stop Road Test";
  } else if (isRoadRunning) {
    // Stop road test
    roadTimer.stop();
    roadTestDuration = roadTimer.elapsed;
    isRoadRunning = false;
    actionLabel = "Test Complete";
  }

  // Always update total
  totalTestDuration = fieldTestDuration + roadTestDuration;
  updateState();
}

// New function to handle the combined end test/preview report button
void handleEndTestButton(VoidCallback updateState, {AudioBackend? audioBackend}) {
  if (!isTestEnded) {
    // End the test - stop all timers
    endAllTests(updateState);
    
    // Stop audio recording if available
    if (audioBackend != null) {
      audioBackend.stopRecording();
    }
    
    isTestEnded = true;
    endTestButtonLabel = "Preview Report";
  }
  // If test is already ended, this button will navigate to preview report
  // (handled in the frontend)
  updateState();
}

// New function to reset everything for a new test
void resetForNewTest(VoidCallback updateState, {
  dynamic page2Backend,
  dynamic page3Backend,
  dynamic hillStartBackend,
  dynamic carDetailsBackend,
}) {
  // Reset all timers and state
  fieldTimer.reset();
  roadTimer.reset();
  fieldTestDuration = Duration.zero;
  roadTestDuration = Duration.zero;
  totalTestDuration = Duration.zero;
  isFieldRunning = false;
  isRoadRunning = false;
  isTestEnded = false;
  actionLabel = "Start Field Test";
  endTestButtonLabel = "End Test";
  
  // Reset all backend data
  if (page2Backend != null) {
    page2Backend.resetChecks();
  }
  if (page3Backend != null) {
    page3Backend.resetChecks();
  }
  if (hillStartBackend != null) {
    hillStartBackend.resetChecks();
  }
  if (carDetailsBackend != null) {
    carDetailsBackend.resetCarDetails();
  }
  
  updateState();
}

void endAllTests(VoidCallback updateState) {
  fieldTimer.stop();
  roadTimer.stop();
  isFieldRunning = false;
  isRoadRunning = false;
  actionLabel = "Start New Test"; // Changed to indicate new test option

  updateState(); // Trigger UI update
}

void updateDurations() {
  if (fieldTimer.isRunning) {
    fieldTestDuration = fieldTimer.elapsed;
  }
  if (roadTimer.isRunning) {
    roadTestDuration = roadTimer.elapsed;
  }
  totalTestDuration = fieldTestDuration + roadTestDuration;
}

void handleSubmit(BuildContext context) {
  //print("Field Time: $fieldTestDuration");
  //print("Road Test Time: $roadTestDuration");
  //print("Total Time: $totalTestDuration");

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Submitted")),
  );
}

class Learner {
  final String name;
  final String idNumber;
  final String code;
  final String gender;

  const Learner({
    required this.name,
    required this.idNumber,
    required this.code,
    required this.gender,
  });
}

// Sample list of learners
final List<Learner> learners = [
  Learner(name: 'John Doe', idNumber: '1234567890123', code: 'B1', gender: 'Male'),
  Learner(name: 'Jane Smith', idNumber: '9876543210987', code: 'C1', gender: 'Female'),
  Learner(name: 'Thabo Mokoena', idNumber: '8801234567890', code: 'EB', gender: 'Male'),
];

class Officer {
  final String name;
  final String infraNr;

  const Officer({
    required this.name,
    required this.infraNr,
  });
}

// Sample list of officers
final List<Officer> officers = [
  Officer(name: 'Officer Mokoena', infraNr: 'INF12345'),
  Officer(name: 'Officer Smith', infraNr: 'INF67890'),
  Officer(name: 'Officer Patel', infraNr: 'INF54321'),
];

// Labels for progress indicators
final List<String> progressLabels = [
  "Pre-Trip Inspection",
  "Parallel Parking",
  "Alley Docking",
  "Hill Start",
  "3 Point Turn",
  "Left Turn",
  "Straight Reverse",
  "Road Trip",
];

// Progress colors
final List<Color> progressColors = [
  Colors.red,
  Colors.red,
  Colors.red,
  Colors.red,
  Colors.red,
  Colors.red,
  Colors.red,
  Colors.red,
  Colors.red,
];

// Individual progress values
double progress1 = 0.2;
double progress2 = 0.5;
double progress3 = 0.3;
double progress4 = 0.9;
double progress5 = 0.7;
double progress6 = 0.6;
double progress7 = 0.4;
double progress8 = 0.8;
double progress9 = 0.1;

// Return list of progress values
List<double> getProgressValues() {
  return [
    progress1,
    progress2,
    progress3,
    progress4,
    progress5,
    progress6,
    progress7,
    progress8,
    progress9,
  ];
}

// ✅ This function must be defined at top level, outside a class
IconData getIconForIndex(int index) {
  const icons = [
    Icons.directions_car,
    Icons.timer,
    Icons.star,
    Icons.flag,
    Icons.verified,
    Icons.emoji_events,
    Icons.track_changes,
    Icons.school,
    Icons.traffic,
  ];
  return icons[index % icons.length];
}

// Optional (existing)
class TimerWidget extends StatelessWidget {
  final String label;
  final Duration time;
  const TimerWidget({super.key, required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    String formattedTime = "${time.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(time.inSeconds.remainder(60)).toString().padLeft(2, '0')}";

    return Column(
      children: [
        const Icon(Icons.timer, size: 32),
        const SizedBox(height: 4),
        Text(formattedTime),
        Text(label),
      ],
    );
  }
}


class ActionButton extends StatelessWidget {
  final String label;
  const ActionButton({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label button pressed')),
        );
      },
      child: Text(label),
    );
  }
}
