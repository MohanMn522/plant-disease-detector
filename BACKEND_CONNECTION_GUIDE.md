# 🌱 Plant Disease Detector - Backend Connection Guide

This guide will help you connect your Flutter app to the backend for accurate disease detection results.

## 📋 Prerequisites

- Python 3.9+ installed
- Flutter SDK installed
- Firebase project configured
- Android Studio or VS Code

## 🚀 Quick Start

### 1. Start the Backend Server

**Option A: Using the provided script (Recommended)**
```bash
# From the project root directory
python start_backend.py
```

**Option B: Manual setup**
```bash
# Navigate to backend directory
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

# Start the server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 2. Verify Backend is Running

Open your browser and visit:
- **API Root**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health

You should see:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "services": {
    "ml_model": true,
    "firebase": true
  }
}
```

### 3. Configure Flutter App

The Flutter app is already configured to connect to the backend. The API service is set up to:

- ✅ Connect to `http://localhost:8000` for local development
- ✅ Use Firebase authentication tokens
- ✅ Handle image uploads for disease detection
- ✅ Fall back to mock data if backend is unavailable

## 🔧 Configuration Details

### Backend API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check |
| `/predictions/upload` | POST | Upload image for disease detection |
| `/predictions/history/{user_id}` | GET | Get user's prediction history |
| `/predictions/{prediction_id}` | DELETE | Delete a prediction |
| `/predictions/care-guide` | GET | Get care guide for plant/disease |

### Flutter API Service Configuration

**File**: `flutter_app/lib/services/api_service.dart`

```dart
// For local development
static const String baseUrl = 'http://localhost:8000';

// For production (update when deploying)
// static const String baseUrl = 'https://your-backend-url.onrender.com';

// Set to false when backend is ready
static const bool useMockData = false;
```

## 🧪 Testing the Integration

### 1. Test Backend Health
```bash
curl http://localhost:8000/health
```

### 2. Test Flutter App
1. Start the Flutter app: `flutter run`
2. Register/Login with Firebase
3. Take a photo of a plant leaf
4. Check if the app receives real predictions from the backend

### 3. Check Logs
- **Backend logs**: Check the terminal where you started the backend
- **Flutter logs**: Use `flutter logs` or check Android Studio console

## 🔍 Troubleshooting

### Backend Issues

**Problem**: "Module not found" errors
```bash
# Solution: Install dependencies
pip install -r requirements.txt
```

**Problem**: "Firebase not initialized"
```bash
# Solution: Check Firebase configuration
# Ensure firebase-service-account.json is in backend/ directory
```

**Problem**: "ML model not found"
```bash
# Solution: The backend will create a dummy model automatically
# For production, add your trained model as plant_disease_model.h5
```

### Flutter Issues

**Problem**: "Network error" in Flutter
```dart
// Check if backend is running
// Update baseUrl in api_service.dart
// Ensure useMockData = false
```

**Problem**: "Authentication failed"
```dart
// Check Firebase configuration
// Ensure user is logged in
// Check Firebase ID token generation
```

### Connection Issues

**Problem**: Flutter can't connect to localhost
```dart
// For Android emulator, use: http://10.0.2.2:8000
// For iOS simulator, use: http://localhost:8000
// For physical device, use your computer's IP: http://192.168.1.100:8000
```

## 📱 Mobile Device Testing

### Android Emulator
```dart
static const String baseUrl = 'http://10.0.2.2:8000';
```

### iOS Simulator
```dart
static const String baseUrl = 'http://localhost:8000';
```

### Physical Device
```dart
// Replace with your computer's IP address
static const String baseUrl = 'http://192.168.1.100:8000';
```

## 🚀 Production Deployment

### 1. Deploy Backend
- Deploy to Render, Heroku, or AWS
- Update environment variables
- Add your trained ML model

### 2. Update Flutter App
```dart
// Update the baseUrl in api_service.dart
static const String baseUrl = 'https://your-deployed-backend.com';
```

### 3. Firebase Configuration
- Ensure Firebase project is configured for production
- Update Firebase security rules
- Configure CORS for your domain

## 📊 Expected Results

When everything is working correctly:

1. **Backend**: Returns real disease predictions with confidence scores
2. **Flutter**: Displays actual plant disease information
3. **History**: Saves and retrieves real prediction history
4. **Care Guides**: Shows detailed treatment and prevention tips

## 🆘 Getting Help

If you encounter issues:

1. Check the logs in both backend and Flutter
2. Verify all dependencies are installed
3. Ensure Firebase is properly configured
4. Test the API endpoints directly with curl or Postman

## 📝 Next Steps

1. **Add Real ML Model**: Replace the dummy model with your trained TensorFlow model
2. **Enhance Disease Database**: Add more plant species and diseases
3. **Improve UI**: Add loading states and error handling
4. **Add Offline Support**: Cache predictions for offline viewing
5. **Deploy to Production**: Set up CI/CD pipeline

---

**🎉 Congratulations!** Your Flutter app is now connected to the backend and ready for accurate plant disease detection!


