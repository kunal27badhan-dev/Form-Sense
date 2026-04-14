from flask import Blueprint, jsonify, request

from utils.model_loader import load_artifact, load_encoders
from utils.preprocess import build_weight_features

weight_bp = Blueprint("weight", __name__)


@weight_bp.post("/weight")
def predict_weight():
    payload = request.get_json(silent=True)
    if payload is None:
        raise ValueError("Request body must be valid JSON.")

    encoders = load_encoders()
    model = load_artifact("weight_model.pkl")
    features, cleaned = build_weight_features(payload, encoders)

    prediction = float(model.predict(features)[0])
    result = round(prediction, 2)
    delta = result - float(cleaned["current_weight"])
    weekly_delta = delta / int(cleaned["weeks"])
    if delta <= -0.5:
        trend = "projected loss"
    elif delta >= 0.5:
        trend = "projected gain"
    else:
        trend = "near maintenance"

    extra = (
        f"Estimated after {cleaned['weeks']} week(s) with "
        f"{cleaned['activity_level']} activity and "
        f"{int(cleaned['target_calories'])} kcal/day. "
        f"Trend: {trend} ({delta:+.2f} kg total, {weekly_delta:+.2f} kg/week)."
    )

    return jsonify({"result": result, "extra": extra, "confidence": None}), 200
