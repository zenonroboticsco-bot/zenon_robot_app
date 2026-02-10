import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/robot_state_provider.dart';

class VisionScreen extends StatelessWidget {
  const VisionScreen({super.key});

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
            // Object Following Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Consumer<RobotStateProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF667EEA).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.track_changes,
                                color: Color(0xFF667EEA),
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Object Following',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Track and follow objects in real-time',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Status Indicator
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: provider.isObjectFollowingActive
                                ? Colors.green.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: provider.isObjectFollowingActive
                                  ? Colors.green
                                  : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                provider.isObjectFollowingActive
                                    ? Icons.play_circle_filled
                                    : Icons.stop_circle,
                                color: provider.isObjectFollowingActive
                                    ? Colors.green
                                    : Colors.grey,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider.isObjectFollowingActive
                                          ? 'ACTIVE'
                                          : 'INACTIVE',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: provider.isObjectFollowingActive
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      provider.isObjectFollowingActive
                                          ? 'Robot is following detected objects'
                                          : 'Object following is disabled',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Control Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => provider.toggleObjectFollowing(),
                            icon: Icon(
                              provider.isObjectFollowingActive
                                  ? Icons.stop
                                  : Icons.play_arrow,
                              size: 24,
                            ),
                            label: Text(
                              provider.isObjectFollowingActive
                                  ? 'Stop Object Following'
                                  : 'Start Object Following',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: provider.isObjectFollowingActive
                                  ? Colors.red
                                  : const Color(0xFF667EEA),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Features List
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Features:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildFeatureItem('Real-time object tracking'),
                              _buildFeatureItem('Automatic robot movement'),
                              _buildFeatureItem('Distance-based speed control'),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Object Detection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Consumer<RobotStateProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF764BA2).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.grid_on,
                                color: Color(0xFF764BA2),
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Object Detection',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Detect and classify objects using YOLO',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Status Indicator
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: provider.isObjectDetectionActive
                                ? Colors.green.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: provider.isObjectDetectionActive
                                  ? Colors.green
                                  : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                provider.isObjectDetectionActive
                                    ? Icons.sensors
                                    : Icons.sensors_off,
                                color: provider.isObjectDetectionActive
                                    ? Colors.green
                                    : Colors.grey,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider.isObjectDetectionActive
                                          ? 'DETECTING'
                                          : 'INACTIVE',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: provider.isObjectDetectionActive
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      provider.isObjectDetectionActive
                                          ? 'YOLO detector is running'
                                          : 'Object detection is disabled',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Control Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => provider.toggleObjectDetection(),
                            icon: Icon(
                              provider.isObjectDetectionActive
                                  ? Icons.stop
                                  : Icons.play_arrow,
                              size: 24,
                            ),
                            label: Text(
                              provider.isObjectDetectionActive
                                  ? 'Stop Object Detection'
                                  : 'Start Object Detection',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: provider.isObjectDetectionActive
                                  ? Colors.red
                                  : const Color(0xFF764BA2),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Features List
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Capabilities:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildFeatureItem('Multi-object detection'),
                              _buildFeatureItem('Real-time classification'),
                              _buildFeatureItem('Bounding box visualization'),
                              _buildFeatureItem('YOLO v8 powered'),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFF667EEA)),
                        const SizedBox(width: 8),
                        Text(
                          'Vision System Info',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The vision system uses camera feed to detect and track objects. '
                      'Make sure the camera is powered on before activating vision features.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
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

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
