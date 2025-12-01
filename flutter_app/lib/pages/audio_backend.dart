import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';

class AudioBackend extends ChangeNotifier {
  // Only initialize on Android (not web)
  final AudioRecorder? _audioRecorder = (!kIsWeb && Platform.isAndroid) ? AudioRecorder() : null;
  bool _isRecording = false;
  String? _currentRecordingPath;
  String? _currentLearnerId;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;
  String? get currentLearnerId => _currentLearnerId;
  Duration get recordingDuration => _recordingDuration;
  
  // Format duration as MM:SS
  String get formattedDuration {
    int minutes = _recordingDuration.inMinutes;
    int seconds = _recordingDuration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Request permissions (Android only)
  Future<bool> requestPermissions() async {
    if (kIsWeb || !Platform.isAndroid) return false;
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
    if (kIsWeb || !Platform.isAndroid) return null;
    Directory? downloadsDir = Directory('/storage/emulated/0/Download');
    if (await downloadsDir.exists()) {
      return downloadsDir;
    }
    // Fallback to external storage
    return await getExternalStorageDirectory();
  }

  // Start recording (Android only)
  Future<bool> startRecording(String learnerId) async {
    if (kIsWeb || !Platform.isAndroid || _audioRecorder == null) return false;
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
      String filename = 'SMART_${learnerId}_$timestamp.m4a';
      String filePath = '${saveDir.path}/$filename';

      // Start recording
      await _audioRecorder.start(
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
    if (kIsWeb || !Platform.isAndroid || _audioRecorder == null) return null;
    try {
      String? path = await _audioRecorder.stop();
      _isRecording = false;
      _recordingTimer?.cancel();
      _recordingTimer = null;
      notifyListeners();
      debugPrint('Stopped recording: $path');
      return path;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      return null;
    }
  }

  // Pause recording (Android only)
  Future<void> pauseRecording() async {
    if (kIsWeb || !Platform.isAndroid || _audioRecorder == null) return;
    try {
      await _audioRecorder.pause();
      _recordingTimer?.cancel();
      notifyListeners();
      debugPrint('Paused recording');
    } catch (e) {
      debugPrint('Error pausing recording: $e');
    }
  }

  // Resume recording (Android only)
  Future<void> resumeRecording() async {
    if (kIsWeb || !Platform.isAndroid || _audioRecorder == null) return;
    try {
      await _audioRecorder.resume();
      // Restart timer
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration += const Duration(seconds: 1);
        notifyListeners();
      });
      notifyListeners();
      debugPrint('Resumed recording');
    } catch (e) {
      debugPrint('Error resuming recording: $e');
    }
  }

  // Check if recording is supported
  bool get isRecordingSupported => !kIsWeb && Platform.isAndroid && _audioRecorder != null;

  // Get recording state
  bool get isPaused {
    if (_audioRecorder == null) return false;
    return false; // isPaused() is async, so we'll return false for now
  }

  // Dispose
  @override
  void dispose() {
    _recordingTimer?.cancel();
    _audioRecorder?.dispose();
    super.dispose();
  }
} 