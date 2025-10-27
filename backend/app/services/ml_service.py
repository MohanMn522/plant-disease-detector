import os
import numpy as np
# prefer standalone keras when available; fall back to tf.keras
try:
    from keras.models import load_model
except Exception:
    from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.image import load_img, img_to_array
from loguru import logger

MODEL_PATH = os.path.join(os.path.dirname(__file__), "..", "models", "plant_disease_model.h5")

# Load model once at module import (safe to skip compilation to avoid old 'reduction=auto' issues)
try:
    # pass safe_mode=False when using standalone keras (ignored by tf.keras fallback)
    GLOBAL_MODEL = load_model(MODEL_PATH, compile=False, safe_mode=False)
    logger.info(f"✅ Model loaded successfully from: {MODEL_PATH}")
except TypeError:
    # some load_model implementations don't accept safe_mode; retry without it
    try:
        GLOBAL_MODEL = load_model(MODEL_PATH, compile=False)
        logger.info(f"✅ Model loaded successfully from (fallback): {MODEL_PATH}")
    except Exception as e:
        GLOBAL_MODEL = None
        logger.exception(f"Failed to load model from {MODEL_PATH}: {e}")
except Exception as e:
    GLOBAL_MODEL = None
    logger.exception(f"Failed to load model from {MODEL_PATH}: {e}")

class MLService:
    def __init__(self):
        logger.info("Initializing ML service...")
        # Use the globally loaded model instead of loading per-instance
        self.model = GLOBAL_MODEL

    # removed instance-level load_model() to avoid repeated loads
    def preprocess_image(self, image_file, target_size=(224,224)):
        # image_file is typically a file-like object from FastAPI UploadFile
        img = load_img(image_file, target_size=target_size)
        img_array = img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0)
        img_array = img_array.astype("float32") / 255.0
        return img_array

    def predict(self, image_file):
        if self.model is None:
            raise RuntimeError("Model not loaded")
        img_array = self.preprocess_image(image_file)
        preds = self.model.predict(img_array)
        pred_index = int(np.argmax(preds[0]))
        pred_conf = float(np.max(preds[0]))
        # TODO: map pred_index to a class name if available
        return {
            "predicted_class_index": pred_index,
            "confidence": pred_conf
        }



