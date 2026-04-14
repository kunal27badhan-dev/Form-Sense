from flask import Blueprint, jsonify, request
import numpy as np

from utils.model_loader import load_artifact, load_encoders, load_metadata
from utils.recommendation_catalog import infer_workout_exercises
from utils.preprocess import build_workout_features

workout_bp = Blueprint("workout", __name__)


@workout_bp.post("/workout")
def predict_workout():
    payload = request.get_json(silent=True)
    if payload is None:
        raise ValueError("Request body must be valid JSON.")

    encoders = load_encoders()
    model = load_artifact("workout_model.pkl")
    features, cleaned = build_workout_features(payload, encoders)

    prediction = str(model.predict(features)[0])
    metadata = load_metadata()
    exercise_map = metadata.get("workout_plan_exercises", {})
    exercises = exercise_map.get(prediction, [])
    if not isinstance(exercises, list) or not exercises:
        exercises = infer_workout_exercises(prediction)
    exercise_text = ", ".join(str(item) for item in exercises[:5])

    confidence = None
    if hasattr(model, "predict_proba"):
        confidence = float(np.max(model.predict_proba(features)[0]))

    result = exercise_text or prediction
    extra = (
        f"Plan: {prediction}. "
        f"Built for {cleaned['fitness_level']} level, "
        f"{cleaned['goal']} goal, "
        f"{cleaned['session_minutes']} minute session."
    )

    return (
        jsonify({"result": result, "extra": extra, "confidence": confidence}),
        200,
    )
