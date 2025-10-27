import firebase_admin
from firebase_admin import firestore
from typing import List, Optional
import logging
from datetime import datetime
import json

from  app.models.prediction import PredictionResponse

logger = logging.getLogger(__name__)

class FirebaseService:
    def __init__(self):
        self.db = None
        self.is_initialized = False
        
    def initialize(self):
        """Initialize Firestore client"""
        try:
            if firebase_admin._apps:
                self.db = firestore.client()
                self.is_initialized = True
                logger.info("Firebase service initialized successfully")
            else:
                logger.error("Firebase Admin SDK not initialized")
                raise Exception("Firebase Admin SDK not initialized")
        except Exception as e:
            logger.error(f"Failed to initialize Firebase service: {e}")
            raise
    
    async def save_prediction(self, user_id: str, prediction: PredictionResponse) -> bool:
        """Save prediction to Firestore"""
        try:
            if not self.is_initialized:
                self.initialize()
            
            # Convert prediction to dictionary
            prediction_data = prediction.dict()
            prediction_data['timestamp'] = prediction.timestamp
            
            # Save to Firestore
            doc_ref = self.db.collection('users').document(user_id).collection('predictions').document(prediction.id)
            doc_ref.set(prediction_data)
            
            # Update user's total predictions count
            user_ref = self.db.collection('users').document(user_id)
            user_ref.update({
                'totalPredictions': firestore.Increment(1),
                'lastPredictionAt': firestore.SERVER_TIMESTAMP
            })
            
            logger.info(f"Prediction saved for user {user_id}: {prediction.id}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to save prediction: {e}")
            return False
    
    async def get_prediction_history(self, user_id: str, limit: int = 50) -> List[PredictionResponse]:
        """Get prediction history for a user"""
        try:
            if not self.is_initialized:
                self.initialize()
            
            # Query predictions from Firestore
            predictions_ref = self.db.collection('users').document(user_id).collection('predictions')
            docs = predictions_ref.order_by('timestamp', direction=firestore.Query.DESCENDING).limit(limit).stream()
            
            predictions = []
            for doc in docs:
                data = doc.to_dict()
                # Convert timestamp back to datetime if it's a Firestore timestamp
                if 'timestamp' in data and hasattr(data['timestamp'], 'timestamp'):
                    data['timestamp'] = data['timestamp'].timestamp()
                    data['timestamp'] = datetime.fromtimestamp(data['timestamp'])
                
                prediction = PredictionResponse(**data)
                predictions.append(prediction)
            
            logger.info(f"Retrieved {len(predictions)} predictions for user {user_id}")
            return predictions
            
        except Exception as e:
            logger.error(f"Failed to get prediction history: {e}")
            return []
    
    async def delete_prediction(self, user_id: str, prediction_id: str) -> bool:
        """Delete a specific prediction"""
        try:
            if not self.is_initialized:
                self.initialize()
            
            # Delete prediction from Firestore
            doc_ref = self.db.collection('users').document(user_id).collection('predictions').document(prediction_id)
            doc = doc_ref.get()
            
            if doc.exists:
                doc_ref.delete()
                
                # Update user's total predictions count
                user_ref = self.db.collection('users').document(user_id)
                user_ref.update({
                    'totalPredictions': firestore.Increment(-1)
                })
                
                logger.info(f"Prediction deleted: {prediction_id}")
                return True
            else:
                logger.warning(f"Prediction not found: {prediction_id}")
                return False
                
        except Exception as e:
            logger.error(f"Failed to delete prediction: {e}")
            return False
    
    async def get_user_profile(self, user_id: str) -> Optional[dict]:
        """Get user profile information"""
        try:
            if not self.is_initialized:
                self.initialize()
            
            doc_ref = self.db.collection('users').document(user_id)
            doc = doc_ref.get()
            
            if doc.exists:
                return doc.to_dict()
            else:
                return None
                
        except Exception as e:
            logger.error(f"Failed to get user profile: {e}")
            return None
    
    async def update_user_profile(self, user_id: str, profile_data: dict) -> bool:
        """Update user profile information"""
        try:
            if not self.is_initialized:
                self.initialize()
            
            # Add timestamp
            profile_data['updatedAt'] = firestore.SERVER_TIMESTAMP
            
            # Update user document
            doc_ref = self.db.collection('users').document(user_id)
            doc_ref.update(profile_data)
            
            logger.info(f"User profile updated: {user_id}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to update user profile: {e}")
            return False
    
    async def get_prediction_stats(self, user_id: str) -> dict:
        """Get prediction statistics for a user"""
        try:
            if not self.is_initialized:
                self.initialize()
            
            # Get total predictions
            predictions_ref = self.db.collection('users').document(user_id).collection('predictions')
            total_predictions = len(list(predictions_ref.stream()))
            
            # Get healthy vs diseased predictions
            healthy_predictions = len(list(predictions_ref.where('isHealthy', '==', True).stream()))
            diseased_predictions = total_predictions - healthy_predictions
            
            # Get most common diseases
            disease_counts = {}
            docs = predictions_ref.where('isHealthy', '==', False).stream()
            for doc in docs:
                data = doc.to_dict()
                disease = data.get('diseaseName', 'Unknown')
                disease_counts[disease] = disease_counts.get(disease, 0) + 1
            
            most_common_disease = max(disease_counts.items(), key=lambda x: x[1])[0] if disease_counts else None
            
            return {
                'total_predictions': total_predictions,
                'healthy_predictions': healthy_predictions,
                'diseased_predictions': diseased_predictions,
                'most_common_disease': most_common_disease,
                'disease_counts': disease_counts
            }
            
        except Exception as e:
            logger.error(f"Failed to get prediction stats: {e}")
            return {
                'total_predictions': 0,
                'healthy_predictions': 0,
                'diseased_predictions': 0,
                'most_common_disease': None,
                'disease_counts': {}
            }
    
    def is_ready(self) -> bool:
        """Check if Firebase service is ready"""
        return self.is_initialized and self.db is not None





