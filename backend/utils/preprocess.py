from __future__ import annotations

from typing import Any, Mapping

import numpy as np

DIET_TYPES = ("veg", "non_veg")
DIETARY_RESTRICTIONS = (
    "none",
    "lactose_intolerance",
    "nut_allergy",
    "gluten_intolerance",
    "egg_allergy",
    "soy_allergy",
    "shellfish_allergy",
)
RESTRICTION_FEATURES = tuple(
    restriction for restriction in DIETARY_RESTRICTIONS if restriction != "none"
)
GOALS = ("muscle", "fat_loss", "maintenance")
FITNESS_LEVELS = ("beginner", "intermediate", "advanced")
ACTIVITY_LEVELS = ("low", "moderate", "high")
DIET_QUALITY_LEVELS = ("poor", "average", "good")


def build_meal_features(
    payload: Mapping[str, Any], encoders: Mapping[str, Mapping[str, int]]
) -> tuple[np.ndarray, dict[str, Any]]:
    data = _ensure_json_object(payload)
    protein = _parse_number(data.get("protein"), "protein", min_value=0, max_value=400)
    calories = _parse_number(
        data.get("calories"), "calories", min_value=0, max_value=10000
    )
    diet_type = _parse_enum(data.get("diet_type"), DIET_TYPES, "diet_type")
    goal = _parse_enum(data.get("goal"), GOALS, "goal")
    dietary_restrictions = _parse_restrictions(data.get("dietary_restrictions"))
    allergy_note = _parse_optional_text(data.get("allergy_note"), "allergy_note")

    feature_values = [
        protein,
        calories,
        _encode_enum(diet_type, encoders["diet_type"], "diet_type"),
        _encode_enum(goal, encoders["goal"], "goal"),
        *_restriction_flags(dietary_restrictions),
    ]

    cleaned_payload = {
        "protein": protein,
        "calories": calories,
        "diet_type": diet_type,
        "goal": goal,
        "dietary_restrictions": dietary_restrictions,
        "allergy_note": allergy_note,
    }
    return np.asarray([feature_values], dtype=float), cleaned_payload


def build_workout_features(
    payload: Mapping[str, Any], encoders: Mapping[str, Mapping[str, int]]
) -> tuple[np.ndarray, dict[str, Any]]:
    data = _ensure_json_object(payload)
    fitness_level = _parse_enum(
        data.get("fitness_level"), FITNESS_LEVELS, "fitness_level"
    )
    goal = _parse_enum(data.get("goal"), GOALS, "goal")
    session_minutes = _parse_number(
        data.get("session_minutes"),
        "session_minutes",
        min_value=5,
        max_value=300,
        integer=True,
    )
    activity_level = _parse_enum(
        data.get("activity_level"), ACTIVITY_LEVELS, "activity_level"
    )

    feature_values = [
        _encode_enum(fitness_level, encoders["fitness_level"], "fitness_level"),
        _encode_enum(goal, encoders["goal"], "goal"),
        session_minutes,
        _encode_enum(activity_level, encoders["activity_level"], "activity_level"),
    ]

    cleaned_payload = {
        "fitness_level": fitness_level,
        "goal": goal,
        "session_minutes": int(session_minutes),
        "activity_level": activity_level,
    }
    return np.asarray([feature_values], dtype=float), cleaned_payload


def build_weight_features(
    payload: Mapping[str, Any], encoders: Mapping[str, Mapping[str, int]]
) -> tuple[np.ndarray, dict[str, Any]]:
    data = _ensure_json_object(payload)
    current_weight = _parse_number(
        data.get("current_weight"), "current_weight", min_value=20, max_value=300
    )
    target_calories = _parse_number(
        data.get("target_calories"), "target_calories", min_value=500, max_value=6000
    )
    activity_level = _parse_enum(
        data.get("activity_level"), ACTIVITY_LEVELS, "activity_level"
    )
    weeks = _parse_number(
        data.get("weeks"), "weeks", min_value=1, max_value=104, integer=True
    )
    avg_daily_steps = _parse_number(
        data.get("avg_daily_steps"), "avg_daily_steps", min_value=0, max_value=50000
    )

    feature_values = [
        current_weight,
        target_calories,
        _encode_enum(activity_level, encoders["activity_level"], "activity_level"),
        weeks,
        avg_daily_steps,
    ]

    cleaned_payload = {
        "current_weight": current_weight,
        "target_calories": target_calories,
        "activity_level": activity_level,
        "weeks": int(weeks),
        "avg_daily_steps": avg_daily_steps,
    }
    return np.asarray([feature_values], dtype=float), cleaned_payload


