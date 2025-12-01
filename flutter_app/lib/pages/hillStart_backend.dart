import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';

class HillStartBackend extends ChangeNotifier {
  double progressValue = 0.5; // Start at 50% (initial position)
  final Map<String, int> _checkCounts = {};
  
  // WebSocket connection
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _progressUpdateTimer; // Timer for smooth progress updates
  bool _isConnected = false;
  bool _enableWebSocket = false; // Flag to enable/disable WebSocket
  bool _testStarted = false; // Track if Start button has been pressed
  bool _autoCompleted = false; // Track if test was auto-completed (reached 0% or 100%)
  int _currentStatus = 0; // Current movement status (0=stationary, 1=forward, 2=backward)
  
  // Success/Unsuccessful message triggers
  String? _successMessage; // Message to show (null if none)
  bool _showSuccessMessage = false; // Flag to show message
  bool _isSuccessful = true; // true = success, false = unsuccessful
  
  // Bridge connection settings (for April Tag system)
  String _bridgeHost = "172.16.24.23"; // Can be updated via settings
  static const int _bridgePort = 8767;

  // Method to update IP address from settings
  void updateIpAddress(String ip) {
    if (_bridgeHost != ip) {
      _bridgeHost = ip;
      // Disconnect and reconnect if currently connected
      if (_isConnected) {
        disconnectFromBridge();
        // Reconnect will happen automatically via _scheduleReconnect
      }
      notifyListeners();
    }
  }

  HillStartBackend() {
    // Initialize with 50% progress (initial position)
    progressValue = 0.5;
    notifyListeners();
    
    // Don't automatically connect - wait for user to click Connect button
    _enableWebSocket = false;
  }

  // Enable/disable WebSocket connection
  void setWebSocketEnabled(bool enabled) {
    _enableWebSocket = enabled;
    if (enabled) {
      connectToBridge();
    } else {
      disconnectFromBridge();
    }
  }

  // Disconnect from Bridge
  void disconnectFromBridge() {
    _channel?.sink.close();
    _channel = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _progressUpdateTimer?.cancel();
    _progressUpdateTimer = null;
    _isConnected = false;
    _testStarted = false;
    _autoCompleted = false; // Reset auto-completed flag
    _currentStatus = 0;
    progressValue = 0.5; // Reset to 50% when disconnected
    if (_enableWebSocket) {
      debugPrint('Hill Start - Disconnected from Bridge WebSocket');
    }
    notifyListeners();
  }

  // Connect to Bridge WebSocket
  void connectToBridge() {
    if (!_enableWebSocket) {
      return; // Silent return when disabled
    }
    
    try {
      final uri = Uri.parse('ws://$_bridgeHost:$_bridgePort');
      _channel = WebSocketChannel.connect(uri);
      
      // Mark as attempting connection
      debugPrint('Hill Start - Attempting to connect to Bridge...');
      
      _channel!.stream.listen(
        (data) {
          if (_enableWebSocket) {
            // Mark as connected when we receive ANY data from bridge
            // This confirms the connection is successful (like Parallel/Alley)
            if (!_isConnected) {
              _isConnected = true;
              notifyListeners(); // Update UI to show connected status (green button)
              debugPrint('Hill Start - Connected to Bridge WebSocket (received data)');
              
              // Send initialization request now that connection is confirmed
              Future.delayed(const Duration(milliseconds: 100), () {
                if (_isConnected && _channel != null) {
                  try {
                    final initMessage = jsonEncode({
                      'action': 'initialize',
                      'tag_id': null  // Bridge will auto-detect tag (NOT 1-20)
                    });
                    _channel?.sink.add(initMessage);
                    debugPrint('Hill Start: Sent initialization request');
                  } catch (e) {
                    debugPrint('Hill Start: Error sending initialization request: $e');
                  }
                }
              });
            }
            
            // Handle different message types
            try {
              final decoded = jsonDecode(data);
              if (decoded is Map<String, dynamic>) {
                // Check if it's initialization feedback
                if (decoded['type'] == 'initialize_feedback') {
                  _handleInitializeFeedback(decoded);
                  return;
                }
                // Otherwise, it's progress/status data
                _handleProgressData(data);
              } else {
                // Legacy format
                _handleProgressData(data);
              }
            } catch (e) {
              // Not JSON, treat as legacy format
              _handleProgressData(data);
            }
          }
        },
        onError: (error) {
          if (_enableWebSocket) {
            debugPrint('Hill Start - WebSocket error: $error');
            _isConnected = false;
            notifyListeners(); // Update UI to show disconnected status
            _scheduleReconnect();
          }
        },
        onDone: () {
          if (_enableWebSocket) {
            debugPrint('Hill Start - WebSocket connection closed');
            _isConnected = false;
            notifyListeners(); // Update UI to show disconnected status
            _scheduleReconnect();
          }
        },
      );
    } catch (e) {
      if (_enableWebSocket) {
        debugPrint('Hill Start - Failed to connect to Bridge: $e');
        _isConnected = false;
        _scheduleReconnect();
      }
    }
  }

