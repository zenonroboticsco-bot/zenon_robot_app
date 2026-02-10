import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/debug_logger.dart';
import '../services/robot_state_provider.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  bool _autoScroll = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.success:
        return Colors.green;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.api:
        return Colors.blue;
      case LogLevel.info:
      default:
        return Colors.grey;
    }
  }

  IconData _getLevelIcon(LogLevel level) {
    switch (level) {
      case LogLevel.success:
        return Icons.check_circle;
      case LogLevel.error:
        return Icons.error;
      case LogLevel.warning:
        return Icons.warning;
      case LogLevel.api:
        return Icons.api;
      case LogLevel.info:
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1a1a2e),
            const Color(0xFF16213e).withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Status Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<RobotStateProvider>(
                builder: (context, provider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.monitor_heart, color: Color(0xFF667EEA)),
                          SizedBox(width: 8),
                          Text(
                            'System Status',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStatusRow('Connection', provider.isConnected ? 'Online' : 'Offline', 
                        provider.isConnected ? Colors.green : Colors.red),
                      _buildStatusRow('Robot Started', provider.isRobotStarted ? 'Yes' : 'No',
                        provider.isRobotStarted ? Colors.green : Colors.grey),
                      _buildStatusRow('Live Mode', provider.isLiveModeEnabled ? 'Active' : 'Inactive',
                        provider.isLiveModeEnabled ? Colors.green : Colors.grey),
                      _buildStatusRow('Camera', provider.isCameraOn ? 'ON' : 'OFF',
                        provider.isCameraOn ? Colors.green : Colors.grey),
                      _buildStatusRow('Voice Listener', provider.isVoiceListenerActive ? 'Active' : 'Inactive',
                        provider.isVoiceListenerActive ? Colors.green : Colors.grey),
                      _buildStatusRow('AI Conversation', provider.isAIConversationActive ? 'Active' : 'Inactive',
                        provider.isAIConversationActive ? Colors.green : Colors.grey),
                      _buildStatusRow('Object Following', provider.isObjectFollowingActive ? 'Active' : 'Inactive',
                        provider.isObjectFollowingActive ? Colors.green : Colors.grey),
                      _buildStatusRow('Object Detection', provider.isObjectDetectionActive ? 'Active' : 'Inactive',
                        provider.isObjectDetectionActive ? Colors.green : Colors.grey),
                    ],
                  );
                },
              ),
            ),
          ),

          // Log Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.article, color: Color(0xFF667EEA), size: 20),
                              const SizedBox(width: 8),
                              Consumer<DebugLogger>(
                                builder: (context, logger, child) {
                                  return Text(
                                    '${logger.logs.length} Logs',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  );
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _autoScroll ? Icons.vertical_align_bottom : Icons.pause,
                                  color: _autoScroll ? Colors.green : Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _autoScroll = !_autoScroll),
                                tooltip: _autoScroll ? 'Auto-scroll ON' : 'Auto-scroll OFF',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                                onPressed: () {
                                  context.read<DebugLogger>().clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Logs cleared')),
                                  );
                                },
                                tooltip: 'Clear logs',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Logs List
          Expanded(
            child: Card(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Consumer<DebugLogger>(
                builder: (context, logger, child) {
                  if (logger.logs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No logs yet',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  if (_autoScroll && logger.logs.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(0);
                      }
                    });
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: logger.logs.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final log = logger.logs[index];
                      final color = _getLevelColor(log.level);
                      final icon = _getLevelIcon(log.level);

                      return InkWell(
                        onTap: () {
                          if (log.data != null || log.endpoint != null) {
                            _showLogDetails(context, log);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Time
                              SizedBox(
                                width: 60,
                                child: Text(
                                  log.timeString,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[400],
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Icon
                              Icon(icon, size: 16, color: color),
                              const SizedBox(width: 8),

                              // Message
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log.message,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: color,
                                      ),
                                    ),
                                    if (log.endpoint != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          log.endpoint!,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500],
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogDetails(BuildContext context, LogEntry log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getLevelIcon(log.level), color: _getLevelColor(log.level)),
            const SizedBox(width: 8),
            const Text('Log Details'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Time', log.timestamp.toString()),
              if (log.endpoint != null)
                _buildDetailRow('Endpoint', log.endpoint!),
              _buildDetailRow('Message', log.message),
              if (log.data != null)
                _buildDetailRow('Data', log.data.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: 'Time: ${log.timestamp}\n'
                      'Endpoint: ${log.endpoint ?? 'N/A'}\n'
                      'Message: ${log.message}\n'
                      'Data: ${log.data ?? 'N/A'}',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
