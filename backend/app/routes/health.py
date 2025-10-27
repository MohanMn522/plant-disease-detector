from fastapi import APIRouter, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import logging
from datetime import datetime

from ..services.ml_service import MLService
from ..services.firebase_service import FirebaseService

logger = logging.getLogger(__name__)
router = APIRouter()
security = HTTPBearer()

# Initialize services
ml_service = MLService()
firebase_service = FirebaseService()

@router.get("/")
async def health_check():
    """Basic health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "service": "plant-disease-detector-api"
    }

@router.get("/detailed")
async def detailed_health_check():
    """Detailed health check with service status"""
    try:
        # Check ML service
        ml_ready = ml_service.is_ready()
        
        # Check Firebase service
        firebase_ready = firebase_service.is_ready()
        
        # Overall health status
        overall_healthy = ml_ready and firebase_ready
        
        return {
            "status": "healthy" if overall_healthy else "degraded",
            "timestamp": datetime.utcnow().isoformat(),
            "services": {
                "ml_model": {
                    "status": "ready" if ml_ready else "not_ready",
                    "initialized": ml_ready
                },
                "firebase": {
                    "status": "ready" if firebase_ready else "not_ready",
                    "initialized": firebase_ready
                }
            },
            "overall_healthy": overall_healthy
        }
        
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return {
            "status": "unhealthy",
            "timestamp": datetime.utcnow().isoformat(),
            "error": str(e),
            "services": {
                "ml_model": {"status": "error"},
                "firebase": {"status": "error"}
            },
            "overall_healthy": False
        }

@router.get("/ready")
async def readiness_check():
    """Kubernetes-style readiness check"""
    try:
        ml_ready = ml_service.is_ready()
        firebase_ready = firebase_service.is_ready()
        
        if ml_ready and firebase_ready:
            return {"status": "ready"}
        else:
            return {"status": "not_ready"}
            
    except Exception as e:
        logger.error(f"Readiness check failed: {e}")
        return {"status": "not_ready", "error": str(e)}

@router.get("/live")
async def liveness_check():
    """Kubernetes-style liveness check"""
    return {"status": "alive", "timestamp": datetime.utcnow().isoformat()}





