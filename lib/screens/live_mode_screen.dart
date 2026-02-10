import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LiveModeScreen extends StatefulWidget {
  const LiveModeScreen({super.key});

  @override
  State<LiveModeScreen> createState() => _LiveModeScreenState();
}

class _LiveModeScreenState extends State<LiveModeScreen> {
  double _leftLegPosition = 1850;
  double _rightLegPosition = 2300;
  double _leftWheelSpeed = 0;
  double _rightWheelSpeed = 0;
  
  bool _liveModeEnabled = false;
  bool _robotStarted = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkRobotState();
  }

  // Check if robot is already started
  Future<void> _checkRobotState() async {
    setState(() => _isChecking = true);
    
    try {
      final response = await ApiService.getRobotState();
      
      // If we get a successful response, robot is running
      if (response['success'] == true || response.containsKey('left_leg') || response.containsKey('right_leg')) {
        if (mounted) {
          setState(() {
            _robotStarted = true;
            _isChecking = false;
          });
        }
        return;
      }
    } catch (e) {
      // Error getting state - robot likely not started
      print('Robot state check error: $e');
    }
    
    if (mounted) {
      setState(() {
        _robotStarted = false;
        _isChecking = false;
      });
    }
  }

  Future<void> _toggleLiveMode(bool value) async {
    if (value) {
      // Turning ON Live Mode - ALWAYS check current state first
      setState(() => _isChecking = true);
      
      // Re-check robot state before attempting to start
      await _checkRobotState();
      
      if (_robotStarted) {
        // Robot already running - just enable sliders
        setState(() {
          _liveModeEnabled = true;
          _isChecking = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Robot already running - Live Mode ON'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
      
      // Robot NOT running - start it now
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🤖 Starting robot...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      try {
        final result = await ApiService.startRobot();
        
        if (result['success'] == true) {
          setState(() {
            _robotStarted = true;
            _liveModeEnabled = true;
            _isChecking = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ Robot started! Live Mode ON'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          setState(() => _isChecking = false);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✗ Failed to start: ${result['error'] ?? 'Unknown error'}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        setState(() => _isChecking = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✗ Error starting robot: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } else {
      // Turning OFF Live Mode - just disable sliders
      setState(() => _liveModeEnabled = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Live Mode OFF'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Future<void> _updateRobot() async {
    if (!_liveModeEnabled || !_robotStarted) return;
    
    final commands = {
      'left_leg': _leftLegPosition,
      'right_leg': _rightLegPosition,
      'left_wheel': _leftWheelSpeed,
      'right_wheel': _rightWheelSpeed,
    };

    try {
      await ApiService.updateRobotState(commands);
    } catch (e) {
      print('Update robot error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1a1a2e), const Color(0xFF16213e).withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Live Joint Control', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    
                    // Robot Status Indicator
                    if (_robotStarted && !_isChecking)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Robot Already Running',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Checking status
                    if (_isChecking)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Checking robot status...',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Live Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                        _isChecking
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Switch(
                                value: _liveModeEnabled,
                                onChanged: _toggleLiveMode,
                                activeColor: Colors.green,
                              ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _liveModeEnabled ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_liveModeEnabled ? Icons.check_circle : Icons.circle_outlined, color: _liveModeEnabled ? Colors.green : Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Text(_liveModeEnabled ? 'Sliders Active - Control Enabled' : 'Sliders Disabled', style: TextStyle(color: _liveModeEnabled ? Colors.green : Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [const Icon(Icons.accessibility_new, color: Color(0xFF667EEA)), const SizedBox(width: 8), const Text('Leg Position', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 12),
                    _buildSlider('Left Leg', _leftLegPosition, 1300, 2800, (val) => setState(() => _leftLegPosition = val)),
                    _buildSlider('Right Leg', _rightLegPosition, 1300, 2800, (val) => setState(() => _rightLegPosition = val)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [const Icon(Icons.speed, color: Color(0xFF667EEA)), const SizedBox(width: 8), const Text('Wheel Speed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 12),
                    _buildSlider('Left Wheel', _leftWheelSpeed, -200, 200, (val) => setState(() => _leftWheelSpeed = val)),
                    _buildSlider('Right Wheel', _rightWheelSpeed, -200, 200, (val) => setState(() => _rightWheelSpeed = val)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF667EEA).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF667EEA))),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / 10).round(),
            activeColor: const Color(0xFF667EEA),
            inactiveColor: const Color(0xFF667EEA).withOpacity(0.3),
            onChanged: _liveModeEnabled ? onChanged : null,
            onChangeEnd: _liveModeEnabled ? (_) => _updateRobot() : null,
          ),
        ],
      ),
    );
  }
}
