import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'checklist_data.dart';
import 'hillStart_backend.dart';

class HillStartPage extends StatefulWidget {
  const HillStartPage({super.key});

  @override
  State<HillStartPage> createState() => _HillStartPageState();
}

class _HillStartPageState extends State<HillStartPage> {
  @override
  Widget build(BuildContext context) {
    // Listen for success messages and show popup dialog
    return Consumer<HillStartBackend>(
      builder: (context, backend, _) {
        // Show success/unsuccessful message when triggered
        if (backend.showSuccessMessage && backend.successMessage != null) {
          // Show dialog after frame is built to prevent duplicate messages
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final message = backend.successMessage ?? '';
            final isSuccessful = backend.isSuccessful;
            backend.clearSuccessMessage();
            _showResultDialog(context, message, isSuccessful);
          });
        }
        
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Title
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Incline Start',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                // Initialization feedback message
                Consumer<HillStartBackend>(
                  builder: (context, backend, _) {
                    if (backend.initializationMessage != null) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: (backend.initializationSuccess == true) 
                              ? Colors.green.withOpacity(0.1) 
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (backend.initializationSuccess == true) 
                                ? Colors.green 
                                : Colors.orange,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              (backend.initializationSuccess == true) 
                                  ? Icons.check_circle 
                                  : Icons.warning,
                              color: (backend.initializationSuccess == true) 
                                  ? Colors.green 
                                  : Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                backend.initializationMessage!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: (backend.initializationSuccess == true) 
                                      ? Colors.green.shade700 
                                      : Colors.orange.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => backend.clearInitializationFeedback(),
                              color: Colors.grey,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Row(
                  children: [
                    Consumer<HillStartBackend>(
                      builder: (context, backend, _) {
                        return ElevatedButton(
                          onPressed: () => Provider.of<HillStartBackend>(context, listen: false).connectWebSocket(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: backend.isConnected ? Colors.green : Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(backend.isConnected ? 'Connected' : 'Connect'),
                        );
                      },
                    ),
                    SizedBox(width: 8),
                    Consumer<HillStartBackend>(
                      builder: (context, backend, _) {
                        final isAutoCompleted = backend.autoCompleted;
                        return ElevatedButton(
                          onPressed: isAutoCompleted 
                              ? null  // Disable button when auto-completed
                              : () {
                                  if (!backend.testStarted) {
                                    // Start the test
                                    Provider.of<HillStartBackend>(context, listen: false).startTest();
                                  } else {
                                    // Complete the test
                                    Provider.of<HillStartBackend>(context, listen: false).completeAndDisconnect();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAutoCompleted 
                                ? Colors.grey 
                                : (backend.testStarted ? Colors.blue : Colors.green),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                            disabledForegroundColor: Colors.white70,
                          ),
                          child: Text(
                            isAutoCompleted 
                                ? 'Auto-Completed' 
                                : (backend.testStarted ? 'Complete' : 'Start'),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Consumer<HillStartBackend>(
                        builder: (context, backend, _) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            child: LinearProgressIndicator(
                              value: backend.progressValue,
                              minHeight: 8.0,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Consumer<HillStartBackend>(
                      builder: (context, backend, _) {
                        return Text(
                          '${(backend.progressValue * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(child: _ChecklistCard(sectionTitle: 'INCLINE START')),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _showResultDialog(BuildContext context, String message, bool isSuccessful) {
    final Color themeColor = isSuccessful ? Colors.green : Colors.red;
    final IconData icon = isSuccessful ? Icons.check_circle : Icons.cancel;
    final String title = isSuccessful ? 'Success!' : 'Unsuccessful!';
    
    showDialog(
      context: context,
      barrierDismissible: false, // User must click OK to dismiss
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(icon, color: themeColor, size: 30),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: themeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
    final backend = Provider.of<HillStartBackend>(context);
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
                      onPressed: () {
                        backend.incrementCheck(key);
                      },
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

  double _calculateTotal(TestSection section, HillStartBackend backend) 
  {
    double total = 0;
    for (var check in section.checks) {
      final key = '${section.title}-${check.description}';
      final count = backend.getCheckCount(key);
      total += check.penaltyValue * count;
    }
    return total;
  }
} 
