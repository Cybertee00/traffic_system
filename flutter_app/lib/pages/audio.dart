import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'audio_backend.dart';
import 'dashboard_backend.dart';
import 'dart:io';

class AudioPage extends StatelessWidget {
  const AudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recording'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<AudioBackend>(
        builder: (context, audioBackend, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          audioBackend.isRecording 
                            ? Icons.mic 
                            : Icons.mic_off,
                          size: 64,
                          color: audioBackend.isRecording 
                            ? Colors.red 
                            : Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          audioBackend.isRecording 
                            ? 'Recording in Progress' 
                            : 'Recording Stopped',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (audioBackend.isRecording) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Duration: ${audioBackend.formattedDuration}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Recording Info
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recording Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Status', audioBackend.isRecording ? 'Active' : 'Inactive'),
                        if (audioBackend.currentRecordingPath != null)
                          _buildInfoRow('File Path', audioBackend.currentRecordingPath!),
                        if (audioBackend.currentLearnerId != null)
                          _buildInfoRow('Learner ID', audioBackend.currentLearnerId!),
                        _buildInfoRow('File Format', 'M4A (AAC)'),
                        if (Platform.isAndroid)
                          _buildInfoRow('Quality', '128 kbps, 44.1 kHz')
                        else if (Platform.isWindows)
                          _buildInfoRow('Note', 'Placeholder files for Windows'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Manual Controls (for testing)
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Manual Controls',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Note: Recording automatically starts/stops with test timers',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: audioBackend.isRecording 
                                  ? null 
                                  : () => _startManualRecording(context, audioBackend),
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Start Recording'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: audioBackend.isRecording 
                                  ? () => _stopManualRecording(context, audioBackend)
                                  : null,
                                icon: const Icon(Icons.stop),
                                label: const Text('Stop Recording'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Instructions
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'How it works',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                                                 Text(
                           '• Recording automatically starts when you begin a field test\n'
                           '• Recording automatically stops when you end the test\n'
                           '• Files are saved in Downloads folder with learner ID\n'
                           '• Format: SMART_[LearnerID]_[Timestamp].${Platform.isWindows ? "txt" : "m4a"}',
                           style: const TextStyle(fontSize: 14),
                         ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startManualRecording(BuildContext context, AudioBackend audioBackend) async {
    // Get current learner ID from dashboard
    final learnersList = learners;
    if (learnersList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No learner selected. Please select a learner first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String learnerId = learnersList[0].idNumber; // Use first learner for demo
    bool success = await audioBackend.startRecording(learnerId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Started recording for learner: $learnerId'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to start recording. Check permissions.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopManualRecording(BuildContext context, AudioBackend audioBackend) async {
    String? savedPath = await audioBackend.stopRecording();
    
    if (savedPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recording saved: $savedPath'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to stop recording.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showInfoDialog(BuildContext context) {
    //final audioBackend = Provider.of<AudioBackend>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Recording Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Automatic Recording:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('• Starts when field test begins'),
            const Text('• Stops when test ends'),
            Text('• Saves to Downloads folder'),
            const SizedBox(height: 16),
            const Text(
              'File Naming:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Format: SMART_[LearnerID]_[Timestamp].${Platform.isWindows ? "txt" : "m4a"}'),
            Text('• Example: SMART_1234567890123_1640995200000.${Platform.isWindows ? "txt" : "m4a"}'),
            const SizedBox(height: 16),
            const Text(
              'Permissions Required:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('• Microphone access'),
            if (Platform.isAndroid) ...[
              const Text('• Storage access'),
              const Text('• File management'),
            ] else ...[
              const Text('• System will handle permissions automatically'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
