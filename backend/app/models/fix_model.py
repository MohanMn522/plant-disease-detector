import tensorflow as tf
from tensorflow.keras.models import load_model, Model, model_from_json
from tensorflow.keras.layers import Input
import os, json, h5py

try:
    print("🔍 Trying to load model directly...")
    model = load_model("plant_disease_model.h5", compile=False)
    print("✅ Model loaded directly.")
except Exception as e:
    print("⚠️ Direct load failed, rebuilding manually:", e)

    with h5py.File("plant_disease_model.h5", "r") as f:
        if "model_config" in f.attrs:
            config_attr = f.attrs["model_config"]
            if isinstance(config_attr, bytes):
                model_config = config_attr.decode("utf-8")
            else:
                model_config = config_attr
        else:
            raise RuntimeError("❌ model_config not found in .h5 file!")

    model = model_from_json(model_config)
    print("✅ Model architecture rebuilt from JSON config.")

# ---- Fix model input shape ----
inp = Input(shape=(224, 224, 3))
try:
    out = model(inp, training=False)
except Exception as e:
    print("⚠️ Could not apply model directly, using last layer output:", e)
    out = model.output

fixed_model = Model(inputs=inp, outputs=out)

# ---- Save fixed model ----
output_path = "plant_disease_model_fixed.h5"
if os.path.exists(output_path):
    os.remove(output_path)

fixed_model.save(output_path)
print(f"✅ Fixed model saved successfully as {output_path}")
