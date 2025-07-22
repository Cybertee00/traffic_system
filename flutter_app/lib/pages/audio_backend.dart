import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';

class AudioBackend extends ChangeNotifier {
  // Only initialize on Android
  final AudioRecorder? _audioRecorder = Platform.isAndroid ? AudioRecorder() : null;
  bool _isRecording = false;
  String? _currentRecordingPath;
  String? _currentLearnerId;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;
  String? get currentLearnerId => _currentLearnerId;
  Duration get recordingDuration => _recordingDuration;

  // Request permissions (Android only)
  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) return false;
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();

    bool allGranted = true;
    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        allGranted = false;
      }
    });

    return allGranted;
  }

  // Get Downloads or external storage directory
  Future<Directory?> _getSaveDirectory() async {
    if (!Platform.isAndroid) return null;
    Directory? downloadsDir = Directory('/storage/emulated/0/Download');
    if (await downloadsDir.exists()) {
      return downloadsDir;
    }
    // Fallback to external storage
    return await getExternalStorageDirectory();
  }

  // Start recording (Android only)
  Future<bool> startRecording(String learnerId) async {
    if (!Platform.isAndroid) return false;
    try {
      // Request permissions first
      bool permissionsGranted = await requestPermissions();
      if (!permissionsGranted) {
        debugPrint('Audio recording permissions not granted');
        return false;
      }

      // Get save directory
      Directory? saveDir = await _getSaveDirectory();
      if (saveDir == null) {
        debugPrint('Could not access save directory');
        return false;
      }

      // Create filename with learner ID and timestamp
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String filename = 'SMART_${learnerId}_${timestamp}.m4a';
      String filePath = '${saveDir.path}/$filename';

      // Start recording
      await _audioRecorder!.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      _isRecording = true;
      _currentRecordingPath = filePath;
      _currentLearnerId = learnerId;
      _recordingDuration = Duration.zero;

      // Start timer to track recording duration
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration += const Duration(seconds: 1);
        notifyListeners();
      });

      notifyListeners();
      debugPrint('Started recording: $filePath');
      return true;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      return false;
    }
  }

  // Stop recording (Android only)
  Future<String?> stopRecording() async {
    if (!Platform.isAndroid) return null;
    try {
      if (!_isRecording) {
        return null;
      }

      // Stop the recording
      String? path = await _audioRecorder!.stop();
      
      // Stop the timer
      _recordingTimer?.cancel();
      _recordingTimer = null;

      _isRecording = false;
      String? savedPath = _currentRecordingPath;
      
      // Clear current recording info
      _currentRecordingPath = null;
      _currentLearnerId = null;
      _recordingDuration = Duration.zero;

      notifyListeners();
      debugPrint('Stopped recording: $path');
      return savedPath;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      return null;
    }
  }

  // Check if currently recording
  bool get isCurrentlyRecording => _isRecording;

  // Get formatted duration string
  String get formattedDuration {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(_recordingDuration.inHours);
    String minutes = twoDigits(_recordingDuration.inMinutes.remainder(60));
    String seconds = twoDigits(_recordingDuration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  // Dispose resources
  @override
  void dispose() {
    _recordingTimer?.cancel();
    if (Platform.isAndroid) {
      _audioRecorder?.dispose();
    }
    super.dispose();
  }
} 