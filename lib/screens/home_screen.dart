import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/robot_state_provider.dart';
import '../services/debug_logger.dart';
import 'live_mode_screen.dart';
import 'motions_screen.dart';
import 'camera_screen.dart';
import 'robot_control_screen.dart';
import 'vision_screen.dart';
import 'debug_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const LiveModeScreen(),
    const MotionsScreen(),
    const CameraScreen(),
    const RobotControlScreen(),
    const VisionScreen(),
    const DebugScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Auto-connect on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RobotStateProvider>().testConnection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: DebugLogger()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Zenon Robot',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            Consumer<RobotStateProvider>(
              builder: (context, provider, child) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: provider.isConnected
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: provider.isConnected
                              ? Colors.green
                              : Colors.red,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: provider.isConnected
                                  ? Colors.green
                                  : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            provider.isConnected ? 'Online' : 'Offline',
                            style: TextStyle(
                              color: provider.isConnected
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<RobotStateProvider>().testConnection();
              },
              tooltip: 'Reconnect',
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF667EEA).withOpacity(0.3),
                const Color(0xFF764BA2).withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: const Color(0xFF667EEA),
            unselectedItemColor: Colors.white60,
            selectedFontSize: 11,
            unselectedFontSize: 10,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_input_component, size: 22),
                label: 'Live Mode',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_run, size: 22),
                label: 'Motions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.videocam, size: 22),
                label: 'Camera',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.gamepad, size: 22),
                label: 'Control',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.visibility, size: 22),
                label: 'Vision',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bug_report, size: 22),
                label: 'Debug',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
