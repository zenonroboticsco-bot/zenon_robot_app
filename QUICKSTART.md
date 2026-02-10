# Zenon Robot App - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Prerequisites
Make sure you have:
- Flutter SDK installed (version 3.0.0 or higher)
- Android Studio or VS Code
- Android device or emulator
- USB cable (for physical device)

### Step 2: Setup
```bash
cd zenon_robot_app
chmod +x setup.sh
./setup.sh
```

### Step 3: Connect to Robot Network
1. Connect your mobile device to the same network as the robot
2. Verify robot is accessible at: `10.255.254.75`
3. Test with: `ping 10.255.254.75`

### Step 4: Run the App
Choose option 1 from the setup script menu to run in debug mode:
```bash
./setup.sh
# Select: 1. Run app in debug mode
```

### Step 5: Connect in App
1. App will auto-connect on startup
2. Look for green "Online" indicator in top-right
3. If offline, tap the refresh icon

## 📱 Main Features Overview

### Live Mode Tab 🎮
Control individual joints in real-time:
- **Legs**: Move left/right legs (1300-2800)
- **Ears**: Adjust ear positions (300-700)
- **Wheels**: Control wheel speed (-200 to 200)
- **Profile**: Set velocity and acceleration

**How to use:**
1. Tap "Live Mode" tab at bottom
2. Adjust sliders to desired positions
3. Changes apply automatically on slider release
4. Tap "Reset to Stand" to return to default pose

### Motions Tab 🕺
Execute pre-programmed motions:
- 60+ motions organized by category
- Search by name
- Filter by category (All, Basic Postures, Gestures, etc.)

**How to use:**
1. Tap "Motions" tab
2. Browse or search for a motion
3. Tap any motion card to execute
4. Wait for completion (progress shown)

**Popular motions:**
- `wave` - Friendly wave gesture
- `dance` - Dance routine
- `bow` - Polite bow
- `patrol` - Security patrol pattern

### Camera Tab 📹
View robot's camera feed:
- Live streaming at 2 fps
- Single image capture
- Camera power control

**How to use:**
1. Tap "Camera" tab
2. Toggle "Camera Power" to ON
3. Tap "Start Live View" for streaming
4. Or tap "Capture" for single image

### Control Tab 🎯
Manual robot control:
- **Movement**: D-pad style directional controls
- **Power**: Start/shutdown robot
- **Face**: Set expression (8 options)
- **Voice**: Enable voice commands
- **AI**: Activate AI conversation mode

**How to use:**
1. Tap "Control" tab
2. Use arrow buttons for movement
3. Tap expressions to change robot face
4. Toggle voice/AI features as needed

### Vision Tab 👁️
Advanced vision features:
- **Object Following**: Robot tracks and follows objects
- **Object Detection**: YOLO-powered object detection

**How to use:**
1. Tap "Vision" tab
2. Ensure camera is powered on
3. Tap "Start Object Following" or "Start Object Detection"
4. Watch status indicator turn green
5. Tap "Stop" to deactivate

## 🔧 Quick Troubleshooting

### App shows "Offline"
```bash
# On robot, check API server is running:
ps aux | grep api_server

# Test connectivity:
curl http://10.255.254.75:8000/robot/state

# Restart robot API if needed:
# (refer to robot documentation)
```

### Camera not working
1. Toggle camera power OFF then ON
2. Wait 2-3 seconds
3. Try "Capture" before "Live View"

### Motions not executing
1. Check robot is "Started" (not just connected)
2. Go to Control tab → tap "Start Robot"
3. Try "Calibrate" motion first

### Build errors
```bash
# Clean and rebuild:
flutter clean
flutter pub get
flutter run
```

## 📖 Common Tasks

### Change Robot IP Address
Edit `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_NEW_IP:8000';
```

### Build APK for Distribution
```bash
./setup.sh
# Select: 2. Build APK (release)
# APK location: build/app/outputs/flutter-apk/app-release.apk
```

### Test Without Robot
- App will show "Offline" status
- All UI features are functional
- API calls will fail gracefully
- No crashes or errors

## 🎨 UI Tips

### Navigation
- 5 tabs at bottom for main features
- Swipe or tap to switch tabs
- All tabs remain in memory (IndexedStack)

### Status Indicators
- **Green**: Active/Online/Success
- **Red**: Inactive/Offline/Error
- **Yellow**: Warning/Processing

### Buttons
- Disabled buttons are grayed out
- Loading shown during operations
- Snackbar notifications for results

## 🔥 Advanced Features

### Custom Joint Commands (Live Mode)
1. Adjust multiple sliders
2. Tap "Update" to send all at once
3. Or let auto-update on each slider release

### Motion Search
1. Type motion name in search box
2. Instant filtering
3. Clear with X button

### Camera Streaming
- Auto-refreshes every 500ms when active
- Stops when switching tabs to save bandwidth
- Manual refresh available

## 📱 Recommended Workflow

1. **Connect**: Ensure "Online" status
2. **Start Robot**: Control tab → "Start Robot"
3. **Test**: Live Mode → "Reset to Stand"
4. **Calibrate**: Motions → "calibrate"
5. **Explore**: Try different motions and features!

## 💡 Pro Tips

- Keep robot on stable surface when testing motions
- Start with basic postures before complex motions
- Use "wheels_stop" immediately if robot moves unexpectedly
- Camera works best in well-lit environments
- Voice features require quiet environment

## 🆘 Need Help?

### Check Logs
```bash
# On robot:
tail -f /var/log/robot_api.log

# In Android Studio:
# View → Tool Windows → Logcat
```

### Common Error Messages
- "Connection refused" → Robot API not running
- "Timeout" → Network issue, check connectivity
- "Failed to execute" → Robot may be in error state

### Still Having Issues?
1. Check README.md for detailed documentation
2. Review robot API server logs
3. Contact support team

---

**Ready to control your robot? Run `./setup.sh` and let's go! 🚀**
