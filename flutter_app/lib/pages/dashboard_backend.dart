import 'package:flutter/material.dart';
import 'checklist_data.dart';
import 'audio_backend.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

Duration fieldTestDuration = Duration.zero;
Duration roadTestDuration = Duration.zero;
Duration totalTestDuration = Duration.zero;

Stopwatch fieldTimer = Stopwatch();
Stopwatch roadTimer = Stopwatch();

bool isFieldRunning = false;
bool isRoadRunning = false;
bool isTestEnded = false; // New state to track if test has been ended
bool isNewLearnerSelected = false; // Track if a new learner has been selected after test ended
bool isTestSessionActive = false; // Track if any test session is active (field or road)

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

// Global list to track completed learners
List<int> completedLearnerIds = [];

// Function to mark a learner as completed
void markLearnerAsCompleted(int learnerId) {
  if (!completedLearnerIds.contains(learnerId)) {
    completedLearnerIds.add(learnerId);
    print('Marked learner $learnerId as completed. Total completed: ${completedLearnerIds.length}');
  }
}

// Function to update test result in database
Future<bool> updateTestResultInDatabase(int learnerId, String result, {BuildContext? context}) async {
  try {
    // First, find the booking ID for this learner
    final today = DateTime.now();
    final dateString = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
    // Get all bookings for today to find the booking ID
    final allBookingsUrl = Uri.parse(context != null 
        ? ApiConfig.buildUrl(context, 'learner-test-bookings/')
        : ApiConfig.buildUrlLegacy('learner-test-bookings/'));
    final allBookingsResponse = await http.get(
      allBookingsUrl,
      headers: {'Content-Type': 'application/json'},
    );
    
    if (allBookingsResponse.statusCode == 200) {
      final List<dynamic> allBookingsData = jsonDecode(allBookingsResponse.body);
      
      // Find the booking for this learner on today's date
      final learnerBooking = allBookingsData.firstWhere(
        (booking) => booking['learner_id'] == learnerId && booking['test_date'] == dateString,
        orElse: () => null,
      );
      
      if (learnerBooking != null) {
        final bookingId = learnerBooking['booking_id'];
        
        // Update the result using the API endpoint
        final updateUrl = Uri.parse(context != null
            ? ApiConfig.buildUrl(context, 'learner-test-bookings/$bookingId/result')
            : ApiConfig.buildUrlLegacy('learner-test-bookings/$bookingId/result'));
        final updateResponse = await http.put(
          updateUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'result': result}),
        );
        
        if (updateResponse.statusCode == 200) {
          print('Successfully updated test result for learner $learnerId to: $result');
          return true;
        } else {
          print('Failed to update test result: ${updateResponse.statusCode} - ${updateResponse.body}');
          return false;
        }
      } else {
        print('No booking found for learner $learnerId on $dateString');
        return false;
      }
    } else {
      print('Failed to fetch bookings to find booking ID: ${allBookingsResponse.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error updating test result: $e');
    return false;
  }
}

// Function to check if a learner is completed
bool isLearnerCompleted(int learnerId) {
  return completedLearnerIds.contains(learnerId);
}

// Function to get enabled pages based on license code
List<int> getEnabledPagesForCode(String licenseCode) {
  // Remove "Code " prefix if present
  String code = licenseCode.replaceAll('Code ', '').replaceAll('code ', '');
  
  print('DEBUG: Processing license code: "$licenseCode" -> extracted code: "$code"');
  
  List<int> enabledPages;
  switch (code) {
    case '8':
      // Code 8: Pre-trip, Parallel Parking, Hill Start, 3 Point Turn, Left Turn, Road Trip
      enabledPages = [0, 1, 2, 4, 5, 6, 8]; // Dashboard, Pre-trip, Parallel, Hill Start, 3 Point Turn, Left Turn, Road Trip
      break;
    case '10':
      // Code 10: Hill Start, Straight Reverse, Alley Docking, Road Trip
      enabledPages = [0, 3, 4, 7, 8]; // Dashboard, Alley Docking, Hill Start, Straight Reverse, Road Trip
      break;
    case '14':
      // Code 14: All pages available
      enabledPages = [0, 1, 2, 3, 4, 5, 6, 7, 8]; // All pages
      break;
    default:
      // Default: All pages available
      enabledPages = [0, 1, 2, 3, 4, 5, 6, 7, 8];
      break;
  }
  
  print('DEBUG: License code $code -> Enabled pages: $enabledPages');
  return enabledPages;
}

