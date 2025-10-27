from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import firebase_admin.auth as auth
import logging
from typing import Dict, Any

logger = logging.getLogger(__name__)
router = APIRouter()
security = HTTPBearer()

@router.get("/verify")
async def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Verify Firebase authentication token"""
    try:
        # Verify the Firebase token
        decoded_token = auth.verify_id_token(credentials.credentials)
        
        return {
            "valid": True,
            "uid": decoded_token.get("uid"),
            "email": decoded_token.get("email"),
            "name": decoded_token.get("name"),
            "picture": decoded_token.get("picture")
        }
        
    except Exception as e:
        logger.error(f"Token verification failed: {e}")
        raise HTTPException(status_code=401, detail="Invalid authentication token")

@router.get("/user/{user_id}")
async def get_user_info(
    user_id: str,
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """Get user information from Firebase"""
    try:
        # Verify token first
        decoded_token = auth.verify_id_token(credentials.credentials)
        
        # Check if user ID matches token
        if decoded_token.get("uid") != user_id:
            raise HTTPException(status_code=403, detail="User ID mismatch")
        
        # Get user record from Firebase Auth
        user_record = auth.get_user(user_id)
        
        return {
            "uid": user_record.uid,
            "email": user_record.email,
            "display_name": user_record.display_name,
            "photo_url": user_record.photo_url,
            "email_verified": user_record.email_verified,
            "disabled": user_record.disabled,
            "creation_timestamp": user_record.user_metadata.creation_timestamp,
            "last_sign_in_timestamp": user_record.user_metadata.last_sign_in_timestamp
        }
        
    except auth.UserNotFoundError:
        raise HTTPException(status_code=404, detail="User not found")
    except Exception as e:
        logger.error(f"Failed to get user info: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get user info: {str(e)}")

@router.post("/user/{user_id}/disable")
async def disable_user(
    user_id: str,
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """Disable a user account (admin only)"""
    try:
        # Verify token first
        decoded_token = auth.verify_id_token(credentials.credentials)
        
        # Check if user ID matches token (or implement admin check)
        if decoded_token.get("uid") != user_id:
            raise HTTPException(status_code=403, detail="User ID mismatch")
        
        # Disable user
        auth.update_user(user_id, disabled=True)
        
        return {"message": "User disabled successfully"}
        
    except auth.UserNotFoundError:
        raise HTTPException(status_code=404, detail="User not found")
    except Exception as e:
        logger.error(f"Failed to disable user: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to disable user: {str(e)}")

@router.post("/user/{user_id}/enable")
async def enable_user(
    user_id: str,
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """Enable a user account (admin only)"""
    try:
        # Verify token first
        decoded_token = auth.verify_id_token(credentials.credentials)
        
        # Check if user ID matches token (or implement admin check)
        if decoded_token.get("uid") != user_id:
            raise HTTPException(status_code=403, detail="User ID mismatch")
        
        # Enable user
        auth.update_user(user_id, disabled=False)
        
        return {"message": "User enabled successfully"}
        
    except auth.UserNotFoundError:
        raise HTTPException(status_code=404, detail="User not found")
    except Exception as e:
        logger.error(f"Failed to enable user: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to enable user: {str(e)}")





