# COMPLETE FIX SCRIPT - Apply all corrections
Write-Host "Applying fixes to Zenon Robot App..." -ForegroundColor Cyan
Write-Host ""

# Fix 1: Replace live_mode_screen.dart with simplified 4-control version
Write-Host "[1/2] Fixing Live Mode screen..." -ForegroundColor Yellow
@"
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/robot_state_provider.dart';

class LiveModeScreen extends StatefulWidget {
  const LiveModeScreen({super.key});

  @override
  State<LiveModeScreen> createState() => _LiveModeScreenState();
}

class _LiveModeScreenState extends State<LiveModeScreen> {
  // Only 4 controls as requested
  double _leftLegPosition = 1850;
  double _rightLegPosition = 2300;
  double _leftWheelSpeed = 0;
  double _rightWheelSpeed = 0;

  bool _isSending = false;

  Future<void> _updateRobot() async {
    if (_isSending) return;
    
    setState(() => _isSending = true);
    
    final commands = {
      'left_leg': _leftLegPosition,
      'right_leg': _rightLegPosition,
      'left_wheel': _leftWheelSpeed,
      'right_wheel': _rightWheelSpeed,
    };

    await context.read<RobotStateProvider>().updateJointPositions(commands);
    
    setState(() => _isSending = false);
  }

  void _resetToStand() {
    setState(() {
      _leftLegPosition = 1850;
      _rightLegPosition = 2300;
      _leftWheelSpeed = 0;
      _rightWheelSpeed = 0;
    });
    _updateRobot();
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with Robot Power Control
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Consumer<RobotStateProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      children: [
                        const Text(
                          'Live Joint Control',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Robot Status Display
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: provider.isRobotStarted
                                ? Colors.green.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: provider.isRobotStarted
                                  ? Colors.green
                                  : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                provider.isRobotStarted ? Icons.check_circle : Icons.circle_outlined,
                                color: provider.isRobotStarted ? Colors.green : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                provider.isRobotStarted ? 'Robot Online' : 'Robot Offline',
                                style: TextStyle(
                                  color: provider.isRobotStarted ? Colors.green : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Start/Shutdown Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: provider.isRobotStarted ? null : () => provider.startRobot(),
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Start Robot'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: !provider.isRobotStarted ? null : () => provider.shutdownRobot(),
                                icon: const Icon(Icons.power_off),
                                label: const Text('Shutdown'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Control Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _resetToStand,
                                icon: const Icon(Icons.restart_alt),
                                label: const Text('Reset to Stand'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF667EEA),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isSending ? null : _updateRobot,
                                icon: _isSending
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.send),
                                label: const Text('Update'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF764BA2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Leg Position Controls
            _buildSectionCard(
              title: 'Leg Position',
              icon: Icons.accessibility_new,
              children: [
                _buildSlider(
                  label: 'Left Leg Position',
                  value: _leftLegPosition,
                  min: 1300,
                  max: 2800,
                  onChanged: (val) => setState(() => _leftLegPosition = val),
                ),
                _buildSlider(
                  label: 'Right Leg Position',
                  value: _rightLegPosition,
                  min: 1300,
                  max: 2800,
                  onChanged: (val) => setState(() => _rightLegPosition = val),
                ),
              ],
            ),

            const SizedBox(height: 16),
            
            // Wheel Speed Controls
            _buildSectionCard(
              title: 'Wheel Speed',
              icon: Icons.speed,
              children: [
                _buildSlider(
                  label: 'Left Wheel Speed',
                  value: _leftWheelSpeed,
                  min: -200,
                  max: 200,
                  onChanged: (val) => setState(() => _leftWheelSpeed = val),
                ),
                _buildSlider(
                  label: 'Right Wheel Speed',
                  value: _rightWheelSpeed,
                  min: -200,
                  max: 200,
                  onChanged: (val) => setState(() => _rightWheelSpeed = val),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF667EEA)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667EEA),
                  ),
                ),
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
            onChanged: onChanged,
            onChangeEnd: (_) => _updateRobot(),
          ),
        ],
      ),
    );
  }
}
"@ | Out-File -FilePath "lib\screens\live_mode_screen.dart" -Encoding UTF8

# Fix 2: Update motions_screen.dart to ensure robot is started before running motions
Write-Host "[2/2] Fixing Motion execution..." -ForegroundColor Yellow

$motionsContent = Get-Content "lib\screens\motions_screen.dart" -Raw

# Add check for robot started before running motion
$motionsContent = $motionsContent -replace 'Future<void> _runMotion\(String motionName\) async \{', @'
Future<void> _runMotion(String motionName) async {
    final provider = context.read<RobotStateProvider>();
    
    // Check if robot is started first
    if (!provider.isRobotStarted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please start the robot first (Live Mode tab)'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
'@

$motionsContent | Out-File -FilePath "lib\screens\motions_screen.dart" -Encoding UTF8

Write-Host ""
Write-Host "✅ Fixes applied!" -ForegroundColor Green
Write-Host ""
Write-Host "Changes made:" -ForegroundColor Cyan
Write-Host "  1. Live Mode now shows robot Start/Shutdown buttons" -ForegroundColor White
Write-Host "  2. Reduced to 4 controls: Left/Right Leg Position + Left/Right Wheel Speed" -ForegroundColor White
Write-Host "  3. Motions now check if robot is started before executing" -ForegroundColor White
Write-Host ""
Write-Host "Rebuilding app..." -ForegroundColor Yellow
flutter build apk --release

Write-Host ""
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ✅ BUILD COMPLETE!" -ForegroundColor Green
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "APK: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
Write-Host ""
Write-Host "To use the app:" -ForegroundColor Yellow
Write-Host "  1. Open app and go to Live Mode tab" -ForegroundColor White
Write-Host "  2. Tap 'Start Robot' button first" -ForegroundColor White
Write-Host "  3. Now motions will work!" -ForegroundColor White
Write-Host ""