// Function to check if a page is enabled for current learner
bool isPageEnabledForCurrentLearner(int pageIndex, String? licenseCode) {
  if (licenseCode == null) {
    print('DEBUG: No license code provided, allowing all pages');
    return true; // If no code, allow all pages
  }
  
  List<int> enabledPages = getEnabledPagesForCode(licenseCode);
  bool isEnabled = enabledPages.contains(pageIndex);
  
  print('DEBUG: Page $pageIndex for license $licenseCode - Enabled pages: $enabledPages - Is enabled: $isEnabled');
  
  return isEnabled;
}

// Function to reset completed learners list (for new day or admin purposes)
void resetCompletedLearners() {
  completedLearnerIds.clear();
  print('Reset completed learners list');
}

// Function to reset new learner selection state when test ends
void resetNewLearnerSelection() {
  isNewLearnerSelected = false;
}

// Function to mark that a new learner has been selected
void markNewLearnerSelected() {
  isNewLearnerSelected = true;
}

// Function to check if "Start New Test" button should be enabled
bool canStartNewTest() {
  return isTestEnded && isNewLearnerSelected;
}

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
Map<String, double> getSectionPercentages(
  dynamic page2Backend,
  dynamic page3Backend,
  dynamic hillStartBackend,
) {
  return {
    'Pretrip': _calculateSectionPercentage([
      'PRETRIP INTERIOR',
      'PRETRIP EXTERIOR',
    ], page2Backend),
    'Parallel Parking': _calculateSectionPercentage([
      'PARALLEL PARKING (Left)',
      'PARALLEL PARKING (Right)',
    ], page2Backend),
    'Alley Docking': _calculateSectionPercentage([
      'ALLEY DOCKING (Left)',
      'ALLEY DOCKING (Right)',
    ], page3Backend),
    'Hill Start': _calculateSectionPercentage([
      'INCLINE START',
    ], hillStartBackend),
    '3 Point Turn': _calculateSectionPercentage([
      'TURN IN THE ROAD',
    ], page2Backend),
    'Left Turn': _calculateSectionPercentage(['LEFT TURN'], page2Backend),
    'Straight Reverse': _calculateSectionPercentage([
      'STRAIGHT REVERSING',
    ], page2Backend),
    'Road Trip': _calculateSectionPercentage([
      'STARTING',
      'MOVING OFF',
      'STEERING',
      'CLUTCH',
      'GEAR CHANGING',
      'SIGNALLING',
      'LANE CHANGING',
      'OVERTAKING',
      'INTERSECTION VEHICLE ENTRY/EXIT',
      'SPEED CONTROL',
      'STOPPING',
      'FREEWAYS ENTRY/EXIT',
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

double _calculateSectionPercentage(
  List<String> sectionTitles,
  dynamic backend,
) {
  double maxPenalty = 0;
  double currentPenalty = 0;

  for (var sectionTitle in sectionTitles) {
    maxPenalty += getMaxPenaltyForSection(sectionTitle);
    currentPenalty += getCurrentPenaltyForSection(sectionTitle, backend);
  }

  if (maxPenalty == 0) return 0.0; // Return 0% if no test sections available
  
  // If no penalties have been recorded (test not started), return 0%
  if (currentPenalty == 0) return 0.0;
  
  return ((1 - (currentPenalty / maxPenalty)) * 100).clamp(0.0, 100.0);
}

double getOverallPercentage(
  dynamic page2Backend,
  dynamic page3Backend,
  dynamic hillStartBackend, {
  String? licenseCode,
}) {
  final percentages = getSectionPercentages(
    page2Backend,
    page3Backend,
    hillStartBackend,
  );
  
  // Get enabled pages for this license code
  List<int> enabledPages = licenseCode != null ? getEnabledPagesForCode(licenseCode) : [0, 1, 2, 3, 4, 5, 6, 7, 8];
  
  // Map page indices to section names
  Map<int, String> pageToSection = {
    1: 'Pretrip',
    2: 'Parallel Parking',
    3: 'Alley Docking',
    4: 'Hill Start',
    5: '3 Point Turn',
    6: 'Left Turn',
    7: 'Straight Reverse',
    8: 'Road Trip',
  };
  
  double total = 0;
  int count = 0;
  
  percentages.forEach((section, value) {
    // Only include sections that are enabled for this license code
    int pageIndex = pageToSection.entries.firstWhere(
      (entry) => entry.value == section,
      orElse: () => MapEntry(-1, ''),
    ).key;
    
    if (enabledPages.contains(pageIndex)) {
      total += value;
      count++;
    }
  });
  
  return count > 0 ? total / count : 0.0;
}

bool isOverallPass(
  dynamic page2Backend,
  dynamic page3Backend,
  dynamic hillStartBackend, {
  String? licenseCode,
}) {
  return getOverallPercentage(page2Backend, page3Backend, hillStartBackend, licenseCode: licenseCode) >=
      overallPassMark;
}

Map<String, bool> getSectionPassResults(
  dynamic page2Backend,
  dynamic page3Backend,
  dynamic hillStartBackend,
) {
  final percentages = getSectionPercentages(
    page2Backend,
    page3Backend,
    hillStartBackend,
  );
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

void handleTestButton(
  VoidCallback updateState, {
  AudioBackend? audioBackend,
  String? learnerId,
}) {
  if (!isFieldRunning && !isRoadRunning && fieldTestDuration == Duration.zero) {
    // Start field test
    fieldTimer.start();
    isFieldRunning = true;
    isTestSessionActive = true; // Mark test session as active
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
    isTestSessionActive = true; // Keep test session active
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
void handleEndTestButton(
  VoidCallback updateState, {
  AudioBackend? audioBackend,
  int? currentLearnerId, // Add parameter for current learner ID
  dynamic page2Backend,
  dynamic page3Backend,
  dynamic hillStartBackend,
  String? licenseCode, // Add parameter for license code
  BuildContext? context, // Add context for IP configuration
}) async {
  if (!isTestEnded) {
    // End the test - stop all timers
    endAllTests(updateState);

    // Stop audio recording if available
    if (audioBackend != null) {
      audioBackend.stopRecording();
    }

    // Calculate test result
    String testResult = 'failed'; // Default to failed
    if (page2Backend != null && page3Backend != null && hillStartBackend != null) {
      final overallPercentage = getOverallPercentage(page2Backend, page3Backend, hillStartBackend, licenseCode: licenseCode);
      testResult = overallPercentage >= overallPassMark ? 'passed' : 'failed';
      print('Test result calculated: $testResult (${overallPercentage.toStringAsFixed(1)}%) for license code: $licenseCode');
    }

    // Mark the current learner as completed
    if (currentLearnerId != null) {
      markLearnerAsCompleted(currentLearnerId);
      
      // Update the result in the database
      final updateSuccess = await updateTestResultInDatabase(currentLearnerId, testResult, context: context);
      if (updateSuccess) {
        print('Test result updated in database for learner $currentLearnerId: $testResult');
      } else {
        print('Failed to update test result in database for learner $currentLearnerId');
      }
    }

    isTestEnded = true;
    isTestSessionActive = false; // End the test session
    endTestButtonLabel = "Preview Report";
    
    // Reset new learner selection state when test ends
    resetNewLearnerSelection();
  }
  // If test is already ended, this button will navigate to preview report
  // (handled in the frontend)
  updateState();
}

// New function to reset everything for a new test
void resetForNewTest(
  VoidCallback updateState, {
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
  isTestSessionActive = false; // Reset test session state
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

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text("Submitted")));
}

class Learner {
  final String name;
  final String idNumber;
  final String code;
  final String gender;
  final int? learnerId;
  final int? instructorId;
  final String? testDate;
  final String? result;

  const Learner({
    required this.name,
    required this.idNumber,
    required this.code,
    required this.gender,
    this.learnerId,
    this.instructorId,
    this.testDate,
    this.result,
  });
}

// Function to fetch learners with test bookings for current date
Future<List<Learner>> fetchLearnersForCurrentDate({BuildContext? context}) async {
  try {
    final today = DateTime.now();
    final dateString = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    List<Learner> allLearners = [];
    
          // Fetch only PENDING test bookings for today from the API
      final pendingBookingsUrl = Uri.parse(context != null
          ? ApiConfig.buildUrl(context, 'learner-test-bookings/pending/$dateString')
          : ApiConfig.buildUrlLegacy('learner-test-bookings/pending/$dateString'));
      final pendingBookingsResponse = await http.get(
        pendingBookingsUrl,
        headers: {'Content-Type': 'application/json'},
      );
    
    if (pendingBookingsResponse.statusCode == 200) {
      final List<dynamic> todayBookings = jsonDecode(pendingBookingsResponse.body);
      
      print('Found ${todayBookings.length} test bookings for today ($dateString)');
      
      // Process each booking for today
      for (var booking in todayBookings) {
        try {
          final learnerId = booking['learner_id'];
          final instructorId = booking['instructor_id'];
          final licenceCode = booking['license_code'] as String? ?? '';
          final result = booking['result'] as String? ?? 'pending';
          final testDate = booking['test_date'] as String?;
          
          // Skip if learner has already completed their test
          if (completedLearnerIds.contains(learnerId)) {
            print('Skipping completed learner: $learnerId');
            continue;
          }
          
                      // Fetch user profile information for this learner
            final userProfileUrl = Uri.parse(context != null
                ? ApiConfig.buildUrl(context, 'user-profiles/$learnerId')
                : ApiConfig.buildUrlLegacy('user-profiles/$learnerId'));
            final userProfileResponse = await http.get(
            userProfileUrl,
            headers: {'Content-Type': 'application/json'},
          );
          
          if (userProfileResponse.statusCode == 200) {
            final userProfileData = jsonDecode(userProfileResponse.body);
            
            final displayCode = licenceCode.replaceAll('Code ', '').replaceAll('code ', ''); // Remove "Code " prefix
            
            allLearners.add(
              Learner(
                name: '${userProfileData['name'] ?? ''} ${userProfileData['surname'] ?? ''}'.trim(),
                idNumber: userProfileData['id_number'] ?? '',
                code: displayCode,
                gender: userProfileData['gender'] ?? '',
                learnerId: learnerId,
                instructorId: instructorId,
                testDate: testDate,
                result: result,
              ),
            );
            
            print('Added learner: ${userProfileData['name'] ?? ''} ${userProfileData['surname'] ?? ''} (ID: $learnerId)');
          } else {
            print('Failed to fetch user profile for learner $learnerId: ${userProfileResponse.statusCode}');
          }
        } catch (e) {
          print('Error processing booking for learner ${booking['learner_id']}: $e');
          // Continue with other bookings even if one fails
        }
      }
    } else {
      print('Failed to fetch pending test bookings: ${pendingBookingsResponse.statusCode}');
    }
    
    print('Total available learners for today: ${allLearners.length} (${completedLearnerIds.length} completed)');
    return allLearners;
  } catch (e) {
    print('Error fetching learner data: $e');
    return [];
  }
}

// Empty list of learners (fallback)
final List<Learner> learners = [];

class Officer {
  final String name;
  final String infraNr;

  const Officer({required this.name, required this.infraNr});
}

// New Instructor class to store API data
class Instructor {
  final String infraNr;

  const Instructor({
    required this.infraNr,
  });

  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      infraNr: json['inf_nr'] ?? '',
    );
  }
}

// Function to fetch instructor profile information
  Future<Instructor?> fetchInstructorProfile(int instructorId, {BuildContext? context}) async {
    try {
      final url = Uri.parse(context != null
          ? ApiConfig.buildUrl(context, 'instructor-profiles/$instructorId')
          : ApiConfig.buildUrlLegacy('instructor-profiles/$instructorId'));
    
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Instructor.fromJson(data);
    } else {
      print('Failed to fetch instructor profile: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching instructor profile: $e');
    return null;
  }
}

// Empty list of officers (fallback)
final List<Officer> officers = [];

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

// Progress colors (neutral gray)
final List<Color> progressColors = [
  Colors.grey,
  Colors.grey,
  Colors.grey,
  Colors.grey,
  Colors.grey,
  Colors.grey,
  Colors.grey,
  Colors.grey,
  Colors.grey,
];

// Individual progress values (reset to 0)
double progress1 = 0.0;
double progress2 = 0.0;
double progress3 = 0.0;
double progress4 = 0.0;
double progress5 = 0.0;
double progress6 = 0.0;
double progress7 = 0.0;
double progress8 = 0.0;
double progress9 = 0.0;

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
    Icons.checklist, // Pretrip - checklist icon for inspection
    Icons.local_parking, // Parallel Parking - parking icon
    Icons.directions_car_filled, // Alley Docking - car icon for maneuvering
    Icons.trending_up, // Hill Start - upward trend for incline
    Icons.rotate_right, // 3 Point Turn - rotation icon for turning around
    Icons.turn_left, // Left Turn - left turn arrow
    Icons.keyboard_backspace, // Straight Reverse - backspace for reverse
    Icons.route, // Road Trip - route icon for road driving
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
    String formattedTime =
        "${time.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(time.inSeconds.remainder(60)).toString().padLeft(2, '0')}";

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$label button pressed')));
      },
      child: Text(label),
    );
  }
}
