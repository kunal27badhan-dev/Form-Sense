from __future__ import annotations

from typing import Iterable

DEFAULT_WORKOUT_PLAN_EXERCISES: dict[str, list[str]] = {
    "Express Bodyweight Burner": [
        "Jumping Jacks",
        "Push-Ups",
        "Air Squats",
        "Mountain Climbers",
        "Plank Hold",
    ],
    "Full Body Strength Basics": [
        "Goblet Squat",
        "Incline Push-Up",
        "Dumbbell Row",
        "Hip Bridge",
        "Dead Bug",
    ],
    "Upper Lower Strength Split": [
        "Barbell Bench Press",
        "Romanian Deadlift",
        "Lat Pulldown",
        "Walking Lunges",
        "Dumbbell Shoulder Press",
    ],
    "Push Pull Legs Intense": [
        "Barbell Back Squat",
        "Bench Press",
        "Bent-Over Row",
        "Overhead Press",
        "Conventional Deadlift",
    ],
    "HIIT Starter Circuit": [
        "High Knees",
        "Bodyweight Squats",
        "Burpees",
        "Plank Shoulder Taps",
        "Alternating Reverse Lunges",
    ],
    "Metabolic Conditioning": [
        "Kettlebell Swings",
        "Thrusters",
        "Rowing Intervals",
        "Box Step-Ups",
        "Battle Ropes",
    ],
    "Athlete HIIT Blast": [
        "Sprint Intervals",
        "Box Jumps",
        "Burpee Broad Jumps",
        "Medicine Ball Slams",
        "Skater Hops",
    ],
    "Sprint Interval Circuit": [
        "Treadmill Sprint",
        "Walking Recovery",
        "Jump Squats",
        "Push-Up to T Rotation",
        "Plank Knee Drive",
    ],
    "Mobility and Core Flow": [
        "Cat-Cow Stretch",
        "World's Greatest Stretch",
        "Side Plank",
        "Bird Dog",
        "Glute Bridge March",
    ],
    "Strength and Cardio Mix": [
        "Dumbbell Squat to Press",
        "Assault Bike",
        "Seated Cable Row",
        "Step-Ups",
        "Russian Twists",
    ],
    "Hybrid Endurance Strength": [
        "Front Squat",
        "Pull-Ups",
        "Farmer Carry",
        "Stationary Bike Intervals",
        "Hanging Knee Raises",
    ],
    "Volume Hypertrophy Session": [
        "Leg Press",
        "Incline Dumbbell Press",
        "Chest-Supported Row",
        "Seated Leg Curl",
        "Cable Lateral Raise",
    ],
}

DEFAULT_MEAL_HIGHLIGHTS: dict[str, str] = {
    "Tofu Power Bowl": "Balanced tofu bowl with quinoa, greens, and seeds.",
    "Chicken Quinoa Plate": "Lean chicken with quinoa and mixed vegetables.",
    "Lentil Greens Salad": "High-fiber lentils with leafy greens and lemon dressing.",
    "Grilled Fish Salad": "Omega-rich fish with fresh vegetables and olive oil.",
    "Veggie Brown Rice Plate": "Brown rice with mixed vegetables and legumes.",
    "Turkey Rice Bowl": "Lean turkey with rice and roasted vegetables.",
    "Dairy-Free Protein Bowl": "Lactose-safe protein meal without milk products.",
    "Quinoa Vegetable Plate": "Gluten-aware quinoa plate with seasonal vegetables.",
    "Chickpea Spinach Stir Fry": "Plant-protein chickpeas with sauteed spinach.",
    "Moong Sprout Salad": "Nut-free sprouts salad with herbs and lime.",
    "Lean Chicken Veg Plate": "Shellfish-free lean chicken and vegetable plate.",
    "Low-Cal Veg Soup": "Low-calorie vegetable soup for fat-loss support.",
    "Turkey Lettuce Wrap": "Low-calorie turkey wraps with crunchy lettuce.",
    "High-Protein Chickpea Stir Fry": "High-protein chickpea meal for muscle gain.",
    "High-Protein Grilled Chicken": "High-protein grilled chicken with vegetables.",
}

DEFAULT_FITNESS_GUIDANCE: dict[str, str] = {
    "beginner": "Focus on form, 3 sessions/week, and progressive consistency.",
    "intermediate": "Use progressive overload and mix strength with conditioning.",
    "advanced": "Periodize training, recover well, and target performance blocks.",
}


def parse_exercise_string(value: object) -> list[str]:
    if value is None:
        return []

    if isinstance(value, list):
        return [str(item).strip() for item in value if str(item).strip()]

    text = str(value).strip()
    if not text:
        return []

    normalized = text.replace(",", "|").replace(";", "|")
    return [item.strip() for item in normalized.split("|") if item.strip()]


def serialize_exercise_list(exercises: Iterable[str]) -> str:
    cleaned = [str(item).strip() for item in exercises if str(item).strip()]
    return "|".join(cleaned)


def infer_workout_exercises(plan_name: str) -> list[str]:
    if plan_name in DEFAULT_WORKOUT_PLAN_EXERCISES:
        return DEFAULT_WORKOUT_PLAN_EXERCISES[plan_name]

    lowered = plan_name.lower()
    if "hiit" in lowered or "sprint" in lowered:
        return [
            "Jump Rope",
            "Burpees",
            "High Knees",
            "Mountain Climbers",
            "Plank Hold",
        ]
    if "strength" in lowered or "hypertrophy" in lowered:
        return [
            "Squat",
            "Bench Press",
            "Row",
            "Romanian Deadlift",
            "Overhead Press",
        ]
    if "mobility" in lowered or "core" in lowered:
        return [
            "Cat-Cow Stretch",
            "Hip Flexor Stretch",
            "Side Plank",
            "Bird Dog",
            "Dead Bug",
        ]

    return [
        "Bodyweight Squat",
        "Push-Up",
        "Reverse Lunge",
        "Plank",
        "Glute Bridge",
    ]


def infer_meal_highlight(meal_name: str) -> str:
    return DEFAULT_MEAL_HIGHLIGHTS.get(
        meal_name,
        f"{meal_name}: balanced meal suggestion aligned to your goal and preferences.",
    )


def infer_fitness_guidance(level: str) -> str:
    return DEFAULT_FITNESS_GUIDANCE.get(
        level.lower(),
        "Follow progressive training with balanced nutrition and recovery.",
    )
