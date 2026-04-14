from __future__ import annotations

import sys
from pathlib import Path
from typing import Any

import joblib
import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression, LogisticRegression
from sklearn.neighbors import KNeighborsClassifier
from sklearn.tree import DecisionTreeClassifier

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from utils.preprocess import (  # noqa: E402
    ACTIVITY_LEVELS,
    DIET_QUALITY_LEVELS,
    DIET_TYPES,
    DIETARY_RESTRICTIONS,
    FITNESS_LEVELS,
    GOALS,
    RESTRICTION_FEATURES,
)
from utils.recommendation_catalog import (  # noqa: E402
    infer_fitness_guidance,
    infer_meal_highlight,
    infer_workout_exercises,
    parse_exercise_string,
    serialize_exercise_list,
)

DATASET_PATH = ROOT / "dataset" / "dataset.csv"
ARTIFACTS_PATH = ROOT / "model_artifacts"

SEED = 27
ROW_COUNT = 1200

REQUIRED_COLUMNS = {
    "protein",
    "calories",
    "diet_type",
    "dietary_restrictions",
    "goal",
    "session_minutes",
    "fitness_level",
    "activity_level",
    "current_weight",
    "target_calories",
    "weeks",
    "avg_daily_steps",
    "bmi",
    "resting_heart_rate",
    "weekly_workouts",
    "diet_quality",
    "meal_recommendation",
    "workout_recommendation",
    "fitness_level_class",
    "predicted_weight",
}

NUMERIC_COLUMNS = (
    "protein",
    "calories",
    "session_minutes",
    "current_weight",
    "target_calories",
    "weeks",
    "avg_daily_steps",
    "bmi",
    "resting_heart_rate",
    "weekly_workouts",
    "predicted_weight",
)

INT_COLUMNS = ("session_minutes", "weeks", "weekly_workouts")


def _enum_map(values: tuple[str, ...]) -> dict[str, int]:
    return {value: index for index, value in enumerate(values)}


def _sample_restrictions(rng: np.random.Generator) -> list[str]:
    roll = float(rng.random())
    if roll < 0.58:
        return ["none"]
    if roll < 0.86:
        return [str(rng.choice(RESTRICTION_FEATURES))]

    selected = rng.choice(RESTRICTION_FEATURES, size=2, replace=False)
    return sorted(str(item) for item in selected)


def _choose_meal(
    protein: float,
    calories: float,
    diet_type: str,
    goal: str,
    restrictions: list[str],
) -> str:
    base_meals = {
        ("muscle", "veg"): "Tofu Power Bowl",
        ("muscle", "non_veg"): "Chicken Quinoa Plate",
        ("fat_loss", "veg"): "Lentil Greens Salad",
        ("fat_loss", "non_veg"): "Grilled Fish Salad",
        ("maintenance", "veg"): "Veggie Brown Rice Plate",
        ("maintenance", "non_veg"): "Turkey Rice Bowl",
    }
    meal = base_meals[(goal, diet_type)]

    if "lactose_intolerance" in restrictions and goal == "muscle":
        meal = "Dairy-Free Protein Bowl"
    elif "gluten_intolerance" in restrictions:
        meal = "Quinoa Vegetable Plate" if diet_type == "veg" else "Chicken Quinoa Plate"
    elif "egg_allergy" in restrictions and diet_type == "veg":
        meal = "Chickpea Spinach Stir Fry"
    elif "nut_allergy" in restrictions and meal == "Lentil Greens Salad":
        meal = "Moong Sprout Salad"
    elif "shellfish_allergy" in restrictions and diet_type == "non_veg":
        meal = "Lean Chicken Veg Plate"

    if calories < 350 and goal == "fat_loss":
        meal = "Low-Cal Veg Soup" if diet_type == "veg" else "Turkey Lettuce Wrap"
    if protein > 42 and goal == "muscle":
        meal = (
            "High-Protein Chickpea Stir Fry"
            if diet_type == "veg"
            else "High-Protein Grilled Chicken"
        )
    return meal


