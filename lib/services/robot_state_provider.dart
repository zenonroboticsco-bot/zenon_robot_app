import 'package:flutter/foundation.dart';
import 'api_service.dart';

class RobotStateProvider extends ChangeNotifier {
  bool _isConnected = false;
  bool _isRobotStarted = false;
  bool _isLiveModeEnabled = false;
  Map<String, dynamic> _currentState = {};
  String _statusMessage = 'Not connected';
  
  // Camera state
  bool _isCameraOn = false;
  Uint8List? _latestCameraImage;
  
  // Vision modes
  bool _isObjectFollowingActive = false;
  bool _isObjectDetectionActive = false;
  
  // Voice and AI
  bool _isVoiceListenerActive = false;
  bool _isAIConversationActive = false;

  // Getters
  bool get isConnected => _isConnected;
  bool get isRobotStarted => _isRobotStarted;
  bool get isLiveModeEnabled => _isLiveModeEnabled;
  Map<String, dynamic> get currentState => _currentState;
  String get statusMessage => _statusMessage;
  bool get isCameraOn => _isCameraOn;
  Uint8List? get latestCameraImage => _latestCameraImage;
  bool get isObjectFollowingActive => _isObjectFollowingActive;
  bool get isObjectDetectionActive => _isObjectDetectionActive;
  bool get isVoiceListenerActive => _isVoiceListenerActive;
  bool get isAIConversationActive => _isAIConversationActive;

  // Test connection (robot already running via run.sh)
  Future<void> testConnection() async {
    _statusMessage = 'Testing connection...';
    notifyListeners();
    
    final connected = await ApiService.testConnection();
    _isConnected = connected;
    _statusMessage = connected ? 'Robot Online' : 'Robot Offline';
    notifyListeners();
    
    if (connected) {
      await refreshRobotState();
    }
  }

  // Refresh robot state
  Future<void> refreshRobotState() async {
    try {
      final response = await ApiService.getRobotState();
      if (response['success'] == true) {
        _currentState = response;
        _isRobotStarted = true;
        _statusMessage = 'Robot Ready';
      } else {
        _statusMessage = 'Cannot read state';
        _isRobotStarted = false;
      }
    } catch (e) {
      _statusMessage = 'Error: $e';
      _isRobotStarted = false;
    }
    notifyListeners();
  }

  // Start robot (activates servos and systems)
  Future<bool> startRobot() async {
    if (!_isConnected) {
      _statusMessage = 'Cannot start - robot offline';
      notifyListeners();
      return false;
    }

    _statusMessage = 'Starting robot...';
    notifyListeners();
    
    final response = await ApiService.startRobot();
    if (response['success'] == true) {
      _isRobotStarted = true;
      _statusMessage = 'Robot Started';
      await refreshRobotState();
      notifyListeners();
      return true;
    } else {
      _statusMessage = 'Failed to start robot';
      notifyListeners();
      return false;
    }
  }

  // Shutdown robot (disables servos)
  Future<bool> shutdownRobot() async {
    _statusMessage = 'Shutting down robot...';
    notifyListeners();
    
    final response = await ApiService.shutdownRobot();
    if (response['success'] == true) {
      _isRobotStarted = false;
      _isLiveModeEnabled = false;
      _statusMessage = 'Robot Shutdown';
      notifyListeners();
      return true;
    } else {
      _statusMessage = 'Failed to shutdown robot';
      notifyListeners();
      return false;
    }
  }

  // Toggle Live Mode - Starts robot when enabled
  Future<void> toggleLiveMode(bool value) async {
    if (value) {
      // Turning ON Live Mode - Start the robot
      _statusMessage = 'Starting robot for Live Mode...';
      notifyListeners();
      
      final response = await ApiService.startRobot();
      if (response['success'] == true) {
        _isRobotStarted = true;
        _isLiveModeEnabled = true;
        _statusMessage = 'Live Mode ON - Robot Started';
        await refreshRobotState();
      } else {
        _isLiveModeEnabled = false;
        _statusMessage = 'Failed to start robot';
      }
    } else {
      // Turning OFF Live Mode - Disable sliders only
      _isLiveModeEnabled = false;
      _statusMessage = 'Live Mode OFF';
    }
    notifyListeners();
  }

