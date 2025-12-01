import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';

class CircleData {
  final double x;
  final double y;
  final Color color;

  CircleData({required this.x, required this.y, required this.color});
}

enum DetectionSystem {
  aprilTag,
  esp32Touch,
}

class Page2Backend extends ChangeNotifier {
  double circleSize = 30.0;
  Color middleCardColor = Colors.grey.shade200;
  
  // List of 7 items (0 = green, 1 = red) representing circle colors
  List<int> circleColorData = [];
  
  // Rectangle color based on 9th digit (0 = green, 1 = red)
  Color rectangleColor = Colors.grey;
  
  // WebSocket connection
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  bool _enableWebSocket = true; // Flag to enable/disable WebSocket - re-enabled
  
  // System selection: April Tag or ESP32 Touch
  DetectionSystem _detectionSystem = DetectionSystem.aprilTag;
  DetectionSystem get detectionSystem => _detectionSystem;
  
  // April Tag Bridge connection settings
  String _aprilTagIp = "172.16.24.23"; // April Tag Bridge (can be updated via settings)
  static const int _aprilTagPort = 8765; // Parallel Parking port for April Tag
  
  // ESP32 Touch connection settings
  String _esp32Ip = "192.168.1.100"; // ESP32 default IP (can be updated via settings)
  static const int _esp32Port = 81; // ESP32 default WebSocket port
  
  // Current connection IP and port (based on selected system)
  String get _currentIp => _detectionSystem == DetectionSystem.aprilTag ? _aprilTagIp : _esp32Ip;
  int get _currentPort => _detectionSystem == DetectionSystem.aprilTag ? _aprilTagPort : _esp32Port;

  // Method to set detection system (April Tag or ESP32 Touch)
  void setDetectionSystem(DetectionSystem system) {
    if (_detectionSystem != system) {
      _detectionSystem = system;
      // Disconnect and reconnect if currently connected
      if (_isConnected) {
        _channel?.sink.close();
        _channel = null;
        _isConnected = false;
        _reconnectTimer?.cancel();
        // Reconnect will happen automatically via _scheduleReconnect
        _scheduleReconnect();
      }
      notifyListeners();
    }
  }
  
  // Method to update April Tag IP address from settings
  void updateAprilTagIp(String ip) {
    if (_aprilTagIp != ip) {
      _aprilTagIp = ip;
      // Disconnect and reconnect if currently connected and using April Tag
      if (_isConnected && _detectionSystem == DetectionSystem.aprilTag) {
        _channel?.sink.close();
        _channel = null;
        _isConnected = false;
        _reconnectTimer?.cancel();
        _scheduleReconnect();
      }
      notifyListeners();
    }
  }
  
  // Method to update ESP32 IP address from settings
  void updateEsp32Ip(String ip) {
    if (_esp32Ip != ip) {
      _esp32Ip = ip;
      // Disconnect and reconnect if currently connected and using ESP32
      if (_isConnected && _detectionSystem == DetectionSystem.esp32Touch) {
        _channel?.sink.close();
        _channel = null;
        _isConnected = false;
        _reconnectTimer?.cancel();
        _scheduleReconnect();
      }
      notifyListeners();
    }
  }
  
  // Legacy method for backward compatibility
  void updateIpAddress(String ip) {
    if (_detectionSystem == DetectionSystem.aprilTag) {
      updateAprilTagIp(ip);
    } else {
      updateEsp32Ip(ip);
    }
  }
  
  // Getters for IP addresses/ports
  String get aprilTagIp => _aprilTagIp;
  String get esp32Ip => _esp32Ip;
  int get aprilTagPort => _aprilTagPort;
  int get esp32Port => _esp32Port;
  String get activeTargetIp => _currentIp;
  int get activeTargetPort => _currentPort;

  Page2Backend() {
    // Initialize with default values
    circleColorData = [2, 2, 2, 2, 2, 2, 2];
    _previousStatusArray = [2, 2, 2, 2, 2, 2, 2]; // Initialize previous array to match
    updateCircleColors();
    notifyListeners();
    
    // Don't automatically connect - wait for user to click Connect button
    _enableWebSocket = false;
  }

