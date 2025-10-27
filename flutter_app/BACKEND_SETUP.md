# Backend Setup Instructions

## Current Status
The app is currently configured to use **mock data** for testing purposes. This resolves the "Network error: Not Found" issue you were experiencing.

## How to Switch to Real Backend

### 1. Update API Service Configuration
In `lib/services/api_service.dart`, change line 12:
```dart
static const bool useMockData = true; // Set to false when backend is ready
```
to:
```dart
static const bool useMockData = false; // Set to false when backend is ready
```

### 2. Update Backend URL
In `lib/services/api_service.dart`, replace line 9:
```dart
static const String baseUrl = 'https://your-backend-url.onrender.com';
```
with your actual backend URL:
```dart
static const String baseUrl = 'https://your-actual-backend-url.com';
```

### 3. Backend Requirements
Your backend should implement these endpoints:

- `POST /predict` - Image analysis endpoint
  - Accepts: multipart/form-data with 'image' file and 'userId' field
  - Returns: JSON with prediction results
  - Headers: Authorization: Bearer {user.uid}

- `GET /health` - Health check endpoint
  - Returns: 200 status for healthy backend

- `GET /history/{userId}` - Get prediction history
  - Returns: JSON with user's prediction history

- `POST /save-prediction` - Save prediction to history
  - Accepts: JSON with userId and prediction data

- `DELETE /prediction/{predictionId}` - Delete prediction

- `GET /care-guide?plant={plantName}&disease={diseaseName}` - Get care guide

### 4. Expected Response Format
The backend should return prediction results in this format:
```json
{
  "id": "unique_id",
  "plantName": "Apple",
  "diseaseName": "Apple Scab",
  "confidence": 0.85,
  "description": "Disease description...",
  "treatment": ["Treatment 1", "Treatment 2"],
  "prevention": ["Prevention 1", "Prevention 2"],
  "severity": "Moderate",
  "timestamp": "2024-01-01T12:00:00Z"
}
```

## Testing
- With `useMockData = true`: App works with sample data
- With `useMockData = false`: App connects to your backend
- If backend is unavailable, app automatically falls back to mock data

## Current Mock Data
The app currently shows:
- Apple with Apple Scab (85% confidence)
- Sample treatment and prevention tips
- Mock prediction history with Tomato Early Blight and Rose Black Spot

This allows you to test the full app functionality while developing your backend.
