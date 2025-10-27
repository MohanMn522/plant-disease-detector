from fastapi import FastAPI, HTTPException, Depends, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import os
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, auth, firestore
from typing import List, Optional
import logging
from datetime import datetime
import uuid
from fastapi.concurrency import run_in_threadpool
import io

from app.models.prediction import PredictionRequest, PredictionResponse, PredictionHistory
from app.services.ml_service import MLService
from app.services.firebase_service import FirebaseService
from app.routes import auth, predictions, health

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="Plant Disease Detector API",
    description="AI-powered plant disease detection API",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this properly for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Add no-cache headers to every response to avoid any client/proxy caching
@app.middleware("http")
async def add_no_cache_headers(request, call_next):
    response = await call_next(request)
    response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
    return response

load_dotenv()  # Must come first

# Initialize Firebase Admin SDK
def initialize_firebase():
    private_key = os.getenv("FIREBASE_PRIVATE_KEY")
    if not private_key:
        raise ValueError("FIREBASE_PRIVATE_KEY is not set in .env")

    private_key = private_key.replace('\\n', '\n')

    cred_data = {
        "type": "service_account",
        "project_id": os.getenv("FIREBASE_PROJECT_ID"),
        "private_key_id": os.getenv("FIREBASE_PRIVATE_KEY_ID"),
        "private_key": private_key,
        "client_email": os.getenv("FIREBASE_CLIENT_EMAIL"),
        "client_id": os.getenv("FIREBASE_CLIENT_ID"),
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": os.getenv("FIREBASE_CLIENT_CERT_URL")
    }

    if not firebase_admin._apps:
        cred = credentials.Certificate(cred_data)
        firebase_admin.initialize_app(cred)
        print("Firebase initialized successfully!")

# Initialize services
ml_service = MLService()
firebase_service = FirebaseService()
security = HTTPBearer()

# Dependency to verify Firebase token
async def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        # Verify the Firebase token
        decoded_token = auth.verify_id_token(credentials.credentials)
        return decoded_token
    except Exception as e:
        logger.error(f"Token verification failed: {e}")
        raise HTTPException(status_code=401, detail="Invalid authentication token")

# Include routers
app.include_router(health.router, prefix="/health", tags=["health"])
app.include_router(auth.router, prefix="/auth", tags=["authentication"])
app.include_router(predictions.router, prefix="/predictions")

@app.on_event("startup")
async def startup_event():
    # Model is already loaded in MLService __init__, so no need to call initialize
    logger.info("MLService ready!")
    initialize_firebase()
    logger.info("Application startup completed")

@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on shutdown"""
    logger.info("Application shutdown")

# Root endpoint
@app.get("/")
async def root():
    return {
        "message": "Plant Disease Detector API",
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs"
    }

# Health check endpoint
@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "services": {
            "ml_model": ml_service.is_ready(),
            "firebase": firebase_service.is_ready()
        }
    }

# Image upload and prediction endpoint
@app.post("/predict", response_model=PredictionResponse)
async def predict_disease(
    image: UploadFile = File(...),
    userId: str = Form(...),
    token_data: dict = Depends(verify_token)
):
    """
    Upload an image and get plant disease prediction
    """
    try:
        # Validate user ID matches token
        if token_data.get("uid") != userId:
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

# Get prediction history
@app.get("/history/{user_id}", response_model=List[PredictionResponse])
async def get_prediction_history(
    user_id: str,
    token_data: dict = Depends(verify_token)
):
    """
    Get prediction history for a user
    """
    try:
        # Validate user ID matches token
        if token_data.get("uid") != user_id:
            raise HTTPException(status_code=403, detail="User ID mismatch")
        
        # Get history from Firebase
        history = await firebase_service.get_prediction_history(user_id)
        
        return history
        
    except Exception as e:
        logger.error(f"Failed to get history for user {user_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get history: {str(e)}")

# Delete prediction
@app.delete("/prediction/{prediction_id}")
async def delete_prediction(
    prediction_id: str,
    token_data: dict = Depends(verify_token)
):
    """
    Delete a specific prediction
    """
    try:
        user_id = token_data.get("uid")
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

# Get care guide
@app.get("/care-guide")
async def get_care_guide(
    plant: str,
    disease: Optional[str] = None
):
    """
    Get care guide for a specific plant and disease
    """
    try:
        care_guide = await ml_service.get_care_guide(plant, disease)
        return care_guide
        
    except Exception as e:
        logger.error(f"Failed to get care guide: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get care guide: {str(e)}")

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    contents = await file.read()
    if not contents:
        raise HTTPException(status_code=400, detail="Empty file")

    img_io = io.BytesIO(contents)

    try:
        # run blocking prediction in a threadpool
        result = await run_in_threadpool(ml_service.predict, img_io)
        return result  # expects {"predicted_class_index": ..., "confidence": ...}
    except RuntimeError as e:
        raise HTTPException(status_code=503, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction failed: {e}")

if __name__ == "__main__":
    import uvicorn
    # Use uvicorn for running FastAPI; explicit host/port and reload=True (debug-like) set
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)



