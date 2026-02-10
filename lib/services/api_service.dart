import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'debug_logger.dart';

class ApiService {
  static const String baseUrl = 'http://10.255.254.75:8000';
  static const Duration timeout = Duration(seconds: 10);
  static final _logger = DebugLogger();

  // Robot Control
  static Future<Map<String, dynamic>> startRobot() async {
    _logger.log('Starting robot...', level: LogLevel.api, endpoint: '/robot/start');
    final result = await _post('/robot/start');
    _logger.log(
      result['success'] == true ? 'Robot started successfully' : 'Failed to start robot',
      level: result['success'] == true ? LogLevel.success : LogLevel.error,
      data: result,
    );
    return result;
  }

  static Future<Map<String, dynamic>> shutdownRobot() async {
    _logger.log('Shutting down robot...', level: LogLevel.api, endpoint: '/robot/shutdown');
    final result = await _post('/robot/shutdown');
    _logger.log(
      result['success'] == true ? 'Robot shutdown successfully' : 'Failed to shutdown robot',
      level: result['success'] == true ? LogLevel.success : LogLevel.error,
      data: result,
    );
    return result;
  }

  static Future<Map<String, dynamic>> getRobotState() async {
    final result = await _get('/robot/state');
    if (result['success'] != true) {
      _logger.log('Failed to get robot state', level: LogLevel.warning, endpoint: '/robot/state');
    }
    return result;
  }

  static Future<Map<String, dynamic>> setRobotState(Map<String, double> commands) async {
    _logger.log('Setting robot state', level: LogLevel.api, endpoint: '/robot/state', data: commands);
    return await _post('/robot/state', body: {'commands': commands});
  }

  static Future<Map<String, dynamic>> updateRobotState(Map<String, double> commands) async {
    final result = await _post('/robot/update_state', body: commands);
    if (result['success'] != true) {
      _logger.log('Failed to update robot state', level: LogLevel.warning, data: commands);
    }
    return result;
  }

  static Future<Map<String, dynamic>> getJointSpecs() async {
    return await _get('/robot/joints');
  }

  // Motion Control
  static Future<Map<String, dynamic>> runMotion(String motionName) async {
    _logger.log('Running motion: $motionName', level: LogLevel.api, endpoint: '/robot/run_scenario');
    final result = await _post('/robot/run_scenario', body: {'name': motionName});
    _logger.log(
      result['success'] == true ? '✓ Motion "$motionName" completed' : '✗ Motion "$motionName" failed',
      level: result['success'] == true ? LogLevel.success : LogLevel.error,
    );
    return result;
  }

  // Face Control
  static Future<Map<String, dynamic>> setFaceExpression(String expression) async {
    _logger.log('Setting face expression: $expression', level: LogLevel.info, endpoint: '/robot_face/expression/$expression');
    return await _post('/robot_face/expression/$expression');
  }

  // Camera Control
  static Future<Map<String, dynamic>> cameraControl(bool enable) async {
    final state = enable ? 'on' : 'off';
    _logger.log('Camera power: $state', level: LogLevel.api, endpoint: '/cam/$state');
    final result = await _post('/cam/$state');
    _logger.log(
      result['success'] == true ? 'Camera $state successful' : 'Camera $state failed',
      level: result['success'] == true ? LogLevel.success : LogLevel.error,
    );
    return result;
  }

