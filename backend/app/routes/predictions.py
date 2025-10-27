from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import firebase_admin.auth as auth
import logging
from typing import List, Optional
from datetime import datetime
import uuid

from  app.models.prediction import PredictionResponse
from  app.services.ml_service import MLService
from  app.services.firebase_service import FirebaseService
from PIL import Image
import numpy as np
import io

logger = logging.getLogger(__name__)
router = APIRouter()
security = HTTPBearer()

# Initialize services
ml_service = MLService()
firebase_service = FirebaseService()

@router.post("/upload", response_model=PredictionResponse)
async def upload_and_predict(
    image: UploadFile = File(...),
    userId: str = Form(...),
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """Upload an image and get plant disease prediction"""
    try:
        # Verify token
        decoded_token = auth.verify_id_token(credentials.credentials)
        if decoded_token.get("uid") != userId:
            raise HTTPException(status_code=403, detail="User ID mismatch")
        
        # Validate image file
        if not image.content_type.startswith("image/"):
            raise HTTPException(status_code=400, detail="File must be an image")
        
        # Read image data
        image_data = await image.read()
        
        # Run ML prediction
        prediction_result = await ml_service.predict_disease(image_data)
        
        # Generate unique prediction ID
        prediction_id = str(uuid.uuid4())
        
        # Create prediction response
        response = PredictionResponse(
            id=prediction_id,
            plantName=prediction_result["plant_name"],
            diseaseName=prediction_result["disease_name"],
            confidence=prediction_result["confidence"],
            description=prediction_result["description"],
            symptoms=prediction_result["symptoms"],
            treatments=prediction_result["treatments"],
            preventionTips=prediction_result["prevention_tips"],
            isHealthy=prediction_result["is_healthy"],
            timestamp=datetime.utcnow()
        )
        
        # Save prediction to Firebase
        await firebase_service.save_prediction(userId, response)
        
        logger.info(f"Prediction completed for user {userId}: {prediction_result['disease_name']}")
        
        return response
        
    except Exception as e:
        logger.error(f"Prediction failed: {e}")
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")

@router.get("/history/{user_id}", response_model=List[PredictionResponse])
async def get_prediction_history(
    user_id: str,
    limit: int = 50,
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """Get prediction history for a user"""
    try:
        # Verify token
        decoded_token = auth.verify_id_token(credentials.credentials)
        if decoded_token.get("uid") != user_id:
            raise HTTPException(status_code=403, detail="User ID mismatch")
        
        # Get history from Firebase
        history = await firebase_service.get_prediction_history(user_id, limit)
        
        return history
        
    except Exception as e:
        logger.error(f"Failed to get history for user {user_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get history: {str(e)}")

@router.delete("/{prediction_id}")
async def delete_prediction(
    prediction_id: str,
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """Delete a specific prediction"""
    try:
        # Verify token
        decoded_token = auth.verify_id_token(credentials.credentials)
        user_id = decoded_token.get("uid")
        
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid user")
        
        # Delete from Firebase
        success = await firebase_service.delete_prediction(user_id, prediction_id)
        
        if not success:
            raise HTTPException(status_code=404, detail="Prediction not found")
        
        return {"message": "Prediction deleted successfully"}
        
    except Exception as e:
        logger.error(f"Failed to delete prediction {prediction_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to delete prediction: {str(e)}")

@router.get("/stats/{user_id}")
async def get_prediction_stats(
    user_id: str,
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """Get prediction statistics for a user"""
    try:
        # Verify token
        decoded_token = auth.verify_id_token(credentials.credentials)
        if decoded_token.get("uid") != user_id:
            raise HTTPException(status_code=403, detail="User ID mismatch")
        
        # Get stats from Firebase
        stats = await firebase_service.get_prediction_stats(user_id)
        
        return stats
        
    except Exception as e:
        logger.error(f"Failed to get stats for user {user_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get stats: {str(e)}")

@router.get("/care-guide")
async def get_care_guide(
    plant: str,
    disease: str = None,
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """Get care guide for a specific plant and disease"""
    try:
        # Verify token
        decoded_token = auth.verify_id_token(credentials.credentials)
        
        # Get care guide
        care_guide = await ml_service.get_care_guide(plant, disease)
        
        return care_guide
        
    except Exception as e:
        logger.error(f"Failed to get care guide: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get care guide: {str(e)}")

@router.post("/predict")
async def predict(file: UploadFile = File(...)):
    """
    Receives an uploaded image and returns the model's prediction.
    """
    try:
        # 1️⃣ Read the uploaded file into memory
        contents = await file.read()
        image = Image.open(io.BytesIO(contents)).convert("RGB")
        
        # 2️⃣ Resize / preprocess image as required by your model
        image = image.resize((224, 224))  # adjust size to your model input
        img_array = np.array(image)
        img_array = np.expand_dims(img_array, axis=0)  # add batch dimension
        img_array = img_array.astype("float32") / 255.0  # normalize if needed

        # 3️⃣ Predict
        prediction = ml_service.model.predict(img_array)
        predicted_class = int(np.argmax(prediction, axis=1)[0])

        # 4️⃣ Return JSON
        return {"prediction": predicted_class}

    except Exception as e:
        return {"detail": f"Prediction failed: {str(e)}"}