def _choose_workout(
    fitness_level: str,
    goal: str,
    session_minutes: int,
    activity_level: str,
) -> str:
    table = {
        ("beginner", "muscle"): "Full Body Strength Basics",
        ("intermediate", "muscle"): "Upper Lower Strength Split",
        ("advanced", "muscle"): "Push Pull Legs Intense",
        ("beginner", "fat_loss"): "HIIT Starter Circuit",
        ("intermediate", "fat_loss"): "Metabolic Conditioning",
        ("advanced", "fat_loss"): "Athlete HIIT Blast",
        ("beginner", "maintenance"): "Mobility and Core Flow",
        ("intermediate", "maintenance"): "Strength and Cardio Mix",
        ("advanced", "maintenance"): "Hybrid Endurance Strength",
    }
    workout = table[(fitness_level, goal)]

    if session_minutes <= 25:
        workout = "Express Bodyweight Burner"
    elif activity_level == "high" and goal == "fat_loss":
        workout = "Sprint Interval Circuit"
    elif session_minutes >= 75 and goal == "muscle":
        workout = "Volume Hypertrophy Session"
    return workout


def _fitness_class(
    bmi: float,
    resting_heart_rate: float,
    weekly_workouts: int,
    activity_level: str,
    diet_quality: str,
) -> str:
    activity_score = {"low": 0.0, "moderate": 1.0, "high": 2.0}[activity_level]
    diet_score = {"poor": 0.0, "average": 1.0, "good": 2.0}[diet_quality]

    score = (
        weekly_workouts * 0.24
        + activity_score * 1.2
        + diet_score * 0.85
        - abs(bmi - 22) * 0.14
        - max(0, resting_heart_rate - 62) * 0.045
    )
    if score >= 4.1:
        return "advanced"
    if score >= 2.0:
        return "intermediate"
    return "beginner"


def _weight_target(
    current_weight: float,
    target_calories: float,
    activity_level: str,
    weeks: int,
    avg_daily_steps: float,
    rng: np.random.Generator,
) -> float:
    activity_delta = {"low": 0.06, "moderate": -0.01, "high": -0.08}[activity_level]
    calorie_delta = (target_calories - 2200) / 7700
    step_delta = (8000 - avg_daily_steps) / 120000
    weekly_change = calorie_delta + activity_delta + step_delta
    prediction = current_weight + (weeks * weekly_change) + rng.normal(0, 0.45)
    return float(np.clip(prediction, 35, 220))


def build_dataset() -> pd.DataFrame:
    rng = np.random.default_rng(SEED)
    rows: list[dict[str, object]] = []

    for _ in range(ROW_COUNT):
        diet_type = str(rng.choice(DIET_TYPES))
        goal = str(rng.choice(GOALS))
        fitness_level = str(rng.choice(FITNESS_LEVELS, p=[0.4, 0.4, 0.2]))
        activity_level = str(rng.choice(ACTIVITY_LEVELS, p=[0.35, 0.45, 0.2]))
        diet_quality = str(rng.choice(DIET_QUALITY_LEVELS, p=[0.25, 0.5, 0.25]))

        protein = float(rng.uniform(12, 55))
        calories = float(rng.uniform(250, 900))
        restrictions = _sample_restrictions(rng)

        session_minutes = int(rng.integers(20, 91))

        current_weight = float(rng.uniform(48, 118))
        target_calories = float(rng.uniform(1300, 3200))
        weeks = int(rng.integers(2, 25))
        avg_daily_steps = float(rng.uniform(2500, 17000))

        bmi = float(rng.uniform(17, 36))
        resting_heart_rate = float(rng.uniform(48, 94))
        weekly_workouts = int(rng.integers(0, 13))

        meal_recommendation = _choose_meal(
            protein=protein,
            calories=calories,
            diet_type=diet_type,
            goal=goal,
            restrictions=restrictions,
        )
        workout_recommendation = _choose_workout(
            fitness_level=fitness_level,
            goal=goal,
            session_minutes=session_minutes,
            activity_level=activity_level,
        )
        fitness_level_class = _fitness_class(
            bmi=bmi,
            resting_heart_rate=resting_heart_rate,
            weekly_workouts=weekly_workouts,
            activity_level=activity_level,
            diet_quality=diet_quality,
        )
        predicted_weight = _weight_target(
            current_weight=current_weight,
            target_calories=target_calories,
            activity_level=activity_level,
            weeks=weeks,
            avg_daily_steps=avg_daily_steps,
            rng=rng,
        )

        rows.append(
            {
                "protein": round(protein, 2),
                "calories": round(calories, 2),
                "diet_type": diet_type,
                "dietary_restrictions": "|".join(restrictions),
                "allergy_note": "",
                "goal": goal,
                "session_minutes": session_minutes,
                "fitness_level": fitness_level,
                "activity_level": activity_level,
                "current_weight": round(current_weight, 2),
                "target_calories": round(target_calories, 2),
                "weeks": weeks,
                "avg_daily_steps": round(avg_daily_steps, 2),
                "bmi": round(bmi, 2),
                "resting_heart_rate": round(resting_heart_rate, 2),
                "weekly_workouts": weekly_workouts,
                "diet_quality": diet_quality,
                "meal_recommendation": meal_recommendation,
                "workout_recommendation": workout_recommendation,
                "fitness_level_class": fitness_level_class,
                "predicted_weight": round(predicted_weight, 2),
            }
        )

    return pd.DataFrame(rows)


