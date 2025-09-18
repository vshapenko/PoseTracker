# PoseTracker - Real-time Fitness Exercise Tracking

A Swift iOS app that uses the Vision framework to detect body poses in real-time and track exercise form accuracy.

## Features

- Real-time body pose detection using Vision framework
- Support for 5 exercises:
  - Squats
  - Push-ups
  - Plank
  - Lunges
  - Jumping Jacks
- Live feedback on form accuracy
- Automatic rep counting
- Front-facing camera view for self-monitoring

## Requirements

- iOS 16.0+
- Xcode 15.0+
- iPhone with front-facing camera
- Physical device for testing (camera not available in simulator)

## Setup

1. Open `PoseTracker.xcodeproj` in Xcode
2. Select your development team in project settings
3. Connect your iPhone
4. Select your iPhone as the run destination
5. Build and run the app

## How to Use

1. Grant camera permissions when prompted
2. Position yourself so your full body is visible in the camera
3. Select an exercise from the dropdown menu
4. Follow the on-screen feedback to maintain proper form
5. The app will automatically count your reps

## Technical Details

- **Vision Framework**: Detects 19 body joint points
- **Real-time Processing**: Analyzes poses at 30+ FPS
- **Joint Angle Calculations**: Measures angles between body joints to determine form accuracy
- **Exercise Phases**: Tracks up/down phases for rep counting

## Project Structure

```
PoseTracker/
├── PoseTrackerApp.swift    # App entry point
├── ContentView.swift       # Main UI
├── CameraView.swift        # Camera capture and preview
├── PoseDetector.swift      # Vision framework pose detection logic
├── Exercise.swift          # Exercise models and configurations
└── Info.plist             # App permissions and settings
```

## Customization

To add new exercises:
1. Add a new case to the `Exercise` enum
2. Define target angles for the exercise
3. Implement analysis logic in `PoseDetector.swift`

## Privacy

The app processes all pose detection locally on device. No data is sent to external servers.