  static Future<Uint8List?> getCameraImage() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cam/get/image'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        _logger.log('Camera image failed: HTTP ${response.statusCode}', level: LogLevel.warning);
      }
      return null;
    } catch (e) {
      _logger.log('Camera image error: $e', level: LogLevel.error);
      return null;
    }
  }

  // Audio Control
  static Future<Map<String, dynamic>> respeakerControl(bool enable) async {
    final state = enable ? 'on' : 'off';
    _logger.log('Respeaker: $state', level: LogLevel.info, endpoint: '/respeaker/$state');
    return await _post('/respeaker/$state');
  }

  static Future<Map<String, dynamic>> getAudioDirection() async {
    return await _get('/respeaker/get/dir');
  }

  static Future<Map<String, dynamic>> startRecording() async {
    _logger.log('Starting audio recording', level: LogLevel.info, endpoint: '/recorder/start');
    return await _post('/recorder/start');
  }

  static Future<Map<String, dynamic>> stopRecording() async {
    _logger.log('Stopping audio recording', level: LogLevel.info, endpoint: '/recorder/stop');
    return await _post('/recorder/stop');
  }

  static Future<Map<String, dynamic>> getAudioList() async {
    return await _get('/audio/list');
  }

  static Future<Map<String, dynamic>> playAudio(String path) async {
    _logger.log('Playing audio: $path', level: LogLevel.info, endpoint: '/audio/play');
    return await _post('/audio/play', body: {'address': path});
  }

  // Vision Control
  static Future<Map<String, dynamic>> startObjectFollowing() async {
    _logger.log('Starting object following', level: LogLevel.api, endpoint: '/vision/follow_obj/start');
    final result = await _post('/vision/follow_obj/start');
    _logger.log(
      result['success'] == true ? 'Object following started' : 'Failed to start object following',
      level: result['success'] == true ? LogLevel.success : LogLevel.error,
    );
    return result;
  }

  static Future<Map<String, dynamic>> stopObjectFollowing() async {
    _logger.log('Stopping object following', level: LogLevel.api, endpoint: '/vision/follow_obj/stop');
    return await _post('/vision/follow_obj/stop');
  }

  static Future<Map<String, dynamic>> startObjectDetection() async {
    _logger.log('Starting object detection', level: LogLevel.api, endpoint: '/vision/yolo/start');
    final result = await _post('/vision/yolo/start');
    _logger.log(
      result['success'] == true ? 'Object detection started' : 'Failed to start object detection',
      level: result['success'] == true ? LogLevel.success : LogLevel.error,
    );
    return result;
  }

  static Future<Map<String, dynamic>> stopObjectDetection() async {
    _logger.log('Stopping object detection', level: LogLevel.api, endpoint: '/vision/yolo/stop');
    return await _post('/vision/yolo/stop');
  }

  // Voice Control
  static Future<Map<String, dynamic>> startVoiceListener() async {
    _logger.log('Starting voice listener', level: LogLevel.api, endpoint: '/robot/listen');
    return await _post('/robot/listen');
  }

  static Future<Map<String, dynamic>> stopVoiceListener() async {
    _logger.log('Stopping voice listener', level: LogLevel.api, endpoint: '/robot/listen/stop');
    return await _post('/robot/listen/stop');
  }

  static Future<Map<String, dynamic>> setVoiceLanguage(String langCode) async {
    _logger.log('Setting voice language: $langCode', level: LogLevel.info, endpoint: '/robot/listen/lang/$langCode');
    return await _post('/robot/listen/lang/$langCode');
  }

  // AI Chatbot
  static Future<Map<String, dynamic>> startAIConversation() async {
    _logger.log('Starting AI conversation', level: LogLevel.api, endpoint: '/ai/listen/start');
    return await _post('/ai/listen/start');
  }

  static Future<Map<String, dynamic>> stopAIConversation() async {
    _logger.log('Stopping AI conversation', level: LogLevel.api, endpoint: '/ai/listen/stop');
    return await _post('/ai/listen/stop');
  }

  static Future<Map<String, dynamic>> aiTalk(String text, {String? lang}) async {
    _logger.log('AI Talk: $text', level: LogLevel.info, endpoint: '/ai/talk');
    return await _post('/ai/talk', body: {'text': text, 'lang': lang});
  }

  static Future<Map<String, dynamic>> aiAsk(String prompt, {String? lang}) async {
    _logger.log('AI Ask: $prompt', level: LogLevel.info, endpoint: '/ai/ask');
    return await _post('/ai/ask', body: {'prompt': prompt, 'lang': lang});
  }

  static Future<Map<String, dynamic>> setAILanguage(String langCode) async {
    return await _post('/ai/lang/$langCode');
  }

  static Future<Map<String, dynamic>> getAIStatus() async {
    return await _get('/ai/status');
  }

  // Helper Methods
  static Future<Map<String, dynamic>> _get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      return _handleResponse(response, endpoint);
    } catch (e) {
      _logger.log('GET $endpoint error: $e', level: LogLevel.error);
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> _post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: body != null ? json.encode(body) : null,
      ).timeout(timeout);

      return _handleResponse(response, endpoint);
    } catch (e) {
      _logger.log('POST $endpoint error: $e', level: LogLevel.error);
      return {'success': false, 'error': e.toString()};
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response, String endpoint) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        return {'success': true, 'data': response.body};
      }
    } else {
      _logger.log(
        'HTTP ${response.statusCode} on $endpoint',
        level: LogLevel.error,
        data: response.body,
      );
      return {
        'success': false,
        'error': 'HTTP ${response.statusCode}: ${response.body}',
      };
    }
  }

  // Connection Test
  static Future<bool> testConnection() async {
    try {
      _logger.log('Testing connection...', level: LogLevel.info);
      final response = await http.get(
        Uri.parse('$baseUrl/robot/state'),
      ).timeout(const Duration(seconds: 3));
      
      final connected = response.statusCode == 200;
      _logger.log(
        connected ? 'Connection successful' : 'Connection failed',
        level: connected ? LogLevel.success : LogLevel.error,
      );
      return connected;
    } catch (e) {
      _logger.log('Connection test failed: $e', level: LogLevel.error);
      return false;
    }
  }
}
