# Plant Disease Detector - Flutter Mobile App

A comprehensive Flutter mobile application for plant disease detection with ML model integration, Firebase backend, and FastAPI server.

## Project Structure

```
plant_disease_detector/
├── flutter_app/                 # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── services/
│   │   └── models/
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
├── backend/                     # FastAPI backend server
│   ├── app/
│   │   ├── main.py
│   │   ├── models/
│   │   ├── routes/
│   │   └── services/
│   ├── ml_models/
│   ├── requirements.txt
│   └── Dockerfile
├── documentation/               # Project documentation
│   ├── user_manual.md
│   ├── test_cases.md
│   ├── system_design.md
│   └── performance_report.md
└── deployment/                  # Deployment configurations
    ├── docker-compose.yml
    ├── render.yaml
    └── firebase_config/
```

## Features

- 🔍 **Plant Disease Detection**: Upload images and get AI-powered disease predictions
- 📱 **Cross-Platform**: Works on both Android and iOS
- 🔐 **Authentication**: Firebase Auth with email/password and Google Sign-In
- 📊 **History Tracking**: View previous predictions and results
- 🌱 **Care Guides**: Get plant care tips and recommendations
- ☁️ **Cloud Backend**: FastAPI server with ML model integration
- 🧪 **Comprehensive Testing**: Unit and integration tests

## Quick Start

### Prerequisites
- Flutter SDK (3.0+)
- Python 3.8+
- Firebase project setup
- Android Studio / Xcode

### Installation

1. **Clone and setup Flutter app:**
```bash
cd flutter_app
flutter pub get
flutter run
```

2. **Setup FastAPI backend:**
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

3. **Configure Firebase:**
- Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- Update Firebase configuration in the app

## Documentation

- [User Manual](documentation/user_manual.md)
- [Test Cases](documentation/test_cases.md)
- [System Design](documentation/system_design.md)
- [Performance Report](documentation/performance_report.md)

## Deployment

- **Backend**: Deploy to Render/Google Cloud/AWS
- **Mobile**: Generate APK/IPA for distribution
- **Firebase**: Configure for production environment

## License

MIT License - see LICENSE file for details


