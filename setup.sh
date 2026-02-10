#!/bin/bash

# Zenon Robot App Setup Script
# This script sets up and runs the Flutter app for Zenon Robot control

echo "================================================"
echo "  Zenon Robot Control App - Setup Script"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if Flutter is installed
print_status "Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed!"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi
print_success "Flutter is installed"

# Check Flutter version
print_status "Checking Flutter version..."
flutter --version

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found!"
    echo "Please run this script from the zenon_robot_app directory"
    exit 1
fi

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "Getting Flutter dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    print_error "Failed to get dependencies"
    exit 1
fi
print_success "Dependencies installed"

# Check for connected devices
print_status "Checking for connected devices..."
flutter devices

# Ask user what they want to do
echo ""
echo "What would you like to do?"
echo "1. Run app in debug mode"
echo "2. Build APK (release)"
echo "3. Build App Bundle (release)"
echo "4. Run tests"
echo "5. Exit"
echo ""
read -p "Enter choice [1-5]: " choice

case $choice in
    1)
        print_status "Running app in debug mode..."
        flutter run
        ;;
    2)
        print_status "Building release APK..."
        flutter build apk --release
        if [ $? -eq 0 ]; then
            print_success "APK built successfully!"
            echo "Location: build/app/outputs/flutter-apk/app-release.apk"
        else
            print_error "APK build failed"
            exit 1
        fi
        ;;
    3)
        print_status "Building release App Bundle..."
        flutter build appbundle --release
        if [ $? -eq 0 ]; then
            print_success "App Bundle built successfully!"
            echo "Location: build/app/outputs/bundle/release/app-release.aab"
        else
            print_error "App Bundle build failed"
            exit 1
        fi
        ;;
    4)
        print_status "Running tests..."
        flutter test
        ;;
    5)
        print_status "Exiting..."
        exit 0
        ;;
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
print_success "Setup complete!"
echo ""
echo "================================================"
echo "  Next Steps:"
echo "================================================"
echo "1. Ensure your device is connected to the robot's network"
echo "2. Robot should be accessible at: http://10.255.254.75:8000"
echo "3. Open the app and tap the refresh icon to connect"
echo ""
echo "For troubleshooting, see README.md"
echo ""