def load_or_create_dataset() -> pd.DataFrame:
    DATASET_PATH.parent.mkdir(parents=True, exist_ok=True)

    if DATASET_PATH.exists():
        df = pd.read_csv(DATASET_PATH)
        if df.empty:
            raise ValueError(f"{DATASET_PATH} exists but has no rows.")
        return df

    df = build_dataset()
    df.to_csv(DATASET_PATH, index=False)
    return df


def _normalize_enum(value: Any, allowed: tuple[str, ...], field_name: str) -> str:
    normalized = str(value).strip().lower().replace("-", "_").replace(" ", "_")
    if normalized not in allowed:
        allowed_text = ", ".join(allowed)
        raise ValueError(
            f"Invalid value '{value}' in column '{field_name}'. Expected one of: {allowed_text}"
        )
    return normalized


def _normalize_restrictions(value: Any) -> str:
    text = str(value).strip()
    if not text or text.lower() in {"nan", "none"}:
        return "none"

    normalized = text.replace(",", "|").replace(";", "|")
    parts = [
        item.strip().lower().replace("-", "_").replace(" ", "_")
        for item in normalized.split("|")
        if item.strip()
    ]
    if not parts:
        return "none"

    invalid = [item for item in parts if item not in DIETARY_RESTRICTIONS]
    if invalid:
        raise ValueError(
            "Invalid dietary_restrictions values found: "
            + ", ".join(sorted(set(invalid)))
        )

    deduped: list[str] = []
    for item in parts:
        if item not in deduped:
            deduped.append(item)

    if "none" in deduped and len(deduped) > 1:
        deduped = [item for item in deduped if item != "none"]
    return "|".join(deduped or ["none"])