  // Handle incoming status data from Bridge
  void _handleProgressData(dynamic data) {
    if (!_enableWebSocket) return; // Don't process data if disabled
    
    try {
      final jsonData = jsonDecode(data.toString());
      
      if (jsonData.containsKey('status')) {
        final int status = jsonData['status'] as int;
        final int previousStatus = _currentStatus;
        _currentStatus = status;
        
        debugPrint('Hill Start - Status received: $status (0=stationary, 1=forward, 2=backward, -1=init)');
        
        // Handle initialization (status -1) - just ensure we're at 50% and ready
        if (status == -1) {
          _progressUpdateTimer?.cancel();
          _progressUpdateTimer = null;
          progressValue = 0.5; // Ensure we're at 50% (initial position)
          notifyListeners();
          debugPrint('Hill Start - Initialized at 50%');
          return;
        }
        
        // Handle status changes - SNAP to target immediately
        if (status == 1) {
          // Forward - snap to 100% immediately
          if (previousStatus != 1) {
            // Only snap when status changes (not continuously)
            progressValue = 1.0;
            _progressUpdateTimer?.cancel();
            _progressUpdateTimer = null;
            // Trigger success message
            _successMessage = 'Vehicle successfully moved FORWARD!';
            _showSuccessMessage = true;
            _isSuccessful = true; // Forward = successful
            notifyListeners();
            debugPrint('Hill Start - Tag moved FORWARD, progress snapped to 100%');
            
            // Auto-complete when reaching 100%
            if (_testStarted && !_autoCompleted) {
              _autoCompleted = true;
              // Delay auto-completion slightly to show the success message first
              Future.delayed(const Duration(milliseconds: 500), () {
                completeAndDisconnect();
                debugPrint('Hill Start - Auto-completed at 100%');
              });
            }
          }
        } else if (status == 2) {
          // Backward - snap to 0% immediately
          if (previousStatus != 2) {
            // Only snap when status changes (not continuously)
            progressValue = 0.0;
            _progressUpdateTimer?.cancel();
            _progressUpdateTimer = null;
            // Trigger UNSUCCESSFUL message (backward = unsuccessful)
            _successMessage = 'Vehicle moved BACKWARD - Unsuccessful!';
            _showSuccessMessage = true;
            _isSuccessful = false; // Backward = unsuccessful
            notifyListeners();
            debugPrint('Hill Start - Tag moved BACKWARD, progress snapped to 0% - UNSUCCESSFUL');
            
            // Auto-complete when reaching 0%
            if (_testStarted && !_autoCompleted) {
              _autoCompleted = true;
              // Delay auto-completion slightly to show the unsuccessful message first
              Future.delayed(const Duration(milliseconds: 500), () {
                completeAndDisconnect();
                debugPrint('Hill Start - Auto-completed at 0%');
              });
            }
          }
        } else if (status == 0) {
          // Stationary - keep current position
          _progressUpdateTimer?.cancel();
          _progressUpdateTimer = null;
        }
        
      } else if (jsonData.containsKey('progress')) {
        // Legacy support - if bridge still sends progress directly
        final double progress = (jsonData['progress'] as num).toDouble();
        progressValue = progress.clamp(0.0, 1.0);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Hill Start - Error parsing status data: $e');
    }
  }
  
  // Removed _animateToFiftyPercent - line now starts at 50% by default
  // Removed _startProgressUpdate - progress now snaps immediately to 0% or 100%

  // Schedule reconnection attempt
  void _scheduleReconnect() {
    if (!_enableWebSocket) return;
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected && _enableWebSocket) {
        debugPrint('Hill Start - Attempting to reconnect to Bridge...');
        connectToBridge();
      }
    });
  }

  // Manual reconnection
  void reconnect() {
    if (!_enableWebSocket) {
      debugPrint('Hill Start - WebSocket is disabled. Enable it first.');
      return;
    }
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    connectToBridge();
  }

  // Check connection status
  bool get isConnected => _isConnected;
  bool get isWebSocketEnabled => _enableWebSocket;
  
  // Initialization feedback state
  String? _initializationMessage;
  bool? _initializationSuccess;
  
  String? get initializationMessage => _initializationMessage;
  bool? get initializationSuccess => _initializationSuccess;
  
  void _handleInitializeFeedback(Map<String, dynamic> feedback) {
    _initializationSuccess = feedback['success'] as bool?;
    _initializationMessage = feedback['message'] as String?;
    notifyListeners();
    
    if (_initializationSuccess == true) {
      debugPrint('✅ Hill Start: Initialization successful - ${feedback['message']}');
    } else {
      debugPrint('❌ Hill Start: Initialization failed - ${feedback['message']}');
    }
  }
  
  void clearInitializationFeedback() {
    _initializationMessage = null;
    _initializationSuccess = null;
    notifyListeners();
  }

  // Connect WebSocket when user clicks Connect button
  void connectWebSocket() {
    _enableWebSocket = true;
    connectToBridge();
    debugPrint('Hill Start WebSocket connection initiated by user');
    // Initialization request will be sent automatically when connection is confirmed
  }

  // Start the test - initialize Hill Start with current tag position
  void startTest() {
    if (!_isConnected) {
      debugPrint('Hill Start - Cannot start test: not connected to bridge');
      return;
    }
    
    if (_testStarted) {
      debugPrint('Hill Start - Test already started');
      return;
    }
    
    _testStarted = true;
    _currentStatus = 0;
    
    // Cancel any existing timers
    _progressUpdateTimer?.cancel();
    _progressUpdateTimer = null;
    
    // Send initialization message to bridge
    try {
      final initMessage = jsonEncode({
        'action': 'initialize',
        'tag_id': null  // Bridge will auto-detect tag (NOT 1-20)
      });
      _channel?.sink.add(initMessage);
      debugPrint('Hill Start - Test started, initialization sent to bridge');
    } catch (e) {
      debugPrint('Hill Start - Error sending initialization: $e');
    }
  }
  
  // Reset test state
  void resetTest() {
    _testStarted = false;
    _autoCompleted = false;
    _currentStatus = 0;
    progressValue = 0.5; // Reset to 50% (initial position)
    _progressUpdateTimer?.cancel();
    _progressUpdateTimer = null;
    notifyListeners();
  }

  // Complete and disconnect - save current state and disconnect
  void completeAndDisconnect() {
    // Save current progress state (0%, 50%, or 100%)
    debugPrint('Hill Start - Completed with progress: ${(progressValue * 100).toInt()}%');
    
    // Disconnect WebSocket but preserve progress state
    _channel?.sink.close();
    _channel = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _progressUpdateTimer?.cancel();
    _progressUpdateTimer = null;
    _isConnected = false;
    _enableWebSocket = false;
    // Note: We DO NOT reset _testStarted, _currentStatus, or progressValue to preserve state
    debugPrint('Hill Start - WebSocket disconnected and state saved at ${(progressValue * 100).toInt()}%');
    notifyListeners();
  }

  double getProgress() => progressValue;

  int getCheckCount(String key) => _checkCounts[key] ?? 0;

  void incrementCheck(String key) {
    _checkCounts[key] = (_checkCounts[key] ?? 0) + 1;
    notifyListeners();
  }

  void resetChecks() {
    _checkCounts.clear();
    notifyListeners();
  }

  double calculateTotalPenalty(String sectionTitle, List<CheckItem> checks) {
    double total = 0;
    for (var check in checks) {
      final key = '$sectionTitle-${check.description}';
      final count = getCheckCount(key);
      total += check.penaltyValue * count;
    }
    return total;
  }

  bool get testStarted => _testStarted;
  bool get autoCompleted => _autoCompleted;
  
  // Success message management
  String? get successMessage => _successMessage;
  bool get showSuccessMessage => _showSuccessMessage;
  bool get isSuccessful => _isSuccessful;
  void clearSuccessMessage() {
    _successMessage = null;
    _showSuccessMessage = false;
    _isSuccessful = true; // Reset to default
    notifyListeners();
  }
  
  @override
  void dispose() {
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    _progressUpdateTimer?.cancel();
    super.dispose();
  }
}

class CheckItem {
  final String abbreviation;
  final String description;
  final int penaltyValue;

  CheckItem({
    required this.abbreviation,
    required this.description,
    required this.penaltyValue,
  });
}

