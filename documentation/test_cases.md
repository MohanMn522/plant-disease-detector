# Plant Disease Detector - Test Cases

## Table of Contents
1. [Test Strategy](#test-strategy)
2. [Unit Tests](#unit-tests)
3. [Integration Tests](#integration-tests)
4. [End-to-End Tests](#end-to-end-tests)
5. [Performance Tests](#performance-tests)
6. [Security Tests](#security-tests)
7. [Test Automation](#test-automation)

## Test Strategy

### Testing Pyramid
```
                    /\
                   /  \
                  /E2E \
                 /______\
                /        \
               /Integration\
              /____________\
             /              \
            /   Unit Tests   \
           /__________________\
```

### Test Coverage Goals
- **Unit Tests**: 80%+ code coverage
- **Integration Tests**: Critical user flows
- **E2E Tests**: Complete user journeys
- **Performance Tests**: Response time < 5s
- **Security Tests**: Authentication & authorization

## Unit Tests

### Flutter App Tests

#### Authentication Tests
```dart
// test/services/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plant_disease_detector/services/auth_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      authService = AuthService();
    });

    test('should sign in with email and password successfully', () async {
      // Arrange
      when(mockAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => UserCredential());

      // Act
      final result = await authService.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result, isNotNull);
      verify(mockAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('should handle invalid credentials', () async {
      // Arrange
      when(mockAuth.signInWithEmailAndPassword(
        email: 'invalid@example.com',
        password: 'wrongpassword',
      )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      // Act & Assert
      expect(
        () => authService.signInWithEmailAndPassword(
          email: 'invalid@example.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
```

#### Prediction Service Tests
```dart
// test/services/prediction_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plant_disease_detector/services/api_service.dart';
import 'package:plant_disease_detector/models/prediction_result.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  group('PredictionService Tests', () {
    late MockApiService mockApiService;
    late PredictionController controller;

    setUp(() {
      mockApiService = MockApiService();
      controller = PredictionController(mockApiService);
    });

    test('should analyze image successfully', () async {
      // Arrange
      final mockResult = PredictionResult(
        id: 'test-id',
        plantName: 'Tomato',
        diseaseName: 'Bacterial Spot',
        confidence: 0.85,
        description: 'Test description',
        symptoms: ['Symptom 1', 'Symptom 2'],
        treatments: ['Treatment 1', 'Treatment 2'],
        preventionTips: ['Prevention 1', 'Prevention 2'],
        timestamp: DateTime.now(),
      );

      when(mockApiService.uploadAndPredict(any))
          .thenAnswer((_) async => mockResult);

      // Act
      final result = await controller.analyzeImage(File('test_image.jpg'));

      // Assert
      expect(result, equals(mockResult));
      expect(controller.state.history, contains(mockResult));
    });

    test('should handle API errors gracefully', () async {
      // Arrange
      when(mockApiService.uploadAndPredict(any))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => controller.analyzeImage(File('test_image.jpg')),
        throwsA(isA<Exception>()),
      );
    });
  });
}
```

### Backend API Tests

#### ML Service Tests
```python
# tests/test_ml_service.py
import pytest
import numpy as np
from unittest.mock import Mock, patch
from app.services.ml_service import MLService

class TestMLService:
    @pytest.fixture
    def ml_service(self):
        return MLService()

    @pytest.mark.asyncio
    async def test_predict_disease_success(self, ml_service):
        # Arrange
        mock_image_data = b"fake_image_data"
        mock_prediction = np.array([[0.1, 0.2, 0.7]])  # 70% confidence for class 2
        
        with patch.object(ml_service, 'model') as mock_model:
            mock_model.predict.return_value = mock_prediction
            ml_service.class_names = ['Class1', 'Class2', 'Class3']
            ml_service.disease_info = {
                'Class3': {
                    'description': 'Test disease',
                    'symptoms': ['Symptom 1'],
                    'treatments': ['Treatment 1'],
                    'prevention_tips': ['Prevention 1']
                }
            }
            ml_service.is_initialized = True

            # Act
            result = await ml_service.predict_disease(mock_image_data)

            # Assert
            assert result['confidence'] == 0.7
            assert result['disease_name'] == 'Class3'
            assert 'symptoms' in result
            assert 'treatments' in result

    @pytest.mark.asyncio
    async def test_predict_disease_not_initialized(self, ml_service):
        # Arrange
        ml_service.is_initialized = False
        mock_image_data = b"fake_image_data"

        # Act & Assert
        with pytest.raises(Exception, match="ML service not initialized"):
            await ml_service.predict_disease(mock_image_data)

    def test_preprocess_image(self, ml_service):
        # Arrange
        mock_image_data = b"fake_image_data"
        
        with patch('PIL.Image.open') as mock_image_open:
            mock_image = Mock()
            mock_image.mode = 'RGB'
            mock_image.resize.return_value = mock_image
            mock_image_open.return_value = mock_image
            
            with patch('numpy.array') as mock_array:
                mock_array.return_value = np.array([[[1, 2, 3]]])
                
                # Act
                result = ml_service._preprocess_image(mock_image_data)
                
                # Assert
                assert result.shape == (1, 224, 224, 3)
                mock_image.resize.assert_called_once_with((224, 224))
```

#### Firebase Service Tests
```python
# tests/test_firebase_service.py
import pytest
from unittest.mock import Mock, patch
from app.services.firebase_service import FirebaseService
from app.models.prediction import PredictionResponse

class TestFirebaseService:
    @pytest.fixture
    def firebase_service(self):
        return FirebaseService()

    @pytest.mark.asyncio
    async def test_save_prediction_success(self, firebase_service):
        # Arrange
        mock_prediction = PredictionResponse(
            id='test-id',
            plantName='Tomato',
            diseaseName='Bacterial Spot',
            confidence=0.85,
            description='Test description',
            symptoms=['Symptom 1'],
            treatments=['Treatment 1'],
            preventionTips=['Prevention 1'],
            isHealthy=False,
            timestamp=datetime.now()
        )
        
        with patch.object(firebase_service, 'db') as mock_db:
            mock_collection = Mock()
            mock_document = Mock()
            mock_db.collection.return_value = mock_collection
            mock_collection.document.return_value = mock_document
            mock_document.collection.return_value = mock_collection
            mock_collection.document.return_value = mock_document
            
            firebase_service.is_initialized = True

            # Act
            result = await firebase_service.save_prediction('user123', mock_prediction)

            # Assert
            assert result is True
            mock_document.set.assert_called_once()

    @pytest.mark.asyncio
    async def test_get_prediction_history(self, firebase_service):
        # Arrange
        mock_doc1 = Mock()
        mock_doc1.to_dict.return_value = {
            'id': 'pred1',
            'plantName': 'Tomato',
            'diseaseName': 'Bacterial Spot',
            'confidence': 0.85,
            'description': 'Test',
            'symptoms': [],
            'treatments': [],
            'preventionTips': [],
            'isHealthy': False,
            'timestamp': datetime.now()
        }
        
        with patch.object(firebase_service, 'db') as mock_db:
            mock_collection = Mock()
            mock_document = Mock()
            mock_db.collection.return_value = mock_collection
            mock_collection.document.return_value = mock_document
            mock_document.collection.return_value = mock_collection
            mock_collection.order_by.return_value = mock_collection
            mock_collection.limit.return_value = mock_collection
            mock_collection.stream.return_value = [mock_doc1]
            
            firebase_service.is_initialized = True

            # Act
            result = await firebase_service.get_prediction_history('user123')

            # Assert
            assert len(result) == 1
            assert result[0].plantName == 'Tomato'
```

## Integration Tests

### API Integration Tests
```python
# tests/test_api_integration.py
import pytest
from fastapi.testclient import TestClient
from app.main import app
from unittest.mock import patch

client = TestClient(app)

class TestAPIIntegration:
    @pytest.fixture
    def mock_auth_token(self):
        return "valid_firebase_token"

    @patch('firebase_admin.auth.verify_id_token')
    def test_predict_endpoint_success(self, mock_verify_token, mock_auth_token):
        # Arrange
        mock_verify_token.return_value = {'uid': 'user123'}
        
        with open('tests/test_image.jpg', 'rb') as f:
            image_data = f.read()

        # Act
        response = client.post(
            '/predict',
            files={'image': ('test.jpg', image_data, 'image/jpeg')},
            data={'userId': 'user123'},
            headers={'Authorization': f'Bearer {mock_auth_token}'}
        )

        # Assert
        assert response.status_code == 200
        data = response.json()
        assert 'plantName' in data
        assert 'diseaseName' in data
        assert 'confidence' in data

    @patch('firebase_admin.auth.verify_id_token')
    def test_history_endpoint_success(self, mock_verify_token, mock_auth_token):
        # Arrange
        mock_verify_token.return_value = {'uid': 'user123'}

        # Act
        response = client.get(
            '/history/user123',
            headers={'Authorization': f'Bearer {mock_auth_token}'}
        )

        # Assert
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)

    def test_health_check_endpoint(self):
        # Act
        response = client.get('/health')

        # Assert
        assert response.status_code == 200
        data = response.json()
        assert data['status'] == 'healthy'
```

### Flutter Integration Tests
```dart
// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:plant_disease_detector/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('Complete user flow test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test login flow
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Test detection flow
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gallery'));
      await tester.pumpAndSettle();

      // Simulate image selection
      await tester.tap(find.text('Analyze Plant'));
      await tester.pumpAndSettle();

      // Verify results page
      expect(find.text('Analysis Results'), findsOneWidget);
    });

    testWidgets('History page navigation test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to history
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      // Verify history page
      expect(find.text('Prediction History'), findsOneWidget);
    });
  });
}
```

## End-to-End Tests

### User Journey Tests

#### Test Case 1: New User Registration and First Prediction
```gherkin
Feature: New User Registration and First Prediction
  As a new user
  I want to register and make my first prediction
  So that I can start using the app

  Scenario: Successful registration and prediction
    Given I am a new user
    When I open the app
    Then I should see the login screen
    
    When I tap "Sign Up"
    And I enter my email "newuser@example.com"
    And I enter my password "password123"
    And I enter my full name "New User"
    And I tap "Create Account"
    Then I should be logged in successfully
    
    When I tap the camera icon
    And I select "Gallery"
    And I choose a plant image
    And I tap "Analyze Plant"
    Then I should see the analysis results
    And the results should contain plant name and disease information
    
    When I tap the history icon
    Then I should see my prediction in the history
```

#### Test Case 2: Existing User Login and Multiple Predictions
```gherkin
Feature: Existing User Login and Multiple Predictions
  As an existing user
  I want to login and make multiple predictions
  So that I can track my plants' health over time

  Scenario: Login and make multiple predictions
    Given I am an existing user with email "user@example.com"
    When I open the app
    And I enter my email "user@example.com"
    And I enter my password "password123"
    And I tap "Sign In"
    Then I should be logged in successfully
    
    When I make a prediction for a tomato plant
    And I make a prediction for a corn plant
    And I make a prediction for an apple tree
    Then I should have 3 predictions in my history
    
    When I view my prediction history
    Then I should see all 3 predictions
    And I should be able to view details for each prediction
```

### API E2E Tests
```python
# tests/test_e2e_api.py
import pytest
import requests
import time

class TestE2EAPI:
    BASE_URL = "https://your-api-url.com"
    
    def test_complete_prediction_flow(self):
        # 1. Health check
        response = requests.get(f"{self.BASE_URL}/health")
        assert response.status_code == 200
        
        # 2. Authentication (mock)
        auth_token = "valid_firebase_token"
        
        # 3. Upload image and predict
        with open('tests/sample_plant_image.jpg', 'rb') as f:
            files = {'image': f}
            data = {'userId': 'test_user_123'}
            headers = {'Authorization': f'Bearer {auth_token}'}
            
            response = requests.post(
                f"{self.BASE_URL}/predict",
                files=files,
                data=data,
                headers=headers
            )
            
            assert response.status_code == 200
            prediction_data = response.json()
            assert 'id' in prediction_data
            prediction_id = prediction_data['id']
        
        # 4. Get prediction history
        response = requests.get(
            f"{self.BASE_URL}/history/test_user_123",
            headers=headers
        )
        assert response.status_code == 200
        history = response.json()
        assert len(history) >= 1
        
        # 5. Verify prediction is in history
        prediction_found = any(p['id'] == prediction_id for p in history)
        assert prediction_found
        
        # 6. Delete prediction
        response = requests.delete(
            f"{self.BASE_URL}/prediction/{prediction_id}",
            headers=headers
        )
        assert response.status_code == 200
        
        # 7. Verify prediction is deleted
        response = requests.get(
            f"{self.BASE_URL}/history/test_user_123",
            headers=headers
        )
        history_after_delete = response.json()
        prediction_still_exists = any(p['id'] == prediction_id for p in history_after_delete)
        assert not prediction_still_exists
```

## Performance Tests

### Load Testing
```python
# tests/test_performance.py
import pytest
import asyncio
import aiohttp
import time
from concurrent.futures import ThreadPoolExecutor

class TestPerformance:
    BASE_URL = "https://your-api-url.com"
    
    @pytest.mark.asyncio
    async def test_concurrent_predictions(self):
        """Test API performance under concurrent load"""
        async def make_prediction(session, user_id):
            with open('tests/sample_plant_image.jpg', 'rb') as f:
                data = aiohttp.FormData()
                data.add_field('image', f, filename='test.jpg', content_type='image/jpeg')
                data.add_field('userId', user_id)
                
                async with session.post(
                    f"{self.BASE_URL}/predict",
                    data=data,
                    headers={'Authorization': 'Bearer valid_token'}
                ) as response:
                    return await response.json()
        
        # Test with 10 concurrent requests
        async with aiohttp.ClientSession() as session:
            start_time = time.time()
            
            tasks = [
                make_prediction(session, f"user_{i}")
                for i in range(10)
            ]
            
            results = await asyncio.gather(*tasks)
            end_time = time.time()
            
            # Assertions
            assert len(results) == 10
            assert all('id' in result for result in results)
            assert (end_time - start_time) < 30  # Should complete within 30 seconds
    
    def test_response_time_under_load(self):
        """Test response times under various load conditions"""
        def make_request():
            start_time = time.time()
            response = requests.get(f"{self.BASE_URL}/health")
            end_time = time.time()
            return end_time - start_time, response.status_code
        
        # Test with 50 concurrent requests
        with ThreadPoolExecutor(max_workers=50) as executor:
            futures = [executor.submit(make_request) for _ in range(50)]
            results = [future.result() for future in futures]
        
        response_times = [result[0] for result in results]
        status_codes = [result[1] for result in results]
        
        # Assertions
        assert all(code == 200 for code in status_codes)
        assert max(response_times) < 5.0  # Max response time < 5 seconds
        assert sum(response_times) / len(response_times) < 2.0  # Avg response time < 2 seconds
```

### Mobile App Performance Tests
```dart
// test/performance_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:plant_disease_detector/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Tests', () {
    testWidgets('App startup time test', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      app.main();
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // App should start within 3 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
    });

    testWidgets('Image upload performance test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to detection page
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();
      
      // Simulate image selection and analysis
      await tester.tap(find.text('Gallery'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Analyze Plant'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Analysis should complete within 15 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(15000));
    });
  });
}
```

## Security Tests

### Authentication Security Tests
```python
# tests/test_security.py
import pytest
import requests
from unittest.mock import patch

class TestSecurity:
    BASE_URL = "https://your-api-url.com"
    
    def test_invalid_token_rejection(self):
        """Test that invalid tokens are rejected"""
        response = requests.get(
            f"{self.BASE_URL}/history/user123",
            headers={'Authorization': 'Bearer invalid_token'}
        )
        assert response.status_code == 401
    
    def test_missing_token_rejection(self):
        """Test that missing tokens are rejected"""
        response = requests.get(f"{self.BASE_URL}/history/user123")
        assert response.status_code == 401
    
    def test_user_id_mismatch_rejection(self):
        """Test that user ID mismatch is rejected"""
        with patch('firebase_admin.auth.verify_id_token') as mock_verify:
            mock_verify.return_value = {'uid': 'user123'}
            
            response = requests.get(
                f"{self.BASE_URL}/history/user456",
                headers={'Authorization': 'Bearer valid_token'}
            )
            assert response.status_code == 403
    
    def test_sql_injection_protection(self):
        """Test protection against SQL injection"""
        malicious_user_id = "user123'; DROP TABLE users; --"
        
        with patch('firebase_admin.auth.verify_id_token') as mock_verify:
            mock_verify.return_value = {'uid': 'user123'}
            
            response = requests.get(
                f"{self.BASE_URL}/history/{malicious_user_id}",
                headers={'Authorization': 'Bearer valid_token'}
            )
            # Should not cause server error
            assert response.status_code in [200, 403, 404]
    
    def test_file_upload_security(self):
        """Test file upload security"""
        # Test with non-image file
        with open('tests/malicious_file.txt', 'rb') as f:
            files = {'image': f}
            data = {'userId': 'user123'}
            headers = {'Authorization': 'Bearer valid_token'}
            
            response = requests.post(
                f"{self.BASE_URL}/predict",
                files=files,
                data=data,
                headers=headers
            )
            assert response.status_code == 400
```

## Test Automation

### CI/CD Pipeline
```yaml
# .github/workflows/test.yml
name: Test Suite

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.9'
    
    - name: Install dependencies
      run: |
        cd backend
        pip install -r requirements.txt
        pip install pytest pytest-asyncio pytest-cov
    
    - name: Run unit tests
      run: |
        cd backend
        pytest tests/ -v --cov=app --cov-report=xml
    
    - name: Run integration tests
      run: |
        cd backend
        pytest tests/test_api_integration.py -v
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./backend/coverage.xml

  flutter-tests:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.0.0'
    
    - name: Install dependencies
      run: |
        cd flutter_app
        flutter pub get
    
    - name: Run unit tests
      run: |
        cd flutter_app
        flutter test
    
    - name: Run integration tests
      run: |
        cd flutter_app
        flutter test integration_test/
```

### Test Data Management
```python
# tests/conftest.py
import pytest
import tempfile
import os
from PIL import Image

@pytest.fixture
def sample_image():
    """Create a sample test image"""
    # Create a temporary image file
    temp_file = tempfile.NamedTemporaryFile(suffix='.jpg', delete=False)
    
    # Create a simple test image
    image = Image.new('RGB', (224, 224), color='green')
    image.save(temp_file.name, 'JPEG')
    
    yield temp_file.name
    
    # Cleanup
    os.unlink(temp_file.name)

@pytest.fixture
def mock_firebase_token():
    """Mock Firebase authentication token"""
    return {
        'uid': 'test_user_123',
        'email': 'test@example.com',
        'name': 'Test User'
    }
```

---

*This test cases document provides comprehensive testing strategies for the Plant Disease Detector application. Regular testing ensures reliability, performance, and security of the system.*





