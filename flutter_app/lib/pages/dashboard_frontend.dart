import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dashboard_backend.dart';
import 'login_page.dart';
import 'package:provider/provider.dart';
import 'parallel_parking_backend.dart';
import 'alleyDocking_backend.dart';
import 'hillStart_backend.dart';
import 'car_details_backend.dart';
import 'checklist_data.dart';
import 'report_preview_page.dart';
import 'theme_backend.dart';
import 'audio_backend.dart';
import 'dart:math' as math;


class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => Page1State();
}
class Page1State extends State<Page1> 
{
  Learner selectedLearner = learners[0];
  Officer selectedOfficer = officers[0];
  bool isEditingOfficer = false;
 
  late Ticker _ticker;

  Duration fieldElapsed = Duration.zero;
  Duration roadElapsed = Duration.zero;


  bool isFieldRunning = false;
  bool isRoadRunning = false;
  

  final TextEditingController officerNameController =
    TextEditingController(text: 'Officer Name');

  final TextEditingController officerInfraNrController =
    TextEditingController(text: 'Infra nr');

  final TextEditingController officerEmailController =
    TextEditingController(text: 'user@example.com');
  
  final TextEditingController carLicenceController = TextEditingController();
  final TextEditingController carRegController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick)..start();
    
    // Initialize controllers with provider values after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final carDetails = Provider.of<CarDetailsBackend>(context, listen: false);
      if (carDetails.carLicence.isNotEmpty) {
        carLicenceController.text = carDetails.carLicence;
      }
      if (carDetails.carReg.isNotEmpty) {
        carRegController.text = carDetails.carReg;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update controllers when provider values change
    final carDetails = Provider.of<CarDetailsBackend>(context, listen: false);
    if (carDetails.carLicence != carLicenceController.text) {
      carLicenceController.text = carDetails.carLicence;
    }
    if (carDetails.carReg != carRegController.text) {
      carRegController.text = carDetails.carReg;
    }
  }

  void _onTick(Duration _) {
  setState(() {
    updateDurations(); // ✅ This updates fieldTestDuration, roadTestDuration, totalTestDuration
    // Update the dashboard state variables with the global timer values
    fieldElapsed = fieldTestDuration;
    roadElapsed = roadTestDuration;
  });
}


  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void toggleTheme() {
    final themeBackend = Provider.of<ThemeBackend>(context, listen: false);
    themeBackend.toggleTheme();
  }
  Widget _buildProgressTimer(String label, Duration elapsed, Duration total) {
  double progress = 1 - (elapsed.inSeconds / total.inSeconds).clamp(0.0, 1.0);

  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String minutes = twoDigits(elapsed.inMinutes.remainder(60));
  String seconds = twoDigits(elapsed.inSeconds.remainder(60));

  return Stack(
    alignment: Alignment.center,
    children: [
      SizedBox(
        height: 100,
        width: 100,
        child: CircularProgressIndicator(
          value: progress,
          strokeWidth: 10,
          backgroundColor: Colors.grey[300],
          color: Colors.blue,
        ),
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, size: 20),
          Text("$minutes:$seconds", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    ],
  );
}


  @override
  Widget build(BuildContext context) {
    getProgressValues();
    final page2Backend = Provider.of<Page2Backend>(context);
    final page3Backend = Provider.of<Page3Backend>(context);
    final hillStartBackend = Provider.of<HillStartBackend>(context);
    final themeBackend = Provider.of<ThemeBackend>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            )
          ],
        ),
        endDrawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              //const DrawerHeader(
                //decoration: BoxDecoration(color: Colors.blue),
                //child: Text('Settings', style: TextStyle(color: Colors.white)),
              //),
              SwitchListTile(
                title: const Text("Dark Mode"),
                value: themeBackend.isDarkMode,
                onChanged: (value) {
                  toggleTheme();
                },
                secondary: const Icon(Icons.dark_mode),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );

                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );

                },
              ),
            ],
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Officer/Instructor Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        DropdownButton<Officer>(
                          value: selectedOfficer,
                          onChanged: (Officer? newValue) {
                            setState(() {
                              selectedOfficer = newValue!;
                            });
                          },
                          items: officers.map((Officer officer) {
                            return DropdownMenuItem<Officer>(
                              value: officer,
                              child: Text(officer.name),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[300],
                          child: const Icon(Icons.person, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedOfficer.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedOfficer.infraNr,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),


          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown to pick learner
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Learner Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      DropdownButton<Learner>(
                        value: selectedLearner,
                        onChanged: (Learner? newValue) {
                          setState(() {
                            selectedLearner = newValue!;
                          });
                        },
                        items: learners.map((Learner learner) {
                          return DropdownMenuItem<Learner>(
                            value: learner,
                            child: Text(learner.name),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Display learner info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name: ${selectedLearner.name}", style: const TextStyle(fontSize: 14)),
                            Text("ID: ${selectedLearner.idNumber}", style: const TextStyle(fontSize: 14)),
                            Text("Code: ${selectedLearner.code}", style: const TextStyle(fontSize: 14)),
                            Text("Gender: ${selectedLearner.gender}", style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Car Details Card (all fields in one row)
          Consumer<CarDetailsBackend>(
            builder: (context, carDetails, child) {
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Car Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: carLicenceController,
                              onChanged: (value) => carDetails.updateCarLicence(value),
                              decoration: const InputDecoration(
                                labelText: 'Licence Number',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: carRegController,
                              onChanged: (value) => carDetails.updateCarReg(value),
                              decoration: const InputDecoration(
                                labelText: 'Registration Number',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: carDetails.carTransmission.isNotEmpty ? carDetails.carTransmission : null,
                              decoration: const InputDecoration(
                                labelText: 'Transmission Type',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Automatic', child: Text('Automatic')),
                                DropdownMenuItem(value: 'Manual', child: Text('Manual')),
                              ],
                              onChanged: (value) {
                                carDetails.updateCarTransmission(value ?? '');
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: carDetails.carWeather.isNotEmpty ? carDetails.carWeather : null,
                              decoration: const InputDecoration(
                                labelText: 'Weather Conditions',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Wet', child: Text('Wet')),
                                DropdownMenuItem(value: 'Dry', child: Text('Dry')),
                              ],
                              onChanged: (value) {
                                carDetails.updateCarWeather(value ?? '');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Penalty Points Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Penalty Points', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildPenaltyRow('Pretrip', page2Backend, ['PRETRIP INTERIOR', 'PRETRIP EXTERIOR']),
                  _buildPenaltyRow('Parallel Parking', page2Backend, ['PARALLEL PARKING (Left)', 'PARALLEL PARKING (Right)']),
                  _buildPenaltyRow('Alley Docking', page3Backend, ['ALLEY DOCKING (Left)', 'ALLEY DOCKING (Right)']),
                  _buildPenaltyRow('Hill Start', hillStartBackend, ['INCLINE START']),
                  _buildPenaltyRow('3 Point Turn', page2Backend, ['TURN IN THE ROAD']),
                  _buildPenaltyRow('Left Turn', page2Backend, ['LEFT TURN']),
                  _buildPenaltyRow('Straight Reverse', page2Backend, ['STRAIGHT REVERSING']),
                  _buildPenaltyRow('Road Trip', page2Backend, [
                    'STARTING','MOVING OFF','STEERING','CLUTCH','GEAR CHANGING','SIGNALLING','LANE CHANGING','OVERTAKING','INTERSECTION VEHICLE ENTRY/EXIT','SPEED CONTROL','STOPPING','FREEWAYS ENTRY/EXIT',
                  ]),
                ],
              ),
            ),
          ),


            //const SizedBox(height: 10),

            // 2. 9 Circular Progress Bars (penalty percentage)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: DashboardGraphsGrid(),
            ),
            // Color Legend
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendColor(Colors.green, '85–100%'),
                  const SizedBox(width: 16),
                  _buildLegendColor(Colors.yellow, '70–84%'),
                  const SizedBox(width: 16),
                  _buildLegendColor(Colors.orange, '51–69%'),
                  const SizedBox(width: 16),
                  _buildLegendColor(Colors.red, '0–50%'),
                ],
              ),
            ),


            //const SizedBox(height: 10),

            // 3. Timers with circular progress bars
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildProgressTimer("Field Time", fieldTestDuration, fieldTestTotal),
                  _buildProgressTimer("Road Trip Time", roadTestDuration, roadTestTotal),
                  _buildProgressTimer("Total Test Time", totalTestDuration, fieldTestTotal + roadTestTotal),
                ],
              ),
            ),
          ),


            //const SizedBox(height: 20),

            // 4. Buttons
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (isTestEnded) {
                          // Reset for new test
                          resetForNewTest(() => setState(() {}),
                            page2Backend: page2Backend,
                            page3Backend: page3Backend,
                            hillStartBackend: hillStartBackend,
                            carDetailsBackend: Provider.of<CarDetailsBackend>(context, listen: false),
                          );
                        } else {
                          // Handle normal test button
                          final audioBackend = Provider.of<AudioBackend>(context, listen: false);
                          handleTestButton(() => setState(() {}),
                            audioBackend: audioBackend,
                            learnerId: selectedLearner.idNumber,
                          );
                        }
                      },
                      child: Text(actionLabel),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (!isTestEnded) {
                          // End the test
                          final audioBackend = Provider.of<AudioBackend>(context, listen: false);
                          handleEndTestButton(() => setState(() {}),
                            audioBackend: audioBackend,
                          );
                        } else {
                          // Navigate to preview report
                          final carDetails = Provider.of<CarDetailsBackend>(context, listen: false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ReportPreviewPage(
                              officer: selectedOfficer,
                              learner: selectedLearner,
                              carLicence: carDetails.carLicence,
                              carReg: carDetails.carReg,
                              carTransmission: carDetails.carTransmission,
                              carWeather: carDetails.carWeather,
                              fieldTestDuration: fieldElapsed,
                              roadTestDuration: roadElapsed,
                              totalTestDuration: fieldElapsed + roadElapsed,
                            )),
                          );
                        }
                      },
                      child: Text(endTestButtonLabel),
                    ),
                  ],
                ),
              ),
            ),

            // 5. Results Doughnut Graph (only show when test is ended)
            if (isTestEnded)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Test Results Summary',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TestResultsDoughnut(
                        page2Backend: page2Backend,
                        page3Backend: page3Backend,
                        hillStartBackend: hillStartBackend,
                      ),
                    ],
                  ),
                ),
              ),

          ],
        ),
      ),
    );
  }
}

