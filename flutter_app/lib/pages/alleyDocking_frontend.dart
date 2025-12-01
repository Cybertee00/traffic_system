import 'package:flutter/material.dart';
import 'checklist_data.dart';
import 'package:provider/provider.dart';
import 'alleyDocking_backend.dart';

class AlleyDockingPage extends StatefulWidget {
  const AlleyDockingPage({super.key});

  @override
  State<AlleyDockingPage> createState() => _AlleyDockingPageState();
}

class _AlleyDockingPageState extends State<AlleyDockingPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Page3Backend>(
      builder: (context, backend, _) {
        // Show bump dialog when triggered (similar to Hill Start)
        // IMPORTANT: Check flag and show dialog in PostFrameCallback to ensure widget tree is built
        if (backend.showBumpDialog) {
          // Show dialog after frame is built to prevent duplicate messages
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              // Don't clear flag here - clear it in the dialog itself or after showing
              _showBumpDialog(context, backend);
            }
          });
        }
        
        return Scaffold(
          appBar: AppBar(title: Text('Alley Docking')),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: _ChecklistCard(sectionTitle: 'ALLEY DOCKING (Left)')),
                Expanded(child: _MiddleCard()),
                Expanded(child: _ChecklistCard(sectionTitle: 'ALLEY DOCKING (Right)')),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _showBumpDialog(BuildContext context, Page3Backend backend) {
    // Prevent duplicate dialogs
    if (!context.mounted) return;
    
    // Clear flag BEFORE showing dialog (like Hill Start)
    backend.clearBumpDialog();
    
    showDialog(
      context: context,
      barrierDismissible: false, // User must click a button to dismiss
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 30),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Oops!',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'You have bumped into a pole',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Proceed - continue the test
              backend.clearBumpDialog();
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              'Proceed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // End Test - just close the dialog for now
              backend.endTestDueToBump();
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'End Test',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  final String sectionTitle;
  const _ChecklistCard({required this.sectionTitle});

  @override
  Widget build(BuildContext context) {
    final backend = Provider.of<Page3Backend>(context);
    final section = testSections.firstWhere((s) => s.title == sectionTitle);

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                section.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: section.checks.length,
                itemBuilder: (context, index) {
                  final check = section.checks[index];
                  final key = '${section.title}-${check.description}';
                  final count = backend.getCheckCount(key);

                  return ListTile(
                    leading: IconButton(
                      icon: const Icon(Icons.add_rounded, color: Colors.green),
                      onPressed: () => backend.incrementCheck(key),
                    ),
                    title: Text(check.description),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: count > 0 ? Colors.red.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
                          color: count > 0 ? Colors.red : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _calculateTotal(section, backend) > 0 
                    ? Colors.red.withOpacity(0.1) 
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Penalty:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${_calculateTotal(section, backend)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: _calculateTotal(section, backend) > 0 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateTotal(TestSection section, Page3Backend backend) {
    int total = 0;
    for (var check in section.checks) {
      final key = '${section.title}-${check.description}';
      final count = backend.getCheckCount(key);
      total += check.penaltyValue * count;
    }
    return total;
  }
}

class _MiddleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final backend = Provider.of<Page3Backend>(context);

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          // Connect and Complete buttons at the top
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Detection System:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<DetectionSystem>(
                      value: backend.detectionSystem,
                      onChanged: (system) {
                        if (system != null) {
                          backend.setDetectionSystem(system);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: DetectionSystem.aprilTag,
                          child: Text('April Tag'),
                        ),
                        DropdownMenuItem(
                          value: DetectionSystem.esp32Touch,
                          child: Text('ESP32 Touch'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Target: ws://${backend.activeTargetIp}:${backend.activeTargetPort}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => backend.connectWebSocket(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: backend.isConnected ? Colors.green : Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Connect'),
                    ),
                    ElevatedButton(
                      onPressed: () => backend.completeAndDisconnect(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Complete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Visual representation of poles
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                return Stack(
                  children: [
                    // Single parking barrier (unfilled rectangle)
                    Positioned(
                      left: width * 0.30,
                      top: height * 0.35,
                      child: Container(
                        width: width * 0.40,
                        height: height * 0.45,
                        decoration: BoxDecoration(
                          border: Border.all(color: backend.rectangleColor, width: 4),
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                    // Poles (circles)
                    ...backend.circles.map((circle) {
                      return Positioned(
                        left: circle.x * width - 15,
                        top: circle.y * height - 15,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: circle.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
