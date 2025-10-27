from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class PredictionRequest(BaseModel):
    """Request model for prediction"""
    image_url: Optional[str] = None
    user_id: str

class PredictionResponse(BaseModel):
    """Response model for prediction results"""
    id: str
    plantName: str
    diseaseName: str
    confidence: float = Field(..., ge=0.0, le=1.0)
    description: str
    symptoms: List[str]
    treatments: List[str]
    preventionTips: List[str]
    isHealthy: bool = False
    timestamp: datetime
    imageUrl: Optional[str] = None

    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }

class PredictionHistory(BaseModel):
    """Model for prediction history"""
    user_id: str
    predictions: List[PredictionResponse]
    total_count: int

class CareGuideRequest(BaseModel):
    """Request model for care guide"""
    plant_name: str
    disease_name: Optional[str] = None

class CareGuideResponse(BaseModel):
    """Response model for care guide"""
    plant_name: str
    disease_name: Optional[str]
    general_care: List[str]
    disease_specific_care: List[str]
    prevention_tips: List[str]
    treatment_options: List[str]

class MLPredictionResult(BaseModel):
    """Internal model for ML prediction results"""
    plant_name: str
    disease_name: str
    confidence: float
    is_healthy: bool
    description: str
    symptoms: List[str]
    treatments: List[str]
    prevention_tips: List[str]