def build_fitness_features(
    payload: Mapping[str, Any], encoders: Mapping[str, Mapping[str, int]]
) -> tuple[np.ndarray, dict[str, Any]]:
    data = _ensure_json_object(payload)
    bmi = _parse_number(data.get("bmi"), "bmi", min_value=10, max_value=80)
    resting_heart_rate = _parse_number(
        data.get("resting_heart_rate"),
        "resting_heart_rate",
        min_value=30,
        max_value=220,
    )
    weekly_workouts = _parse_number(
        data.get("weekly_workouts"),
        "weekly_workouts",
        min_value=0,
        max_value=30,
        integer=True,
    )
    activity_level = _parse_enum(
        data.get("activity_level"), ACTIVITY_LEVELS, "activity_level"
    )
    diet_quality = _parse_enum(
        data.get("diet_quality"), DIET_QUALITY_LEVELS, "diet_quality"
    )

    feature_values = [
        bmi,
        resting_heart_rate,
        weekly_workouts,
        _encode_enum(activity_level, encoders["activity_level"], "activity_level"),
        _encode_enum(diet_quality, encoders["diet_quality"], "diet_quality"),
    ]

    cleaned_payload = {
        "bmi": bmi,
        "resting_heart_rate": resting_heart_rate,
        "weekly_workouts": int(weekly_workouts),
        "activity_level": activity_level,
        "diet_quality": diet_quality,
    }
    return np.asarray([feature_values], dtype=float), cleaned_payload


def _ensure_json_object(payload: Mapping[str, Any]) -> Mapping[str, Any]:
    if not isinstance(payload, Mapping):
        raise ValueError("Request body must be a JSON object.")
    return payload


def _parse_number(
    value: Any,
    field_name: str,
    *,
    min_value: float | None = None,
    max_value: float | None = None,
    integer: bool = False,
) -> float:
    try:
        number = float(value)
    except (TypeError, ValueError):
        raise ValueError(f"Field '{field_name}' must be a number.") from None

    if min_value is not None and number < min_value:
        raise ValueError(f"Field '{field_name}' must be >= {min_value}.")
    if max_value is not None and number > max_value:
        raise ValueError(f"Field '{field_name}' must be <= {max_value}.")
    if integer and not number.is_integer():
        raise ValueError(f"Field '{field_name}' must be an integer.")
    return int(number) if integer else number


def _parse_enum(value: Any, allowed: tuple[str, ...], field_name: str) -> str:
    if not isinstance(value, str):
        raise ValueError(
            f"Field '{field_name}' must be one of: {', '.join(allowed)}."
        )
    normalized = value.strip().lower()
    if normalized not in allowed:
        raise ValueError(
            f"Field '{field_name}' must be one of: {', '.join(allowed)}."
        )
    return normalized


def _parse_restrictions(value: Any) -> list[str]:
    if not isinstance(value, list):
        raise ValueError(
            "Field 'dietary_restrictions' must be a list of restriction codes."
        )

    normalized_restrictions: list[str] = []
    for raw in value:
        restriction = _parse_enum(raw, DIETARY_RESTRICTIONS, "dietary_restrictions")
        if restriction not in normalized_restrictions:
            normalized_restrictions.append(restriction)

    if not normalized_restrictions:
        return ["none"]
    if "none" in normalized_restrictions and len(normalized_restrictions) > 1:
        normalized_restrictions = [
            restriction for restriction in normalized_restrictions if restriction != "none"
        ]
    return normalized_restrictions or ["none"]


def _parse_optional_text(value: Any, field_name: str) -> str:
    if value is None:
        return ""
    if not isinstance(value, str):
        raise ValueError(f"Field '{field_name}' must be a string when provided.")
    trimmed = value.strip()
    if len(trimmed) > 300:
        raise ValueError(f"Field '{field_name}' must be 300 characters or fewer.")
    return trimmed


def _encode_enum(value: str, mapping: Mapping[str, int], field_name: str) -> int:
    if value not in mapping:
        raise ValueError(
            f"Value '{value}' is unsupported for '{field_name}'. Retrain encoders."
        )
    return mapping[value]


def _restriction_flags(restrictions: list[str]) -> list[int]:
    active = {item for item in restrictions if item != "none"}
    return [1 if feature in active else 0 for feature in RESTRICTION_FEATURES]
