#!/usr/bin/env python3
"""
Simple test script to verify ML service provides different results
"""

import asyncio
import numpy as np
from PIL import Image
import io
import sys
import os

from app.services.ml_service import MLService

def create_test_image(brightness=0.5, color_bias='green'):
    """Create a test image with specific characteristics"""
    # Create a 224x224 RGB image
    image_array = np.random.rand(224, 224, 3) * 0.3  # Base noise
    
    # Apply brightness
    image_array = image_array * brightness
    
    # Apply color bias
    if color_bias == 'green':
        image_array[:, :, 1] += 0.4  # More green
    elif color_bias == 'red':
        image_array[:, :, 0] += 0.4  # More red
    elif color_bias == 'blue':
        image_array[:, :, 2] += 0.4  # More blue
    
    # Add some patterns to make it look more like a leaf
    center_x, center_y = 112, 112
    y, x = np.ogrid[:224, :224]
    mask = ((x - center_x)**2 + (y - center_y)**2) < 10000
    image_array[mask] += 0.2
    
    # Ensure values are in [0, 1] range
    image_array = np.clip(image_array, 0, 1)
    
    # Convert to PIL Image
    image = Image.fromarray((image_array * 255).astype(np.uint8))
    
    # Convert to bytes
    img_byte_arr = io.BytesIO()
    image.save(img_byte_arr, format='JPEG')
    return img_byte_arr.getvalue()

async def test_ml_variety():
    """Test that ML service provides different results for different images"""
    print("🧪 Testing ML Service Variety")
    print("=" * 50)
    
    # Initialize ML service
    ml_service = MLService()
    await ml_service.initialize()
    
    # Test different image types
    test_cases = [
        ("Dark Green Leaf", 0.2, 'green'),
        ("Bright Green Leaf", 0.8, 'green'),
        ("Medium Green Leaf", 0.5, 'green'),
        ("Dark Red Leaf", 0.2, 'red'),
        ("Bright Red Leaf", 0.8, 'red'),
    ]
    
    results = []
    
    for i, (description, brightness, color) in enumerate(test_cases, 1):
        print(f"\n{i}. Testing {description} (brightness: {brightness}, color: {color})")
        
        # Create test image
        image_data = create_test_image(brightness, color)
        
        # Get prediction
        try:
            result = await ml_service.predict_disease(image_data)
            results.append({
                'description': description,
                'plant': result['plant_name'],
                'disease': result['disease_name'],
                'confidence': result['confidence'],
                'is_healthy': result['is_healthy']
            })
            
            print(f"   ✅ Plant: {result['plant_name']}")
            print(f"   ✅ Disease: {result['disease_name']}")
            print(f"   ✅ Confidence: {result['confidence']:.1%}")
            print(f"   ✅ Healthy: {result['is_healthy']}")
            
        except Exception as e:
            print(f"   ❌ Error: {e}")
    
    # Analyze results
    print("\n" + "=" * 50)
    print("📊 Results Analysis")
    print("=" * 50)
    
    # Count unique combinations
    unique_combinations = set()
    plant_counts = {}
    disease_counts = {}
    
    for result in results:
        combo = f"{result['plant']} - {result['disease']}"
        unique_combinations.add(combo)
        
        # Count plants
        plant_counts[result['plant']] = plant_counts.get(result['plant'], 0) + 1
        
        # Count diseases
        disease_counts[result['disease']] = disease_counts.get(result['disease'], 0) + 1
    
    print(f"📈 Total predictions: {len(results)}")
    print(f"🎯 Unique plant-disease combinations: {len(unique_combinations)}")
    print(f"🌱 Different plants detected: {len(plant_counts)}")
    print(f"🦠 Different diseases detected: {len(disease_counts)}")
    
    print(f"\n🌱 Plant Distribution:")
    for plant, count in sorted(plant_counts.items()):
        print(f"   {plant}: {count}")
    
    print(f"\n🦠 Disease Distribution:")
    for disease, count in sorted(disease_counts.items()):
        print(f"   {disease}: {count}")
    
    # Show all unique combinations
    print(f"\n🎯 All Unique Combinations:")
    for i, combo in enumerate(sorted(unique_combinations), 1):
        print(f"   {i}. {combo}")
    
    # Check if we have variety
    if len(unique_combinations) >= 3:
        print(f"\n✅ SUCCESS: ML service provides good variety!")
        print(f"   Different images produce different results")
        return True
    else:
        print(f"\n⚠️  WARNING: Limited variety in predictions")
        print(f"   Consider improving the ML model")
        return False

if __name__ == "__main__":
    success = asyncio.run(test_ml_variety())
    if success:
        print("\n🎉 ML Service is working correctly!")
    else:
        print("\n❌ ML Service needs improvement")