class DashboardGraphsGrid extends StatelessWidget {
  const DashboardGraphsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final page2Backend = Provider.of<Page2Backend>(context);
    final page3Backend = Provider.of<Page3Backend>(context);
    final hillStartBackend = Provider.of<HillStartBackend>(context);
    final progressColors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.brown, Colors.indigo
    ];
    return SizedBox(
      width: 600,
      height: 600,
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildPenaltyProgressBar('Pretrip', page2Backend, ['PRETRIP INTERIOR', 'PRETRIP EXTERIOR'], progressColors[0], getIconForIndex(0)),
          _buildPenaltyProgressBar('Parallel Parking', page2Backend, ['PARALLEL PARKING (Left)', 'PARALLEL PARKING (Right)'], progressColors[1], getIconForIndex(1)),
          _buildPenaltyProgressBar('Alley Docking', page3Backend, ['ALLEY DOCKING (Left)', 'ALLEY DOCKING (Right)'], progressColors[2], getIconForIndex(2)),
          _buildPenaltyProgressBar('Hill Start', hillStartBackend, ['INCLINE START'], progressColors[3], getIconForIndex(3)),
          _buildPenaltyProgressBar('3 Point Turn', page2Backend, ['TURN IN THE ROAD'], progressColors[4], getIconForIndex(4)),
          _buildPenaltyProgressBar('Left Turn', page2Backend, ['LEFT TURN'], progressColors[5], getIconForIndex(5)),
          _buildPenaltyProgressBar('Straight Reverse', page2Backend, ['STRAIGHT REVERSING'], progressColors[6], getIconForIndex(6)),
          _buildPenaltyProgressBar('Road Trip', page2Backend, [
            'STARTING','MOVING OFF','STEERING','CLUTCH','GEAR CHANGING','SIGNALLING','LANE CHANGING','OVERTAKING','INTERSECTION VEHICLE ENTRY/EXIT','SPEED CONTROL','STOPPING','FREEWAYS ENTRY/EXIT',
          ], progressColors[7], getIconForIndex(7)),
        ],
      ),
    );
  }
}

