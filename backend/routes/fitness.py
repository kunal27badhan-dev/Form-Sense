from flask import Blueprint, jsonify, request
import numpy as np

from utils.model_loader import load_artifact, load_encoders, load_metadata
from utils.recommendation_catalog import infer_fitness_guidance
from utils.preprocess import build_fitness_features

fitness_bp = Blueprint("fitness", __name__)


@fitness_bp.post("/fitness")
def predict_fitness():
    payload = request.get_json(silent=True)
    if payload is None:
        raise ValueError("Request body must be valid JSON.")

    encoders = load_encoders()
    model = load_artifact("fitness_model.pkl")
    metadata = load_metadata()
    features, cleaned = build_fitness_features(payload, encoders)

    prediction = str(model.predict(features)[0])
    guidance_map = metadata.get("fitness_guidance", {})
    guidance = guidance_map.get(prediction)
    if not isinstance(guidance, str) or not guidance.strip():
        guidance = infer_fitness_guidance(prediction)

    confidence = None
    if hasattr(model, "predict_proba"):
        confidence = float(np.max(model.predict_proba(features)[0]))

    extra = (
        f"Using BMI {cleaned['bmi']}, resting HR {int(cleaned['resting_heart_rate'])}, "
        f"{cleaned['weekly_workouts']} weekly workout(s), "
        f"{cleaned['activity_level']} activity, and {cleaned['diet_quality']} diet quality. "
        f"Guidance: {guidance}"
    )

    return (
        jsonify({"result": prediction, "extra": extra, "confidence": confidence}),
        200,
    )
