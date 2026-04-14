# coolapp

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## ML backend and module routes

This app now includes a Flask backend under `backend/` and four Flutter ML screens:
- Meal AI: `/ml/meal`
- Workout AI: `/ml/workout`
- Weight AI: `/ml/weight`
- Fitness AI: `/ml/fitness`

### Backend setup (Windows)
```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python training\train_models.py
python app.py
```

### Backend endpoints
- `GET /health`
- `POST /predict/meal`
- `POST /predict/workout`
- `POST /predict/weight`
- `POST /predict/fitness`

### Dataset-driven realistic outputs
`backend/training/train_models.py` now uses `backend/dataset/dataset.csv` as the primary source of truth (it does not overwrite with synthetic rows when the file already exists).  
To control practical outputs, keep these columns populated in the dataset:
- `meal_recommendation`
- `workout_recommendation`
- `predicted_weight`
- `fitness_level_class`

Optional enrichment columns supported by training/runtime:
- `workout_exercises` (pipe/comma separated exercise names)
- `meal_highlights`
- `fitness_guidance`

Training builds `metadata.pkl` from these columns so runtime responses include real exercise names and actionable guidance.
