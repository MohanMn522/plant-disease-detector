#!/usr/bin/env python3
"""
Test script to verify backend connection
"""

import requests
import json
import time

def test_backend():
    base_url = "http://localhost:8000"
    
    print("🧪 Testing Plant Disease Detector Backend")
    print("=" * 50)
    
    # Test 1: Health Check
    print("1. Testing health endpoint...")
    try:
        response = requests.get(f"{base_url}/health", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print("✅ Health check passed!")
            print(f"   Status: {data.get('status')}")
            print(f"   ML Model: {data.get('services', {}).get('ml_model')}")
            print(f"   Firebase: {data.get('services', {}).get('firebase')}")
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Cannot connect to backend: {e}")
        print("   Make sure the backend server is running on port 8000")
        return False
    
    # Test 2: Root endpoint
    print("\n2. Testing root endpoint...")
    try:
        response = requests.get(f"{base_url}/", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print("✅ Root endpoint working!")
            print(f"   Message: {data.get('message')}")
            print(f"   Version: {data.get('version')}")
        else:
            print(f"❌ Root endpoint failed: {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"❌ Root endpoint error: {e}")
    
    # Test 3: API Documentation
    print("\n3. Testing API documentation...")
    try:
        response = requests.get(f"{base_url}/docs", timeout=5)
        if response.status_code == 200:
            print("✅ API documentation available!")
            print(f"   Visit: {base_url}/docs")
        else:
            print(f"❌ API documentation failed: {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"❌ API documentation error: {e}")
    
    print("\n" + "=" * 50)
    print("🎉 Backend testing completed!")
    print(f"📚 API Documentation: {base_url}/docs")
    print(f"🔍 Interactive API: {base_url}/redoc")
    
    return True

if __name__ == "__main__":
    test_backend()


