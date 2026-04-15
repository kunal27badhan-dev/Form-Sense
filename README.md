# coolapp

Flutter fitness app with Firebase auth + dashboards, now integrated with a Flask ML backend for:
- Meal Recommendation
- Workout Recommendation
- Weight Prediction
- Fitness Level Classification

## App routes

ML module routes:
- `/ml/meal`
- `/ml/workout`
- `/ml/weight`
- `/ml/fitness`

## Run backend (Windows)

From project root:

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
python training\train_models.py
python app.py
```

Backend default URL: `http://127.0.0.1:5000`  
Android emulator should call: `http://10.0.2.2:5000`

### Backend endpoints
- `GET /health`
- `POST /predict/meal`
- `POST /predict/workout`
- `POST /predict/weight`
- `POST /predict/fitness`

## Dataset-driven training and outputs

Training script: `backend/training/train_models.py`  
Dataset source: `backend/dataset/dataset.csv`

Behavior:
- If dataset exists, training uses it as the source of truth.
- If dataset is missing, fallback synthetic generation is used once.
- Training exports model artifacts and `metadata.pkl`.

Required target columns:
- `meal_recommendation`
- `workout_recommendation`
- `predicted_weight`
- `fitness_level_class`

Optional enrichment columns:
- `workout_exercises` (pipe/comma separated names)
- `meal_highlights`
- `fitness_guidance`

These enrichment columns are converted into runtime metadata so responses include:
- Practical exercise names for Workout AI
- Meal highlight text for Meal AI
- Guidance text for Fitness AI
- Trend explanation for Weight AI

## Flutter notes

- API client layer:
  - `lib/services/endpoints.dart`
  - `lib/services/api_service.dart`
  - `lib/models/request_models.dart`
- Shared ML widgets/constants:
  - `lib/widgets/glass_card.dart`
  - `lib/widgets/glass_button.dart`
  - `lib/widgets/input_field.dart`
  - `lib/widgets/result_card.dart`
  - `lib/utils/constants.dart`
