from flask import Blueprint, jsonify, request
import numpy as np

from utils.model_loader import load_artifact, load_encoders, load_metadata
from utils.recommendation_catalog import infer_meal_highlight
from utils.preprocess import build_meal_features

meal_bp = Blueprint("meal", __name__)


@meal_bp.post("/meal")
def predict_meal():
    payload = request.get_json(silent=True)
    if payload is None:
        raise ValueError("Request body must be valid JSON.")

    encoders = load_encoders()
    model = load_artifact("food_model.pkl")
    features, cleaned = build_meal_features(payload, encoders)

    prediction = str(model.predict(features)[0])
    prediction = _enforce_meal_constraints(prediction, cleaned)
    metadata = load_metadata()
    meal_highlights = metadata.get("meal_highlights", {})
    highlight = meal_highlights.get(prediction)
    if not isinstance(highlight, str) or not highlight.strip():
        highlight = infer_meal_highlight(prediction)

    confidence = None
    if hasattr(model, "predict_proba"):
        confidence = float(np.max(model.predict_proba(features)[0]))

    restrictions = cleaned["dietary_restrictions"]
    restriction_text = (
        "none"
        if restrictions == ["none"]
        else ", ".join(item.replace("_", " ") for item in restrictions)
    )
    extra = (
        f"Goal: {cleaned['goal']}. "
        f"Diet: {cleaned['diet_type']}. "
        f"Restrictions: {restriction_text}. "
        f"{highlight}"
    )

    return (
        jsonify({"result": prediction, "extra": extra, "confidence": confidence}),
        200,
    )


def _enforce_meal_constraints(prediction: str, cleaned: dict[str, object]) -> str:
    safe_prediction = prediction
    goal = str(cleaned["goal"])
    diet_type = str(cleaned["diet_type"])
    restrictions = set(cleaned["dietary_restrictions"])  # type: ignore[arg-type]

    non_veg_keywords = ("chicken", "fish", "turkey", "beef", "prawn", "shrimp")
    if diet_type == "veg" and any(keyword in safe_prediction.lower() for keyword in non_veg_keywords):
        safe_prediction = {
            "muscle": "High-Protein Chickpea Stir Fry",
            "fat_loss": "Lentil Greens Salad",
            "maintenance": "Veggie Brown Rice Plate",
        }[goal]

    lower_prediction = safe_prediction.lower()
    if "lactose_intolerance" in restrictions and any(
        word in lower_prediction for word in ("milk", "cheese", "whey", "dairy")
    ):
        safe_prediction = "Dairy-Free Protein Bowl"
        lower_prediction = safe_prediction.lower()

    if "nut_allergy" in restrictions and any(
        word in lower_prediction for word in ("almond", "nut")
    ):
        safe_prediction = "Moong Sprout Salad"
        lower_prediction = safe_prediction.lower()

    if "shellfish_allergy" in restrictions and any(
        word in lower_prediction for word in ("shrimp", "prawn", "shellfish")
    ):
        safe_prediction = "Lean Chicken Veg Plate" if diet_type == "non_veg" else "Tofu Power Bowl"

    return safe_prediction
