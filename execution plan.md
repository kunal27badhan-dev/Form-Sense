# Fitness ML App - Execution Plan (Ready for Implementation)

## 1. Objective
Implement four ML-powered modules in the existing Flutter app with a Flask backend:
- Meal Recommendation (KNN)
- Workout Recommendation (Decision Tree)
- Weight Prediction (Linear Regression)
- Fitness Level Classification (Logistic Regression)

## 2. Scope and Boundaries
### In scope
- New Flask backend in `backend/` with 4 prediction endpoints
- Model training/export pipeline for `.pkl` artifacts
- Flutter screens for 4 modules (`lib/screens/ml_modules/`)
- Reusable UI and API layer (`lib/widgets/`, `lib/services/`, `lib/models/`, `lib/utils/`)
- HomePage Quick Actions replacement to open ML screens
- Input validation, loading state, error state, and result rendering
- Meal module preferences: veg/non-veg + allergy/restriction-aware recommendations

### Out of scope (phase 2+)
- YouTube embed, recipe images, shimmer, Firebase prediction history
- Auth/role-based access changes

## 3. Pre-Execution Decisions (must be fixed before coding)
1. **Backend runtime**: Python 3.10+ (recommended 3.11)
2. **Model source**: use existing dataset or provide new cleaned dataset
3. **Label enums** (strict):
   - `diet_type`: `veg`, `non_veg`
   - `dietary_restrictions` (multi-select list): `none`, `lactose_intolerance`, `nut_allergy`, `gluten_intolerance`, `egg_allergy`, `soy_allergy`, `shellfish_allergy`
   - `goal`: `muscle`, `fat_loss`, `maintenance`
   - `fitness_level`: `beginner`, `intermediate`, `advanced`
   - `activity_level`: `low`, `moderate`, `high`
   - `diet_quality`: `poor`, `average`, `good`
4. **API response contract**:
   ```json
   {
     "result": "string|number",
     "extra": "string",
     "confidence": 0.0
   }
   ```
5. **Platform base URL strategy**:
   - Android emulator: `http://10.0.2.2:5000`
   - iOS simulator/Web/Windows: `http://127.0.0.1:5000`

## 3.1 Input Contract (module-level)
### Meal module (updated)
- `protein` (number)
- `calories` (number)
- `diet_type` (`veg` or `non_veg`)
- `dietary_restrictions` (array of restriction codes)
- `allergy_note` (optional string for custom allergy context if not covered by enums)
- `goal` (`muscle`, `fat_loss`, `maintenance`)

### Meal request example
```json
{
  "protein": 30,
  "calories": 400,
  "diet_type": "veg",
  "dietary_restrictions": ["lactose_intolerance"],
  "allergy_note": "avoid milk and whey",
  "goal": "muscle"
}
```

## 4. Dependencies
### Flutter (`pubspec.yaml`)
- Existing: `firebase_core`, `firebase_auth`, `camera`, `video_player`
- Add:
  - `http`
  - `flutter_animate` (optional, if animation complexity increases)

### Python (`backend/requirements.txt`)
- `flask`
- `flask-cors`
- `numpy`
- `pandas`
- `scikit-learn`
- `joblib`
- `python-dotenv`

## 5. Target File Structure
```text
backend/
  app.py
  requirements.txt
  routes/
    meal.py
    workout.py
    weight.py
    fitness.py
  model_artifacts/
    food_model.pkl
    workout_model.pkl
    weight_model.pkl
    fitness_model.pkl
    encoders.pkl
  training/
    train_models.py
  utils/
    preprocess.py
  dataset/
    dataset.csv

lib/
  screens/
    ml_modules/
      meal_page.dart
      workout_page.dart
      weight_page.dart
      fitness_page.dart
  widgets/
    glass_card.dart
    glass_button.dart
    input_field.dart
    result_card.dart
  services/
    api_service.dart
    endpoints.dart
  models/
    request_models.dart
  utils/
    constants.dart
```

## 6. Implementation Sequence (dependency-aware)
### Phase A - Backend foundation
1. Create Flask app factory and register blueprints in `app.py`
2. Add CORS, JSON error handlers, health check (`GET /health`)
3. Add `requirements.txt`

**Exit criteria**: `GET /health` returns `200`.

### Phase B - ML training and artifacts
1. Build `training/train_models.py` to train and export all four models
2. Persist model and encoder artifacts with versioned filenames
3. Add deterministic preprocessing in `utils/preprocess.py` including `diet_type` and `dietary_restrictions` feature handling

**Exit criteria**: all `.pkl` files generated and loadable.

### Phase C - Prediction routes
1. Implement `/predict/meal`, `/predict/workout`, `/predict/weight`, `/predict/fitness`
2. Add strict request validation and typed coercion (meal endpoint must validate `diet_type` and each restriction code)
3. Return consistent response schema and explicit error messages

**Exit criteria**: local API tests pass for valid + invalid payloads.

### Phase D - Flutter service layer
1. Add `http` package and run `flutter pub get`
2. Create `lib/services/endpoints.dart` for environment-safe base URLs
3. Create `lib/services/api_service.dart` for POST + timeout + JSON decode
4. Add request DTOs in `lib/models/request_models.dart`

**Exit criteria**: one manual API call from Flutter returns parsed output.

### Phase E - Reusable UI components
1. Create glassmorphism widgets (`glass_card`, `glass_button`, `input_field`, `result_card`)
2. Centralize constants (radii, blur, spacing, colors) in `lib/utils/constants.dart`

**Exit criteria**: components render consistently in a sandbox screen.

### Phase F - ML module screens
1. Build `meal_page.dart` with input validation + loading + result card, including:
   - diet type selector (`veg` / `non_veg`)
   - dietary restriction multi-select (e.g., lactose intolerance)
   - optional allergy note text field
2. Repeat for workout, weight, fitness modules
3. Keep consistent UX states:
   - Empty state
   - Loading state
   - Success state
   - Error state

**Exit criteria**: all 4 screens submit requests and show results.

### Phase G - Home integration
1. Modify only Quick Actions section in `home_page.dart`
2. Replace cards with: Meal AI, Workout AI, Weight AI, Fitness AI
3. Add route entries in `main.dart`:
   - `/ml/meal`
   - `/ml/workout`
   - `/ml/weight`
   - `/ml/fitness`

**Exit criteria**: taps navigate correctly from Home to each module.

### Phase H - Hardening and quality
1. Run `flutter analyze`
2. Run `flutter test` (noting current default widget test may need update to app reality)
3. Manual responsiveness pass on phone/tablet/web
4. Backend smoke test with boundary values and invalid enums

**Exit criteria**: no analyzer errors; critical user flow is stable.

## 7. Command Checklist
### Backend
```bash
cd backend
python -m venv .venv
# Windows
.venv\Scripts\activate
pip install -r requirements.txt
python training/train_models.py
python app.py
```

### Flutter
```bash
cd ..
flutter pub get
flutter analyze
flutter test
flutter run
```

## 8. Risks and Mitigations
1. **Model/input mismatch** -> freeze enums and preprocessing before UI integration.
2. **Platform networking issues** -> centralize base URL selection in one file.
3. **Unclear confidence semantics** -> include confidence only for classifiers; use null for regressors.
4. **UI inconsistency** -> force all modules through shared widgets and constants.

## 9. Definition of Done
- All 4 ML endpoints run and respond with agreed schema.
- All 4 Flutter module pages are reachable from HomePage and fully functional.
- Input validation and error handling are visible and user-friendly.
- Analyzer passes and core app flow remains stable.
- Plan items completed in phase order with no skipped dependency.