def normalize_dataset(df: pd.DataFrame) -> pd.DataFrame:
    missing = sorted(REQUIRED_COLUMNS - set(df.columns))
    if missing:
        raise ValueError(
            "Dataset is missing required columns: " + ", ".join(missing)
        )

    normalized = df.copy()
    if "allergy_note" not in normalized.columns:
        normalized["allergy_note"] = ""
    normalized["allergy_note"] = normalized["allergy_note"].fillna("").astype(str)

    normalized["diet_type"] = normalized["diet_type"].apply(
        lambda value: _normalize_enum(value, DIET_TYPES, "diet_type")
    )
    normalized["goal"] = normalized["goal"].apply(
        lambda value: _normalize_enum(value, GOALS, "goal")
    )
    normalized["fitness_level"] = normalized["fitness_level"].apply(
        lambda value: _normalize_enum(value, FITNESS_LEVELS, "fitness_level")
    )
    normalized["activity_level"] = normalized["activity_level"].apply(
        lambda value: _normalize_enum(value, ACTIVITY_LEVELS, "activity_level")
    )
    normalized["diet_quality"] = normalized["diet_quality"].apply(
        lambda value: _normalize_enum(value, DIET_QUALITY_LEVELS, "diet_quality")
    )
    normalized["fitness_level_class"] = normalized["fitness_level_class"].apply(
        lambda value: _normalize_enum(value, FITNESS_LEVELS, "fitness_level_class")
    )
    normalized["dietary_restrictions"] = normalized["dietary_restrictions"].apply(
        _normalize_restrictions
    )

    for column in NUMERIC_COLUMNS:
        normalized[column] = pd.to_numeric(normalized[column], errors="raise")

    for column in INT_COLUMNS:
        normalized[column] = normalized[column].round().astype(int)

    normalized["meal_recommendation"] = (
        normalized["meal_recommendation"].astype(str).str.strip()
    )
    normalized["workout_recommendation"] = (
        normalized["workout_recommendation"].astype(str).str.strip()
    )
    normalized = normalized[normalized["meal_recommendation"] != ""]
    normalized = normalized[normalized["workout_recommendation"] != ""]

    if normalized.empty:
        raise ValueError("Dataset has no valid rows after normalization.")

    return normalized


def enrich_dataset(df: pd.DataFrame) -> pd.DataFrame:
    enriched = df.copy()

    def workout_exercises_for(row: pd.Series) -> str:
        existing = parse_exercise_string(row.get("workout_exercises"))
        if existing:
            return serialize_exercise_list(existing)
        return serialize_exercise_list(
            infer_workout_exercises(str(row["workout_recommendation"]))
        )

    def meal_highlight_for(row: pd.Series) -> str:
        existing = str(row.get("meal_highlights", "")).strip()
        if existing:
            return existing
        return infer_meal_highlight(str(row["meal_recommendation"]))

    def fitness_guidance_for(row: pd.Series) -> str:
        existing = str(row.get("fitness_guidance", "")).strip()
        if existing:
            return existing
        return infer_fitness_guidance(str(row["fitness_level_class"]))

    enriched["workout_exercises"] = enriched.apply(workout_exercises_for, axis=1)
    enriched["meal_highlights"] = enriched.apply(meal_highlight_for, axis=1)
    enriched["fitness_guidance"] = enriched.apply(fitness_guidance_for, axis=1)
    return enriched


def _most_common_value(series: pd.Series) -> str:
    modes = series.mode()
    if modes.empty:
        return str(series.iloc[0])
    return str(modes.iloc[0])


def build_metadata(df: pd.DataFrame) -> dict[str, Any]:
    workout_map: dict[str, list[str]] = {}
    meal_map: dict[str, str] = {}
    fitness_map: dict[str, str] = {}

    workout_group = df.groupby("workout_recommendation")["workout_exercises"].apply(
        _most_common_value
    )
    for plan, serialized in workout_group.items():
        exercises = parse_exercise_string(serialized)
        workout_map[str(plan)] = exercises or infer_workout_exercises(str(plan))

    meal_group = df.groupby("meal_recommendation")["meal_highlights"].apply(
        _most_common_value
    )
    for meal, highlight in meal_group.items():
        meal_map[str(meal)] = str(highlight).strip() or infer_meal_highlight(str(meal))

    fitness_group = df.groupby("fitness_level_class")["fitness_guidance"].apply(
        _most_common_value
    )
    for level, guidance in fitness_group.items():
        fitness_map[str(level)] = str(guidance).strip() or infer_fitness_guidance(
            str(level)
        )

    return {
        "workout_plan_exercises": workout_map,
        "meal_highlights": meal_map,
        "fitness_guidance": fitness_map,
    }


