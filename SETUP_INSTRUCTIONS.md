# Plant Disease Detector - Setup Instructions

## Quick Start Guide

This guide will help you set up and deploy the complete Plant Disease Detector application with Flutter mobile app, FastAPI backend, and Firebase integration.

## Prerequisites

### Required Software
- **Flutter SDK** (3.0+) - [Download here](https://flutter.dev/docs/get-started/install)
- **Python** (3.9+) - [Download here](https://www.python.org/downloads/)
- **Node.js** (16+) - [Download here](https://nodejs.org/)
- **Git** - [Download here](https://git-scm.com/downloads)
- **Docker** (optional) - [Download here](https://www.docker.com/get-started)

### Required Accounts
- **Firebase Account** - [Create here](https://firebase.google.com/)
- **Render Account** (for backend deployment) - [Create here](https://render.com/)
- **Google Cloud Account** (optional) - [Create here](https://cloud.google.com/)

## Step 1: Firebase Setup

### 1.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `plant-disease-detector`
4. Enable Google Analytics (optional)
5. Click "Create project"

### 1.2 Enable Authentication
1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" provider
5. Enable "Google" provider
6. Configure Google provider with your OAuth credentials

### 1.3 Create Firestore Database
1. Go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location close to your users
5. Click "Done"

### 1.4 Download Configuration Files
1. Go to Project Settings (gear icon)
2. Scroll down to "Your apps"
3. Click "Add app" → Web app
4. Register app name: `plant-disease-detector-web`
5. Copy the Firebase config object
6. For Android: Click "Add app" → Android, download `google-services.json`
7. For iOS: Click "Add app" → iOS, download `GoogleService-Info.plist`

### 1.5 Generate Service Account Key
1. Go to Project Settings → Service accounts
2. Click "Generate new private key"
3. Download the JSON file
4. Rename it to `firebase-service-account.json`

## Step 2: Flutter App Setup

### 2.1 Clone and Setup
```bash
# Clone the repository
git clone <your-repo-url>
cd plant_disease_detector/flutter_app

# Install dependencies
flutter pub get

# Check Flutter installation
flutter doctor
```

### 2.2 Configure Firebase
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Configure Firebase for Flutter
flutterfire configure
```

### 2.3 Add Configuration Files
1. Copy `google-services.json` to `android/app/`
2. Copy `GoogleService-Info.plist` to `ios/Runner/`
3. Update `lib/main.dart` with your Firebase config

### 2.4 Update API Endpoint
Edit `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://your-backend-url.onrender.com';
```

### 2.5 Run the App
```bash
# For Android
flutter run

# For iOS (macOS only)
flutter run -d ios

# Build APK
flutter build apk --release
```

## Step 3: Backend Setup

### 3.1 Setup Python Environment
```bash
cd plant_disease_detector/backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 3.2 Configure Environment Variables
Create `.env` file in backend directory:
```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour private key here\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your-client-email
FIREBASE_CLIENT_ID=your-client-id
FIREBASE_CLIENT_CERT_URL=your-client-cert-url
```

### 3.3 Add Firebase Service Account
1. Copy `firebase-service-account.json` to `backend/` directory
2. Update the path in `app/main.py` if needed

### 3.4 Test Local Backend
```bash
# Run the development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Test the API
curl http://localhost:8000/health
```

## Step 4: Backend Deployment (Render)

### 4.1 Prepare for Deployment
1. Create `render.yaml` in backend directory (already included)
2. Update environment variables in Render dashboard
3. Connect your GitHub repository to Render

### 4.2 Deploy to Render
1. Go to [Render Dashboard](https://dashboard.render.com/)
2. Click "New" → "Web Service"
3. Connect your GitHub repository
4. Select the backend directory
5. Configure build settings:
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
6. Add environment variables from your `.env` file
7. Click "Create Web Service"

### 4.3 Update Flutter App
Update the API URL in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://your-app-name.onrender.com';
```

## Step 5: ML Model Integration

### 5.1 Prepare ML Model
1. Train your plant disease detection model using TensorFlow
2. Save the model as `plant_disease_model.h5`
3. Place it in `backend/ml_models/` directory

### 5.2 Update Model Configuration
Edit `backend/ml_models/class_names.json` with your model's classes:
```json
[
  "Apple___Apple_scab",
  "Apple___Black_rot",
  "Apple___healthy",
  "Tomato___Bacterial_spot",
  "Tomato___healthy"
]
```

### 5.3 Update Disease Information
Edit `backend/ml_models/disease_info.json` with disease details:
```json
{
  "Apple___Apple_scab": {
    "description": "Apple scab is a fungal disease...",
    "symptoms": ["Dark lesions on leaves", "Brown spots on fruit"],
    "treatments": ["Apply fungicide", "Remove infected leaves"],
    "prevention_tips": ["Plant resistant varieties", "Maintain good sanitation"]
  }
}
```

## Step 6: Testing

### 6.1 Backend Tests
```bash
cd backend

# Run unit tests
pytest tests/ -v

# Run integration tests
pytest tests/test_api_integration.py -v

# Run with coverage
pytest tests/ --cov=app --cov-report=html
```

### 6.2 Flutter Tests
```bash
cd flutter_app

# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

### 6.3 Manual Testing
1. **Authentication Flow**:
   - Test user registration
   - Test user login
   - Test password reset

2. **Disease Detection Flow**:
   - Upload plant image
   - Verify prediction results
   - Check prediction history

3. **Care Guide Flow**:
   - Browse care guides
   - View detailed information
   - Test search functionality

## Step 7: Production Deployment

### 7.1 Security Configuration
1. **Firebase Security Rules**:
```javascript
// Firestore rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

2. **Environment Variables**:
   - Use production Firebase project
   - Set secure API keys
   - Enable HTTPS only

### 7.2 Performance Optimization
1. **Enable Caching**:
   - Configure Redis for backend caching
   - Implement CDN for static assets
   - Enable Firestore offline persistence

2. **Monitor Performance**:
   - Set up application monitoring
   - Configure error tracking
   - Monitor API response times

### 7.3 Build Production APK
```bash
cd flutter_app

# Build release APK
flutter build apk --release

# Build app bundle (recommended for Play Store)
flutter build appbundle --release
```

## Troubleshooting

### Common Issues

#### Firebase Configuration Issues
- **Error**: "Firebase not initialized"
- **Solution**: Check Firebase config files are in correct locations

#### API Connection Issues
- **Error**: "Network error" in Flutter app
- **Solution**: Verify backend URL and CORS configuration

#### ML Model Issues
- **Error**: "Model not found"
- **Solution**: Ensure model file is in correct directory with proper permissions

#### Authentication Issues
- **Error**: "Invalid token"
- **Solution**: Check Firebase service account configuration

### Debug Commands
```bash
# Check Flutter installation
flutter doctor -v

# Check Firebase CLI
firebase --version

# Test backend locally
curl -X GET http://localhost:8000/health

# Check Python dependencies
pip list

# View logs
# Render: Check deployment logs in dashboard
# Flutter: Use flutter logs command
```

## Support and Resources

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [TensorFlow Documentation](https://www.tensorflow.org/guide)

### Community Support
- [Flutter Community](https://flutter.dev/community)
- [FastAPI Community](https://github.com/tiangolo/fastapi/discussions)
- [Firebase Community](https://firebase.google.com/community)

### Professional Support
For enterprise support or custom development:
- Email: support@plantdiseasedetector.com
- Documentation: [Project Wiki](https://github.com/your-repo/wiki)

---

## Quick Commands Summary

```bash
# Setup Flutter app
cd flutter_app
flutter pub get
flutter run

# Setup Backend
cd backend
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
uvicorn app.main:app --reload

# Run tests
pytest tests/ -v  # Backend tests
flutter test      # Flutter tests

# Build for production
flutter build apk --release  # Flutter
# Deploy to Render via dashboard  # Backend
```

*Setup completed successfully! Your Plant Disease Detector application is ready to use.*





