# Zenon Robot Control App

A professional Flutter mobile application for controlling the Zenon Robot with a beautiful Material Design 3 UI.

## Features

### 🎮 Live Mode
- Real-time joint control with sliders
- Individual control for legs, ears, and wheels
- Motion profile adjustment (velocity & acceleration)
- Instant feedback and updates

### 🕺 Motions Library
- 60+ pre-programmed motions
- Categorized by type (gestures, movements, expressions, etc.)
- Search functionality
- Filter by category
- Smooth execution with visual feedback

### 📹 Camera Control
- Live video streaming (2 fps)
- Single image capture
- Camera power control
- Real-time image display
- Auto-refresh in live mode

### 🎯 Robot Control
- Manual movement controls (D-pad style)
- Robot power management (start/shutdown)
- Face expression control (8 expressions)
- Voice listener toggle
- AI conversation mode
- Quick action buttons

### 👁️ Vision System
- Object following with real-time tracking
- Object detection using YOLO v8
- Status indicators
- Easy on/off controls

## Technical Specifications

### Robot API
- **Base URL**: `http://10.255.254.75:8000`
- **Protocol**: REST API with JSON
- **Timeout**: 10 seconds per request
- **Camera refresh**: 500ms (2 fps)

### Supported Features
- Dynamixel servo control
- DC motor control (wheels)
- Camera streaming
- Audio control
- Face expressions
- Vision processing
- Voice commands
- AI chatbot integration

## Installation

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio or VS Code
- Android device or emulator
- Network connection to robot (10.255.254.75)

### Setup Steps

1. **Clone and Navigate**
   ```bash
   cd zenon_robot_app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

### Building for Release

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS (requires macOS):**
```bash
flutter build ios --release
```

## Network Configuration

### Ensure Robot Connectivity
1. Connect your mobile device to the same network as the robot
2. The robot should be accessible at `10.255.254.75:8000`
3. Test connection using the refresh button in the app

### Firewall Settings
Make sure port 8000 is open on the robot's firewall:
```bash
sudo ufw allow 8000/tcp
```

## App Structure

```
lib/
├── main.dart                      # App entry point
├── screens/
│   ├── home_screen.dart          # Main navigation
│   ├── live_mode_screen.dart     # Joint control
│   ├── motions_screen.dart       # Motion library
│   ├── camera_screen.dart        # Camera controls
│   ├── robot_control_screen.dart # Manual control
│   └── vision_screen.dart        # Vision features
└── services/
    ├── api_service.dart          # API communication
    └── robot_state_provider.dart # State management
```

## Available API Endpoints

### Robot Control
- `POST /robot/start` - Start robot
- `POST /robot/shutdown` - Shutdown robot
- `GET /robot/state` - Get current state
- `POST /robot/state` - Set joint positions
- `POST /robot/update_state` - Update joint positions
- `POST /robot/run_scenario` - Run motion

### Camera
- `POST /cam/on` - Power on camera
- `POST /cam/off` - Power off camera
- `GET /cam/get/image` - Get camera image

### Vision
- `POST /vision/follow_obj/start` - Start object following
- `POST /vision/follow_obj/stop` - Stop object following
- `POST /vision/yolo/start` - Start object detection
- `POST /vision/yolo/stop` - Stop object detection

### Voice & AI
- `POST /robot/listen` - Start voice listener
- `POST /robot/listen/stop` - Stop voice listener
- `POST /ai/listen/start` - Start AI conversation
- `POST /ai/listen/stop` - Stop AI conversation

### Face Control
- `POST /robot_face/expression/{expression}` - Set face expression

## Motion Library

### Categories
- **Basic Postures**: stand, crouch, tall_stand, etc.
- **Gestures**: wave, bow, nod_yes, shake_no, etc.
- **Ear Expressions**: happy_ears, alert_ears, sad_ears, etc.
- **Movement**: move_forward, turn_left, spin, etc.
- **Complex Motions**: dance, celebration, crawl, etc.
- **Face Directions**: face_left, face_right, face_back, etc.
- **Utility**: calibrate, reset_position, test_all_joints

## Troubleshooting

### Connection Issues
- **Problem**: App shows "Offline"
- **Solution**: 
  - Verify robot IP (10.255.254.75)
  - Check network connectivity
  - Ensure API server is running on robot
  - Try manual connection using curl: `curl http://10.255.254.75:8000/robot/state`

### Camera Not Loading
- **Problem**: Camera shows black screen
- **Solution**:
  - Toggle camera power off and on
  - Check if camera is working on robot directly
  - Verify camera endpoint: `curl http://10.255.254.75:8000/cam/get/image`

### Motions Not Executing
- **Problem**: Motions fail to run
- **Solution**:
  - Ensure robot is started (not just connected)
  - Check robot state in Live Mode
  - Verify motors are not in error state
  - Try calibrate motion first

## Development

### Adding New Motions
Edit `motions_screen.dart` and add to the `_motions` map:
```dart
{'name': 'new_motion', 'icon': Icons.icon_name, 'color': Colors.blue}
```

### Modifying API Endpoint
Edit `api_service.dart` and update the `baseUrl`:
```dart
static const String baseUrl = 'http://YOUR_ROBOT_IP:8000';
```

### Customizing UI Theme
Edit `main.dart` theme configuration:
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: const Color(0xFF667EEA),
  brightness: Brightness.dark,
),
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0              # API communication
  provider: ^6.1.1          # State management
  flutter_svg: ^2.0.9       # SVG support
  cached_network_image: ^3.3.0  # Image caching
  shared_preferences: ^2.2.2     # Local storage
```

## License

This project is proprietary software for the Zenon Robot system.

## Support

For issues, questions, or feature requests, please contact the development team.

## Version History

### v1.0.0 (Current)
- Initial release
- Full robot control features
- Live camera streaming
- Complete motion library
- Vision system integration
- Material Design 3 UI

---

**Built with ❤️ using Flutter**
