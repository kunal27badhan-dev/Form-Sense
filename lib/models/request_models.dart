class MealRequest {
  final double protein;
  final double calories;
  final String dietType;
  final List<String> dietaryRestrictions;
  final String allergyNote;
  final String goal;

  const MealRequest({
    required this.protein,
    required this.calories,
    required this.dietType,
    required this.dietaryRestrictions,
    required this.allergyNote,
    required this.goal,
  });

  Map<String, dynamic> toJson() => {
    'protein': protein,
    'calories': calories,
    'diet_type': dietType,
    'dietary_restrictions': dietaryRestrictions,
    'allergy_note': allergyNote,
    'goal': goal,
  };
}

class WorkoutRequest {
  final String fitnessLevel;
  final String goal;
  final int sessionMinutes;
  final String activityLevel;

  const WorkoutRequest({
    required this.fitnessLevel,
    required this.goal,
    required this.sessionMinutes,
    required this.activityLevel,
  });

  Map<String, dynamic> toJson() => {
    'fitness_level': fitnessLevel,
    'goal': goal,
    'session_minutes': sessionMinutes,
    'activity_level': activityLevel,
  };
}

class WeightRequest {
  final double currentWeight;
  final double targetCalories;
  final int weeks;
  final String activityLevel;
  final double avgDailySteps;

  const WeightRequest({
    required this.currentWeight,
    required this.targetCalories,
    required this.weeks,
    required this.activityLevel,
    required this.avgDailySteps,
  });

  Map<String, dynamic> toJson() => {
    'current_weight': currentWeight,
    'target_calories': targetCalories,
    'weeks': weeks,
    'activity_level': activityLevel,
    'avg_daily_steps': avgDailySteps,
  };
}

class FitnessRequest {
  final double bmi;
  final double restingHeartRate;
  final int weeklyWorkouts;
  final String activityLevel;
  final String dietQuality;

  const FitnessRequest({
    required this.bmi,
    required this.restingHeartRate,
    required this.weeklyWorkouts,
    required this.activityLevel,
    required this.dietQuality,
  });

  Map<String, dynamic> toJson() => {
    'bmi': bmi,
    'resting_heart_rate': restingHeartRate,
    'weekly_workouts': weeklyWorkouts,
    'activity_level': activityLevel,
    'diet_quality': dietQuality,
  };
}

class PredictionResponse {
  final Object result;
  final String extra;
  final double? confidence;

  const PredictionResponse({
    required this.result,
    required this.extra,
    required this.confidence,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    final rawConfidence = json['confidence'];
    return PredictionResponse(
      result: json['result'] ?? '',
      extra: (json['extra'] ?? '').toString(),
      confidence: rawConfidence is num ? rawConfidence.toDouble() : null,
    );
  }
}
