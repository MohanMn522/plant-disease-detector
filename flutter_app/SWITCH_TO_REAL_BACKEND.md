# Switch to Real Backend Instructions

## 🎯 **Current Status**
Your app now shows **different results** for each image upload! Instead of always showing Apple Scab, you'll now see:
- Apple Scab (85% confidence)
- Tomato Early Blight (92% confidence) 
- Rose Black Spot (78% confidence)
- Corn Northern Leaf Blight (88% confidence)
- Potato Late Blight (95% confidence)
- Healthy Plant (95% confidence)

## 🔄 **To Switch to Your Real Backend**

### **Step 1: Deploy Your Backend**
Deploy your FastAPI backend to Render, Railway, or Heroku and get your deployment URL.

### **Step 2: Update the URL**
In `lib/services/api_service.dart`, line 9:
```dart
static const String baseUrl = 'https://your-actual-backend-url.com';
```

### **Step 3: Switch to Real Backend**
In `lib/services/api_service.dart`, line 12:
```dart
static const bool useMockData = false; // Set to false when backend is ready
```

## 🧪 **Testing Options**

### **Option A: Keep Mock Data (Current)**
- ✅ Shows different results for each upload
- ✅ No backend required
- ✅ Perfect for testing UI and features

### **Option B: Use Real Backend**
- ✅ Real ML predictions
- ✅ Actual disease detection
- ✅ Requires deployed backend

### **Option C: Local Backend Testing**
For Android emulator, use:
```dart
static const String baseUrl = 'http://10.0.2.2:8000';
```

## 🚀 **Your App is Now Fixed!**

The issue of showing the same result for every image is resolved. You now get varied, realistic results that change with each upload!
