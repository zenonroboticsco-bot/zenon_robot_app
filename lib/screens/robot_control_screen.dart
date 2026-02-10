import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/robot_state_provider.dart';

class RobotControlScreen extends StatefulWidget {
  const RobotControlScreen({super.key});

  @override
  State<RobotControlScreen> createState() => _RobotControlScreenState();
}

class _RobotControlScreenState extends State<RobotControlScreen> {
  final List<String> _faceExpressions = [
    'default',
    'happy',
    'sad',
    'angry',
    'surprised',
    'thinking',
    'sleeping',
    'excited',
  ];

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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Manual Movement Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.gamepad, color: Color(0xFF667EEA)),
                        SizedBox(width: 8),
                        Text(
                          'Manual Movement',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // D-pad Style Controls
                    Center(
                      child: Column(
                        children: [
                          // Forward button
                          _buildDirectionButton(
                            icon: Icons.arrow_upward,
                            label: 'Forward',
                            onPressed: () => _quickMotion('move_forward'),
                          ),
                          const SizedBox(height: 8),
                          
                          // Left, Stop, Right buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildDirectionButton(
                                icon: Icons.arrow_back,
                                label: 'Left',
                                onPressed: () => _quickMotion('turn_left'),
                              ),
                              const SizedBox(width: 8),
                              _buildDirectionButton(
                                icon: Icons.stop,
                                label: 'Stop',
                                onPressed: () => _quickMotion('wheels_stop'),
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              _buildDirectionButton(
                                icon: Icons.arrow_forward,
                                label: 'Right',
                                onPressed: () => _quickMotion('turn_right'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Backward button
                          _buildDirectionButton(
                            icon: Icons.arrow_downward,
                            label: 'Backward',
                            onPressed: () => _quickMotion('move_backward'),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Quick Actions
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildQuickActionChip('Spin', Icons.refresh, () => _quickMotion('spin')),
                        _buildQuickActionChip('Stand', Icons.accessibility, () => _quickMotion('stand')),
                        _buildQuickActionChip('Calibrate', Icons.tune, () => _quickMotion('calibrate')),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Face Expressions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.mood, color: Color(0xFF667EEA)),
                        SizedBox(width: 8),
                        Text(
                          'Face Expressions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _faceExpressions.map((expr) {
                        return ActionChip(
                          label: Text(expr.toUpperCase()),
                          avatar: Icon(_getFaceIcon(expr), size: 18),
                          onPressed: () => _setFace(expr),
                          backgroundColor: const Color(0xFF667EEA).withOpacity(0.3),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Audio & Voice Control
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.mic, color: Color(0xFF667EEA)),
                        SizedBox(width: 8),
                        Text(
                          'Voice & Audio',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Consumer<RobotStateProvider>(
                      builder: (context, provider, child) {
                        return Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Voice Listener'),
                              subtitle: Text(
                                provider.isVoiceListenerActive ? 'Active' : 'Inactive',
                              ),
                              value: provider.isVoiceListenerActive,
                              onChanged: (_) => provider.toggleVoiceListener(),
                              activeColor: const Color(0xFF667EEA),
                            ),
                            SwitchListTile(
                              title: const Text('AI Conversation'),
                              subtitle: Text(
                                provider.isAIConversationActive ? 'Active' : 'Inactive',
                              ),
                              value: provider.isAIConversationActive,
                              onChanged: (_) => provider.toggleAIConversation(),
                              activeColor: const Color(0xFF764BA2),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return SizedBox(
      width: 80,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? const Color(0xFF667EEA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String label, IconData icon, VoidCallback onPressed) {
    return ActionChip(
      label: Text(label),
      avatar: Icon(icon, size: 18),
      onPressed: onPressed,
      backgroundColor: const Color(0xFF764BA2).withOpacity(0.3),
    );
  }

  IconData _getFaceIcon(String expression) {
    switch (expression) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_dissatisfied;
      case 'angry':
        return Icons.sentiment_very_dissatisfied;
      case 'surprised':
        return Icons.sentiment_neutral;
      case 'thinking':
        return Icons.psychology;
      case 'sleeping':
        return Icons.bedtime;
      case 'excited':
        return Icons.celebration;
      default:
        return Icons.mood;
    }
  }

  Future<void> _quickMotion(String motionName) async {
    final success = await context.read<RobotStateProvider>().runMotion(motionName);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '✓ $motionName' : '✗ Failed'),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _setFace(String expression) async {
    await context.read<RobotStateProvider>().setFaceExpression(expression);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Face: $expression'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}