def train_models(df: pd.DataFrame) -> None:
    ARTIFACTS_PATH.mkdir(parents=True, exist_ok=True)

    encoders = {
        "diet_type": _enum_map(DIET_TYPES),
        "goal": _enum_map(GOALS),
        "fitness_level": _enum_map(FITNESS_LEVELS),
        "activity_level": _enum_map(ACTIVITY_LEVELS),
        "diet_quality": _enum_map(DIET_QUALITY_LEVELS),
    }

    meal_df = df.copy()
    meal_df["diet_type_code"] = meal_df["diet_type"].map(encoders["diet_type"])
    meal_df["goal_code"] = meal_df["goal"].map(encoders["goal"])
    for restriction in RESTRICTION_FEATURES:
        meal_df[f"restriction_{restriction}"] = meal_df["dietary_restrictions"].apply(
            lambda value, current=restriction: 1
            if current in str(value).split("|")
            else 0
        )

    meal_features = [
        "protein",
        "calories",
        "diet_type_code",
        "goal_code",
        *[f"restriction_{item}" for item in RESTRICTION_FEATURES],
    ]
    meal_model = KNeighborsClassifier(n_neighbors=9, weights="distance")
    meal_model.fit(
        meal_df[meal_features].to_numpy(),
        meal_df["meal_recommendation"].to_numpy(),
    )

    workout_df = df.copy()
    workout_df["fitness_level_code"] = workout_df["fitness_level"].map(
        encoders["fitness_level"]
    )
    workout_df["goal_code"] = workout_df["goal"].map(encoders["goal"])
    workout_df["activity_level_code"] = workout_df["activity_level"].map(
        encoders["activity_level"]
    )
    workout_features = [
        "fitness_level_code",
        "goal_code",
        "session_minutes",
        "activity_level_code",
    ]
    workout_model = DecisionTreeClassifier(
        random_state=SEED, max_depth=8, min_samples_leaf=10
    )
    workout_model.fit(
        workout_df[workout_features].to_numpy(),
        workout_df["workout_recommendation"].to_numpy(),
    )

    weight_df = df.copy()
    weight_df["activity_level_code"] = weight_df["activity_level"].map(
        encoders["activity_level"]
    )
    weight_features = [
        "current_weight",
        "target_calories",
        "activity_level_code",
        "weeks",
        "avg_daily_steps",
    ]
    weight_model = LinearRegression()
    weight_model.fit(
        weight_df[weight_features].to_numpy(),
        weight_df["predicted_weight"].to_numpy(),
    )

    fitness_df = df.copy()
    fitness_df["activity_level_code"] = fitness_df["activity_level"].map(
        encoders["activity_level"]
    )
    fitness_df["diet_quality_code"] = fitness_df["diet_quality"].map(
        encoders["diet_quality"]
    )
    fitness_features = [
        "bmi",
        "resting_heart_rate",
        "weekly_workouts",
        "activity_level_code",
        "diet_quality_code",
    ]
    fitness_model = LogisticRegression(max_iter=2000, random_state=SEED)
    fitness_model.fit(
        fitness_df[fitness_features].to_numpy(),
        fitness_df["fitness_level_class"].to_numpy(),
    )

    metadata = build_metadata(df)

    joblib.dump(meal_model, ARTIFACTS_PATH / "food_model.pkl")
    joblib.dump(workout_model, ARTIFACTS_PATH / "workout_model.pkl")
    joblib.dump(weight_model, ARTIFACTS_PATH / "weight_model.pkl")
    joblib.dump(fitness_model, ARTIFACTS_PATH / "fitness_model.pkl")
    joblib.dump(encoders, ARTIFACTS_PATH / "encoders.pkl")
    joblib.dump(metadata, ARTIFACTS_PATH / "metadata.pkl")


def main() -> None:
    raw_df = load_or_create_dataset()
    normalized_df = normalize_dataset(raw_df)
    enriched_df = enrich_dataset(normalized_df)

    enriched_df.to_csv(DATASET_PATH, index=False)
    train_models(enriched_df)

    print(f"Dataset prepared: {DATASET_PATH}")
    print(f"Artifacts written: {ARTIFACTS_PATH}")


if __name__ == "__main__":
    main()
