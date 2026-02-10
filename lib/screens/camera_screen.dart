import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/robot_state_provider.dart';
import '../services/debug_logger.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  Timer? _refreshTimer;
  bool _isLiveViewActive = false;
  bool _isRefreshing = false;
  final _logger = DebugLogger();

  @override
  void dispose() {
    _stopLiveView();
    super.dispose();
  }

  void _startLiveView() {
    final provider = context.read<RobotStateProvider>();
    
    if (!provider.isCameraOn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turn on camera first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _logger.log('Starting camera live view', level: LogLevel.info);
    setState(() => _isLiveViewActive = true);
    
    // Refresh camera image every 500ms for smooth streaming
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (mounted && _isLiveViewActive && !_isRefreshing) {
        _isRefreshing = true;
        try {
          await provider.refreshCameraImage();
        } catch (e) {
          _logger.log('Camera refresh error: $e', level: LogLevel.error);
        } finally {
          _isRefreshing = false;
        }
      }
    });
  }

  void _stopLiveView() {
    _logger.log('Stopping camera live view', level: LogLevel.info);
    _refreshTimer?.cancel();
    _refreshTimer = null;
    setState(() {
      _isLiveViewActive = false;
      _isRefreshing = false;
    });
  }

  Future<void> _captureImage() async {
    final provider = context.read<RobotStateProvider>();
    
    if (!provider.isCameraOn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turn on camera first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isRefreshing = true);
    _logger.log('Capturing camera image', level: LogLevel.info);
    
    try {
      await provider.refreshCameraImage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Image captured'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      _logger.log('Image capture failed: $e', level: LogLevel.error);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Capture failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Camera Controls Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.videocam, color: Color(0xFF667EEA)),
                        SizedBox(width: 8),
                        Text(
                          'Camera Control',
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
                            // Camera Power Switch
                            SwitchListTile(
                              title: const Text('Camera Power'),
                              subtitle: Text(
                                provider.isCameraOn ? 'ON' : 'OFF',
                                style: TextStyle(
                                  color: provider.isCameraOn
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              value: provider.isCameraOn,
                              onChanged: (value) async {
                                _logger.log(
                                  'Toggling camera: ${value ? 'ON' : 'OFF'}',
                                  level: LogLevel.info,
                                );
                                
                                // Stop live view if turning off
                                if (!value && _isLiveViewActive) {
                                  _stopLiveView();
                                }
                                
                                await provider.toggleCamera();
                                
                                if (value) {
                                  // When camera turns on, fetch first image
                                  await Future.delayed(const Duration(milliseconds: 500));
                                  await provider.refreshCameraImage();
                                }
                              },
                              activeColor: const Color(0xFF667EEA),
                            ),
                            
                            const Divider(),
                            
                            // Live View Controls
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: provider.isCameraOn
                                        ? (_isLiveViewActive ? _stopLiveView : _startLiveView)
                                        : null,
                                    icon: Icon(
                                      _isLiveViewActive ? Icons.stop : Icons.play_arrow,
                                    ),
                                    label: Text(
                                      _isLiveViewActive ? 'Stop Live' : 'Start Live',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isLiveViewActive
                                          ? Colors.red
                                          : const Color(0xFF667EEA),
                                      minimumSize: const Size(0, 45),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: provider.isCameraOn && !_isLiveViewActive && !_isRefreshing
                                      ? _captureImage
                                      : null,
                                  icon: _isRefreshing
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.camera_alt),
                                  label: const Text('Capture'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF764BA2),
                                    minimumSize: const Size(0, 45),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Camera Feed Card
            Consumer<RobotStateProvider>(
              builder: (context, provider, child) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.camera_alt, color: Color(0xFF667EEA)),
                                SizedBox(width: 8),
                                Text(
                                  'Live Feed',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (_isLiveViewActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: Colors.red,
                                      size: 8,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'LIVE',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Camera Image Display
                        Container(
                          width: double.infinity,
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: provider.latestCameraImage != null
                                ? Image.memory(
                                    provider.latestCameraImage!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      _logger.log('Image display error: $error', level: LogLevel.error);
                                      return const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              size: 48,
                                              color: Colors.red,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Failed to load image',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          provider.isCameraOn
                                              ? Icons.photo_camera
                                              : Icons.videocam_off,
                                          size: 64,
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          provider.isCameraOn
                                              ? 'Start live view or capture image'
                                              : 'Camera is off',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white.withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        
                        if (provider.latestCameraImage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Size: ${(provider.latestCameraImage!.length / 1024).toStringAsFixed(1)} KB',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                                if (_isRefreshing)
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Refreshing...',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green[300],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Camera Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF667EEA)),
                        SizedBox(width: 8),
                        Text(
                          'Camera Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Refresh Rate', '2 fps (500ms interval)'),
                    _buildInfoRow('Format', 'JPEG'),
                    _buildInfoRow('Mode', _isLiveViewActive ? 'Live Stream' : 'Single Capture'),
                    _buildInfoRow('Status', _isRefreshing ? 'Refreshing' : 'Idle'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