Widget _buildPenaltyRow(String label, dynamic backend, List<String> sectionTitles) {
  double total = 0;
  for (var sectionTitle in sectionTitles) {
    final section = testSections.firstWhere(
      (s) => s.title == sectionTitle,
      orElse: () => TestSection(title: sectionTitle, checks: []),
    );
    for (var check in section.checks) {
      final key = '${section.title}-${check.description}';
      final count = backend.getCheckCount(key);
      total += check.penaltyValue * count;
    }
  }
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(total % 1 == 0 ? total.toInt().toString() : total.toStringAsFixed(1), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    ),
  );
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

Color getProgressColor(double percent) {
  if (percent >= 0.85) {
    return Colors.green;
  } else if (percent >= 0.70) {
    return Colors.yellow;
  } else if (percent >= 0.51) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}

Widget _buildPenaltyProgressBar(String label, dynamic backend, List<String> sectionTitles, Color color, IconData icon) {
  double maxPenalty = 0;
  double currentPenalty = 0;
  for (var sectionTitle in sectionTitles) {
    maxPenalty += getMaxPenaltyForSection(sectionTitle);
    currentPenalty += getCurrentPenaltyForSection(sectionTitle, backend);
  }
  // Inverse logic: start at 100%, decrease as penalties are incurred
  double percent = 0.0;
  if (maxPenalty > 0) {
    if (currentPenalty > 0) {
      percent = (1 - (currentPenalty / maxPenalty)).clamp(0.0, 1.0);
    } else {
      percent = 0.0; // Bar remains empty until the first penalty is recorded
    }
  }
  int percentage = (percent * 100).toInt();
  final progressColor = getProgressColor(percent);
  return Center(
    child: Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: CircularProgressIndicator(
            value: percent,
            strokeWidth: 12,
            backgroundColor: Colors.grey[300],
            color: progressColor,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            Text("$percentage%", style: const TextStyle(fontSize: 15)),
          ],
        ),
      ],
    ),
  );
}