  // Enable/disable WebSocket connection
  void setWebSocketEnabled(bool enabled) {
    _enableWebSocket = enabled;
    if (enabled) {
      connectToESP32();
    } else {
      disconnectFromESP32();
    }
  }

  // Disconnect from ESP32
  void disconnectFromESP32() {
    _channel?.sink.close();
    _channel = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _isConnected = false;
  }

  // Connect to WebSocket (ESP32 Touch or April Tag Bridge)
  void connectToESP32() {
    if (!_enableWebSocket) {
      return; // Silent return when disabled
    }
    
    try {
      final uri = Uri.parse('ws://$_currentIp:$_currentPort');
      debugPrint('Parallel Parking - Connecting to ${_detectionSystem == DetectionSystem.aprilTag ? "April Tag" : "ESP32 Touch"} at $uri');
      _channel = WebSocketChannel.connect(uri);
      
      _channel!.stream.listen(
        (data) {
          if (_enableWebSocket) {
            // Only set connected to true when we actually receive data
            if (!_isConnected) {
              _isConnected = true;
              debugPrint('Parallel Parking - Connected to ${_detectionSystem == DetectionSystem.aprilTag ? "April Tag" : "ESP32 Touch"}');
              notifyListeners(); // Update UI to show connected status
              
              // Send initialization request only for April Tag system
              if (_detectionSystem == DetectionSystem.aprilTag) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (_isConnected && _channel != null) {
                    try {
                      final initMessage = jsonEncode({
                        'action': 'initialize'
                      });
                      _channel?.sink.add(initMessage);
                    } catch (e) {
                      // Silent fail
                    }
                  }
                });
              }
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
                // Otherwise, it's touch/status data
                _handleTouchData(data);
              } else {
                // Legacy format (direct array)
                _handleTouchData(data);
              }
            } catch (e) {
              // Not JSON, treat as legacy format
              _handleTouchData(data);
            }
          }
        },
        onError: (error) {
          if (_enableWebSocket) {
            debugPrint('Parallel Parking - WebSocket error: $error');
            _isConnected = false;
            notifyListeners(); // Update UI to show disconnected status
            _scheduleReconnect();
          }
        },
        onDone: () {
          if (_enableWebSocket) {
            debugPrint('Parallel Parking - WebSocket connection closed');
            _isConnected = false;
            notifyListeners(); // Update UI to show disconnected status
            _scheduleReconnect();
          }
        },
      );
    } catch (e) {
      if (_enableWebSocket) {
        debugPrint('Parallel Parking - Failed to connect to Bridge: $e');
        _isConnected = false;
        notifyListeners(); // Update UI to show disconnected status
        _scheduleReconnect();
      }
    }
  }

  // Handle incoming touch data from ESP32
  void _handleTouchData(dynamic data) {
    if (!_enableWebSocket) return; // Don't process data if disabled
    
    try {
      final dataString = data.toString();
      dynamic jsonData;
      
      // Try to parse as JSON first
      try {
        jsonData = jsonDecode(dataString);
      } catch (e) {
        // If JSON decode fails, try parsing as direct array string
        // Check if it looks like an array string like "[0, 1, 2]"
        if (dataString.trim().startsWith('[') && dataString.trim().endsWith(']')) {
          jsonData = jsonDecode(dataString);
        } else {
          return;
        }
      }
      
      List<int>? statusArray;
      
      // Handle different data formats
      if (jsonData is List) {
        // Direct array format - most common from tag monitoring system
        statusArray = jsonData.map((state) => state as int).toList();
      } else if (jsonData is Map<String, dynamic>) {
        // JSON object format
        if (jsonData.containsKey('touchStates')) {
          // Format with touchStates key
          final List<dynamic> touchStates = jsonData['touchStates'];
          statusArray = touchStates.map((state) => state as int).toList();
        } else if (jsonData.containsKey('status_array')) {
          // Format with status_array key (from tag monitoring system)
          final List<dynamic> statusArrayData = jsonData['status_array'];
          statusArray = statusArrayData.map((state) => state as int).toList();
        } else if (jsonData.containsKey('status')) {
          // Single status value (not applicable for parallel parking, but handle gracefully)
          return;
        } else {
          return;
        }
      } else {
        return;
      }
      
      // Update circleColorData with status array (statusArray is guaranteed to be non-null at this point)
      circleColorData = statusArray;
      
      // Ensure we have exactly 7 items
      if (circleColorData.length != 7) {
        // Pad or truncate to 7 items
        while (circleColorData.length < 7) {
          circleColorData.add(0);
        }
        if (circleColorData.length > 7) {
          circleColorData = circleColorData.sublist(0, 7);
        }
      }
      
      // Update rectangle color based on 9th digit (if available in original format)
      if (jsonData is Map<String, dynamic> && jsonData.containsKey('touchStates') && (jsonData['touchStates'] as List).length >= 9) {
        final int ninthDigit = (jsonData['touchStates'] as List)[8] as int;
        rectangleColor = ninthDigit == 1 ? Colors.green : Colors.grey;
      }
      
      updateCircleColors();
      
      // Check for bump (status 0 or 2) - IMPORTANT: Check BEFORE updating UI
      _checkForBump();
      
      notifyListeners();
    } catch (e) {
      // Try to parse as direct array if JSON parsing fails
      try {
        final directArray = jsonDecode(data.toString()) as List;
        if (directArray.isNotEmpty) {
          circleColorData = directArray.map((state) => state as int).toList();
          if (circleColorData.length == 7) {
            updateCircleColors();
            _checkForBump();
            notifyListeners();
          }
        }
      } catch (e2) {
        // Silent fail - invalid data format
      }
    }
  }

  // Schedule reconnection attempt
  void _scheduleReconnect() {
    if (!_enableWebSocket) return;
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected && _enableWebSocket) {
        debugPrint('Parallel Parking - Attempting to reconnect to ${_detectionSystem == DetectionSystem.aprilTag ? "April Tag Bridge" : "ESP32 Touch"}...');
        connectToESP32();
      }
    });
  }

  // Manual reconnection
  void reconnect() {
    if (!_enableWebSocket) {
      return;
    }
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    connectToESP32();
  }

  // Check connection status
  bool get isConnected => _isConnected;
  bool get isWebSocketEnabled => _enableWebSocket;

  // List to store recorded pole states
  final List<List<int>> _recordedPoleStates = [];
  
  // Initialization feedback state
  String? _initializationMessage;
  bool? _initializationSuccess;
  
  // Bump detection state
  bool _showBumpDialog = false;
  List<int> _previousStatusArray = []; // Track previous status to detect changes (like Hill Start)
  bool get showBumpDialog => _showBumpDialog;
  
  void _checkForBump() {
    // Similar to Hill Start: detect when a pole CHANGES to 0 (moved/bumped) or 2 (not detected)
    // This indicates a pole was hit or moved
    if (!_isConnected) {
      return; // Don't check if not connected
    }
    
    if (circleColorData.isEmpty) {
      return; // Don't check if no data
    }
    
    // Ensure previous array is same length as current
    if (_previousStatusArray.length != circleColorData.length) {
      _previousStatusArray = List.from(circleColorData);
      return; // Don't trigger on resize
    }
    
    // Check if any pole CHANGED to 0 (moved/bumped) or 2 (not detected)
    // This is similar to Hill Start checking if status changed
    bool bumpDetected = false;
    
    for (int i = 0; i < circleColorData.length && i < _previousStatusArray.length; i++) {
      final currentStatus = circleColorData[i];
      final previousStatus = _previousStatusArray[i];
      
      // Detect change TO 0 or 2 (pole was bumped or moved)
      // Only trigger if previous status was 1 (OK) and now it's 0 or 2
      if (previousStatus == 1 && (currentStatus == 0 || currentStatus == 2)) {
        bumpDetected = true;
        break;
      }
    }
    
    // Update previous array for next check (ALWAYS update, even if no bump detected)
    _previousStatusArray = List.from(circleColorData);
    
    // Show dialog when bump is detected (similar to Hill Start showing dialog on status change)
    if (bumpDetected && !_showBumpDialog) {
      _showBumpDialog = true;
      notifyListeners(); // This will trigger the UI to show dialog (like Hill Start)
    }
  }
  
  void clearBumpDialog() {
    _showBumpDialog = false;
    notifyListeners();
  }
  
  void endTestDueToBump() {
    _showBumpDialog = false;
    notifyListeners();
  }
  
  String? get initializationMessage => _initializationMessage;
  bool? get initializationSuccess => _initializationSuccess;
  
  void _handleInitializeFeedback(Map<String, dynamic> feedback) {
    _initializationSuccess = feedback['success'] as bool?;
    _initializationMessage = feedback['message'] as String?;
    notifyListeners();
    
  }
  
  void clearInitializationFeedback() {
    _initializationMessage = null;
    _initializationSuccess = null;
    notifyListeners();
  }

  // Connect WebSocket when user clicks Connect button
  void connectWebSocket() {
    _enableWebSocket = true;
    connectToESP32();
    // Initialization request will be sent automatically when connection is confirmed
  }

  // Complete and disconnect - record current pole states and disconnect
  void completeAndDisconnect() {
    // Record current pole states
    _recordedPoleStates.add(List.from(circleColorData));
    
    // Disconnect WebSocket
    _enableWebSocket = false;
    disconnectFromESP32();
  }

  // Get recorded pole states
  List<List<int>> getRecordedPoleStates() {
    return List.from(_recordedPoleStates);
  }

  // Clear recorded pole states
  void clearRecordedPoleStates() {
    _recordedPoleStates.clear();
  }

  // Update circle colors based on the data
  // Status mapping: 1 = green (OK), 0 = red (error), 2 = grey (not detected)
  void updateCircleColors() {
    for (int i = 0; i < circles.length && i < circleColorData.length; i++) {
      Color circleColor;
      if (circleColorData[i] == 1) {
        circleColor = Colors.green; // Tag is OK
      } else if (circleColorData[i] == 0) {
        circleColor = Colors.red; // Tag moved or not facing north
      } else {
        circleColor = Colors.grey; // Tag not detected or not initialized
      }
      
      circles[i] = CircleData(
        x: circles[i].x,
        y: circles[i].y,
        color: circleColor,
      );
    }
  }

  // Get the current circle color data
  List<int> getCircleColorData() {
    return List.from(circleColorData);
  }

  void setCircleSize(double newSize) {
    circleSize = newSize;
    notifyListeners();
  }

  void setCardBackgroundColor(Color color) {
    middleCardColor = color;
    notifyListeners();
  }

  // Circles positioning for middle card
  List<CircleData> circles = [
    CircleData(x: 0.9, y: 0.1, color: Colors.red),
    CircleData(x: 0.5, y: 0.1, color: Colors.red),
    CircleData(x: 0.1, y: 0.1, color: Colors.red),
    CircleData(x: 0.1, y: 0.5, color: Colors.red),
    CircleData(x: 0.1, y: 0.9, color: Colors.red),
    CircleData(x: 0.5, y: 0.9, color: Colors.red),
    CircleData(x: 0.9, y: 0.9, color: Colors.red),
  ];

  // Checklist counts
  final Map<String, int> _checkCounts = {};

  int getCheckCount(String key) => _checkCounts[key] ?? 0;

  void incrementCheck(String key) {
    _checkCounts[key] = (_checkCounts[key] ?? 0) + 1;
    notifyListeners();
  }

  void resetChecks() {
    _checkCounts.clear();
    notifyListeners();
  }

  void printCheckCounts() {
    _checkCounts.forEach((key, value) {
    });
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    super.dispose();
  }
}
