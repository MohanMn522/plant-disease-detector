# Plant Disease Detector - System Design

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [System Components](#system-components)
3. [Data Flow](#data-flow)
4. [Technology Stack](#technology-stack)
5. [Security Architecture](#security-architecture)
6. [Scalability Considerations](#scalability-considerations)
7. [Deployment Architecture](#deployment-architecture)

## Architecture Overview

The Plant Disease Detector is a comprehensive mobile application with a cloud-based backend that provides AI-powered plant disease detection. The system follows a modern microservices architecture with clear separation of concerns.

### High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Flutter App   │    │   Flutter App   │
│   (Android)     │    │     (iOS)       │    │   (Web Admin)   │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────┴─────────────┐
                    │      Load Balancer        │
                    │        (Nginx)            │
                    └─────────────┬─────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │     FastAPI Backend       │
                    │   (Plant Disease API)     │
                    └─────────────┬─────────────┘
                                  │
          ┌───────────────────────┼───────────────────────┐
          │                       │                       │
┌─────────┴─────────┐    ┌─────────┴─────────┐    ┌─────────┴─────────┐
│   Firebase Auth   │    │  Firebase Firestore│    │   ML Model        │
│   (Authentication)│    │   (Data Storage)   │    │  (TensorFlow)     │
└───────────────────┘    └───────────────────┘    └───────────────────┘
```

## System Components

### 1. Mobile Application (Flutter)

#### Frontend Architecture
- **Framework**: Flutter 3.0+
- **State Management**: Riverpod for reactive state management
- **UI Components**: Material Design 3 with custom theming
- **Navigation**: Bottom navigation with tab-based routing

#### Key Screens
- **Authentication**: Login, Register, Forgot Password
- **Detection**: Camera capture, image upload, analysis
- **Results**: Disease information, treatment recommendations
- **History**: Past predictions with search and filter
- **Care Guide**: Plant care information and tips
- **Profile**: User settings and statistics

#### State Management
```dart
// Provider-based state management
final authStateProvider = StreamProvider<User?>((ref) {
  return authService.authStateChanges;
});

final predictionControllerProvider = StateNotifierProvider<PredictionController, PredictionState>((ref) {
  return PredictionController(apiService);
});
```

### 2. Backend API (FastAPI)

#### API Architecture
- **Framework**: FastAPI with async/await support
- **Authentication**: Firebase Admin SDK integration
- **Documentation**: Auto-generated OpenAPI/Swagger docs
- **Validation**: Pydantic models for request/response validation

#### Core Services
- **ML Service**: TensorFlow model integration for disease prediction
- **Firebase Service**: Firestore operations and user management
- **Auth Service**: Token verification and user authentication

#### API Endpoints
```
POST /predict          - Upload image and get disease prediction
GET  /history/{userId} - Get user's prediction history
DELETE /prediction/{id} - Delete specific prediction
GET  /care-guide       - Get plant care information
GET  /health           - Health check endpoint
```

### 3. Machine Learning Model

#### Model Architecture
- **Framework**: TensorFlow 2.15
- **Architecture**: Convolutional Neural Network (CNN)
- **Input**: 224x224x3 RGB images
- **Output**: Multi-class classification (38 plant disease classes)
- **Preprocessing**: Image resizing, normalization, augmentation

#### Model Pipeline
```python
class MLService:
    async def predict_disease(self, image_data: bytes) -> Dict:
        # 1. Preprocess image
        image = self._preprocess_image(image_data)
        
        # 2. Run inference
        predictions = self.model.predict(image)
        
        # 3. Post-process results
        result = self._postprocess_predictions(predictions)
        
        return result
```

### 4. Data Storage (Firebase)

#### Firestore Collections
```
users/
├── {userId}/
│   ├── profile: User information
│   ├── predictions/
│   │   └── {predictionId}: Prediction results
│   └── settings: User preferences

predictions/
├── {predictionId}: Global prediction data
└── analytics: Usage statistics
```

#### Data Models
```python
class PredictionResponse(BaseModel):
    id: str
    plantName: str
    diseaseName: str
    confidence: float
    description: str
    symptoms: List[str]
    treatments: List[str]
    preventionTips: List[str]
    isHealthy: bool
    timestamp: datetime
```

## Data Flow

### 1. User Authentication Flow
```
User → Flutter App → Firebase Auth → Backend API → Firestore
```

1. User enters credentials in Flutter app
2. Flutter app authenticates with Firebase Auth
3. Firebase returns JWT token
4. Token sent to backend for verification
5. Backend validates token with Firebase Admin SDK
6. User data stored/retrieved from Firestore

### 2. Disease Prediction Flow
```
User → Camera/Gallery → Flutter App → Backend API → ML Model → Results → Firestore
```

1. User captures/selects plant image
2. Image uploaded to backend via multipart form
3. Backend preprocesses image for ML model
4. ML model analyzes image and returns prediction
5. Results formatted and returned to Flutter app
6. Prediction saved to Firestore for history

### 3. Data Synchronization Flow
```
Flutter App ↔ Firebase Firestore ↔ Backend API
```

1. Flutter app reads/writes to Firestore directly
2. Backend API also reads/writes to Firestore
3. Real-time updates via Firestore listeners
4. Offline support with Firestore caching

## Technology Stack

### Frontend (Flutter)
- **Language**: Dart 3.0+
- **Framework**: Flutter 3.0+
- **State Management**: Riverpod 2.4+
- **HTTP Client**: Dio 5.3+
- **Image Handling**: Image Picker, Cached Network Image
- **Firebase**: Core, Auth, Firestore, Storage
- **UI Components**: Material Design 3

### Backend (FastAPI)
- **Language**: Python 3.9+
- **Framework**: FastAPI 0.104+
- **ASGI Server**: Uvicorn
- **Authentication**: Firebase Admin SDK
- **Database**: Firebase Firestore
- **ML Framework**: TensorFlow 2.15
- **Image Processing**: Pillow, OpenCV
- **Validation**: Pydantic 2.5+

### Infrastructure
- **Containerization**: Docker
- **Orchestration**: Docker Compose
- **Cloud Platform**: Render/Google Cloud/AWS
- **CDN**: CloudFlare (optional)
- **Monitoring**: Built-in health checks

### Development Tools
- **Version Control**: Git
- **CI/CD**: GitHub Actions
- **Testing**: Pytest, Flutter Test
- **Code Quality**: Black, Flake8, MyPy
- **Documentation**: Markdown, OpenAPI

## Security Architecture

### Authentication & Authorization
- **Firebase Authentication**: Secure user management
- **JWT Tokens**: Stateless authentication
- **Token Verification**: Server-side validation
- **Role-Based Access**: User permissions

### Data Security
- **Encryption in Transit**: HTTPS/TLS 1.3
- **Encryption at Rest**: Firebase encryption
- **Input Validation**: Pydantic models
- **SQL Injection Prevention**: Firestore NoSQL
- **XSS Protection**: Input sanitization

### API Security
- **CORS Configuration**: Restricted origins
- **Rate Limiting**: Request throttling
- **Input Validation**: Request/response validation
- **Error Handling**: Secure error messages

## Scalability Considerations

### Horizontal Scaling
- **Stateless Backend**: Easy horizontal scaling
- **Load Balancing**: Nginx load balancer
- **Container Orchestration**: Docker Swarm/Kubernetes
- **Auto-scaling**: Cloud platform auto-scaling

### Performance Optimization
- **Image Compression**: Client-side image optimization
- **Caching**: Redis for frequently accessed data
- **CDN**: Static asset delivery
- **Database Indexing**: Firestore composite indexes

### Monitoring & Observability
- **Health Checks**: Application health monitoring
- **Logging**: Structured logging with correlation IDs
- **Metrics**: Performance and usage metrics
- **Alerting**: Automated alert system

## Deployment Architecture

### Development Environment
```
Developer Machine → Git Repository → Local Docker Compose
```

### Staging Environment
```
Git Push → GitHub Actions → Docker Build → Staging Server
```

### Production Environment
```
Git Push → GitHub Actions → Docker Build → Production Server
```

### Deployment Options

#### Option 1: Render (Recommended for MVP)
- **Backend**: Render Web Service
- **Database**: Firebase Firestore
- **CDN**: Render's built-in CDN
- **SSL**: Automatic SSL certificates

#### Option 2: Google Cloud Platform
- **Backend**: Cloud Run
- **Database**: Firestore
- **Storage**: Cloud Storage
- **CDN**: Cloud CDN

#### Option 3: AWS
- **Backend**: ECS/EKS
- **Database**: Firestore
- **Storage**: S3
- **CDN**: CloudFront

### Environment Configuration
```yaml
# Production
FIREBASE_PROJECT_ID: your-project-id
FIREBASE_PRIVATE_KEY: your-private-key
FIREBASE_CLIENT_EMAIL: your-client-email

# Development
DEBUG: true
LOG_LEVEL: debug
```

## Future Enhancements

### Planned Features
- **Offline Mode**: Local ML model for offline predictions
- **Multi-language Support**: Internationalization
- **Expert Consultation**: Connect with plant experts
- **Community Features**: User-generated content
- **Advanced Analytics**: Detailed usage analytics

### Technical Improvements
- **Microservices**: Split into smaller services
- **Event-Driven Architecture**: Async communication
- **Advanced ML**: Ensemble models, transfer learning
- **Real-time Features**: WebSocket support
- **Mobile Optimization**: Native performance improvements

---

*This system design document provides a comprehensive overview of the Plant Disease Detector architecture. For implementation details, refer to the individual component documentation.*