Widget _buildLegendColor(Color color, String label) {
  return Row(
    children: [
      Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black12),
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 13)),
    ],
  );
}

class TestResultsDoughnut extends StatefulWidget {
  final dynamic page2Backend;
  final dynamic page3Backend;
  final dynamic hillStartBackend;

  const TestResultsDoughnut({
    Key? key,
    required this.page2Backend,
    required this.page3Backend,
    required this.hillStartBackend,
  }) : super(key: key);

  @override
  State<TestResultsDoughnut> createState() => _TestResultsDoughnutState();
}

class _TestResultsDoughnutState extends State<TestResultsDoughnut>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overallPercentage = getOverallPercentage(
      widget.page2Backend,
      widget.page3Backend,
      widget.hillStartBackend,
    );
    final isPass = isOverallPass(
      widget.page2Backend,
      widget.page3Backend,
      widget.hillStartBackend,
    );
    final sectionResults = getSectionPassResults(
      widget.page2Backend,
      widget.page3Backend,
      widget.hillStartBackend,
    );

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Doughnut chart
                  CustomPaint(
                    size: const Size(200, 200),
                    painter: DoughnutPainter(
                      percentage: overallPercentage,
                      isPass: isPass,
                      animation: _animation.value,
                    ),
                  ),
                  // Center text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isPass ? 'PASS' : 'FAIL',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isPass ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${overallPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Section results
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sectionResults.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: entry.value ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class DoughnutPainter extends CustomPainter {
  final double percentage;
  final bool isPass;
  final double animation;

  DoughnutPainter({
    required this.percentage,
    required this.isPass,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final strokeWidth = 20.0;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = isPass ? Colors.green : Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = (percentage / 100) * 2 * math.pi * animation;
    
    canvas.drawArc(
      rect,
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