  // Update joint positions (only works when Live Mode is ON)
  Future<bool> updateJointPositions(Map<String, double> commands) async {
    if (!_isLiveModeEnabled) return false;
    
    final response = await ApiService.updateRobotState(commands);
    if (response['success'] == true) {
      await refreshRobotState();
      return true;
    }
    return false;
  }

  // Run motion - SIMPLIFIED: Just run if connected
  Future<bool> runMotion(String motionName) async {
    if (!_isConnected) {
      _statusMessage = 'Robot offline - cannot run motion';
      notifyListeners();
      return false;
    }
    
    _statusMessage = 'Running: $motionName';
    notifyListeners();
    
    final response = await ApiService.runMotion(motionName);
    final success = response['success'] == true;
    
    _statusMessage = success 
        ? 'Completed: $motionName' 
        : 'Failed: $motionName';
    notifyListeners();
    
    if (success) {
      await refreshRobotState();
    }
    
    return success;
  }

  // Camera control
  Future<void> toggleCamera() async {
    final newState = !_isCameraOn;
    final response = await ApiService.cameraControl(newState);
    
    if (response['success'] == true) {
      _isCameraOn = newState;
      if (!newState) {
        _latestCameraImage = null;
      }
      notifyListeners();
    }
  }

  Future<void> refreshCameraImage() async {
    if (!_isCameraOn) return;
    
    final imageData = await ApiService.getCameraImage();
    if (imageData != null) {
      _latestCameraImage = imageData;
      notifyListeners();
    }
  }

  // Object following
  Future<void> toggleObjectFollowing() async {
    if (_isObjectFollowingActive) {
      final response = await ApiService.stopObjectFollowing();
      if (response['success'] == true) {
        _isObjectFollowingActive = false;
        _statusMessage = 'Object following stopped';
      }
    } else {
      final response = await ApiService.startObjectFollowing();
      if (response['success'] == true) {
        _isObjectFollowingActive = true;
        _statusMessage = 'Object following started';
      }
    }
    notifyListeners();
  }

  // Object detection
  Future<void> toggleObjectDetection() async {
    if (_isObjectDetectionActive) {
      final response = await ApiService.stopObjectDetection();
      if (response['success'] == true) {
        _isObjectDetectionActive = false;
        _statusMessage = 'Object detection stopped';
      }
    } else {
      final response = await ApiService.startObjectDetection();
      if (response['success'] == true) {
        _isObjectDetectionActive = true;
        _statusMessage = 'Object detection started';
      }
    }
    notifyListeners();
  }

  // Voice listener
  Future<void> toggleVoiceListener() async {
    if (_isVoiceListenerActive) {
      final response = await ApiService.stopVoiceListener();
      if (response['success'] == true) {
        _isVoiceListenerActive = false;
        _statusMessage = 'Voice listener stopped';
      }
    } else {
      final response = await ApiService.startVoiceListener();
      if (response['success'] == true) {
        _isVoiceListenerActive = true;
        _statusMessage = 'Voice listener started';
      }
    }
    notifyListeners();
  }

  // AI Conversation
  Future<void> toggleAIConversation() async {
    if (_isAIConversationActive) {
      final response = await ApiService.stopAIConversation();
      if (response['success'] == true) {
        _isAIConversationActive = false;
        _statusMessage = 'AI conversation stopped';
      }
    } else {
      final response = await ApiService.startAIConversation();
      if (response['success'] == true) {
        _isAIConversationActive = true;
        _statusMessage = 'AI conversation started';
      }
    }
    notifyListeners();
  }

  // Set face expression
  Future<void> setFaceExpression(String expression) async {
    await ApiService.setFaceExpression(expression);
    _statusMessage = 'Face: $expression';
    notifyListeners();
  }
}
