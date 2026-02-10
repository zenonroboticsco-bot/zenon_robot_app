import 'package:flutter/foundation.dart';

class DebugLogger extends ChangeNotifier {
  static final DebugLogger _instance = DebugLogger._internal();
  factory DebugLogger() => _instance;
  DebugLogger._internal();

  final List<LogEntry> _logs = [];
  final int _maxLogs = 200; // Keep last 200 logs

  List<LogEntry> get logs => List.unmodifiable(_logs);

  void log(String message, {LogLevel level = LogLevel.info, String? endpoint, dynamic data}) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      message: message,
      level: level,
      endpoint: endpoint,
      data: data,
    );

    _logs.insert(0, entry); // Add to beginning
    
    // Keep only last N logs
    if (_logs.length > _maxLogs) {
      _logs.removeRange(_maxLogs, _logs.length);
    }

    notifyListeners();
  }

  void clear() {
    _logs.clear();
    notifyListeners();
  }
}

enum LogLevel {
  info,
  success,
  warning,
  error,
  api,
}

class LogEntry {
  final DateTime timestamp;
  final String message;
  final LogLevel level;
  final String? endpoint;
  final dynamic data;

  LogEntry({
    required this.timestamp,
    required this.message,
    required this.level,
    this.endpoint,
    this.data,
  });

  String get timeString {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}:'
           '${timestamp.second.toString().padLeft(2, '0')}';
  }
}
