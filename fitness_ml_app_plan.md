# 🚀 Fitness ML App – Implementation Plan (Flutter + Flask + ML Models)

## 📌 1. Goal
Build ML-powered modules inside the existing Flutter app:

- Meal Recommendation (KNN)
- Workout Recommendation (Decision Tree)
- Weight Prediction (Linear Regression)
- Fitness Level Classification (Logistic Regression)

Each module:
- Accessible via HomePage buttons
- Opens a modern glassmorphism page
- Takes user input
- Sends request to Flask backend
- Displays prediction results

---

## 🏗️ 2. High-Level Architecture
Flutter UI (coolapp)  
↓ HTTP (REST API)  
Flask Backend (Python)  
↓  
ML Models (.pkl files)

---

## 📂 3. Folder Structure (Flutter – coolapp/lib)
```
lib/
│
├── screens/
│   ├── home_page.dart  (MODIFY)
│   │
│   ├── ml_modules/
│   │   ├── meal_page.dart
│   │   ├── workout_page.dart
│   │   ├── weight_page.dart
│   │   └── fitness_page.dart
│
├── widgets/
│   ├── glass_card.dart
│   ├── glass_button.dart
│   ├── input_field.dart
│   └── result_card.dart
│
├── services/
│   ├── api_service.dart
│   └── endpoints.dart
│
├── models/
│   └── request_models.dart
│
└── utils/
    ├── constants.dart
    └── theme_extensions.dart
```

---

## 🧠 4. Backend Folder Structure (Flask)
```
backend/
│
├── app.py
├── routes/
│   ├── meal.py
│   ├── workout.py
│   ├── weight.py
│   └── fitness.py
│
├── models/
│   ├── food_model.pkl
│   ├── workout_model.pkl
│   ├── weight_model.pkl
│   └── fitness_model.pkl
│
├── utils/
│   ├── preprocess.py
│   └── encoders.pkl
│
└── dataset/
    └── dataset.csv
```

---

## 🎨 5. HomePage Modifications (IMPORTANT)
Modify ONLY Quick Actions section

### Replace/Add ML Buttons:
- Meal AI → /ml/meal
- Workout AI → /ml/workout
- Weight AI → /ml/weight
- Fitness AI → /ml/fitness

### UI Behavior:
- Use existing glass cards style
- Add ML icon overlays
- Add "AI" badge on cards
- Tap → navigate to module screen

---

## 🧊 6. Glassmorphism Design System
- Frosted glass cards (Backdrop blur sigmaX: 20)
- Gradient background animation
- Soft glow borders
- Rounded corners (20–30 radius)
- Floating input sections

---

## 📱 7. ML Module Screen Layout
AppBar (Glass style)  
↓  
Animated Gradient Background  
↓  
Glass Container (Main Card)  
    ↓  
    Title  
    ↓  
    Input Fields  
    ↓  
    Submit Button  
    ↓  
    Result Card  

---

## ✏️ 8. Inputs per Module

### 🍽️ Meal Page
- Protein
- Calories
- Allergy
- Goal

### 🏋️ Workout Page
- Calories target
- Body part
- Fitness level

### ⚖️ Weight Page
- Calories intake
- Protein intake
- Exercise minutes

### 💪 Fitness Page
- BMI
- Activity level
- Diet quality

---

## 🔌 9. API Design (Flask)

Base URL:
http://10.0.2.2:5000/

### Endpoints:
- /predict/meal
- /predict/workout
- /predict/weight
- /predict/fitness

### Request Format:
```json
{
  "protein": 30,
  "calories": 400,
  "allergy": "none",
  "goal": "muscle"
}
```

### Response Format:
```json
{
  "result": "Grilled Chicken Salad",
  "extra": "High protein meal recommendation"
}
```

---

## 🔄 10. API Flow
User Input → Validate → API Call → Loading → Response → UI Update

---

## ⚙️ 11. Service Layer
- POST requests
- JSON handling
- Error handling
- Timeout handling

---

## 🧩 12. Navigation Setup
- /ml/meal
- /ml/workout
- /ml/weight
- /ml/fitness

---

## 🎯 13. UI Components
- glass_card.dart
- input_field.dart
- glass_button.dart
- result_card.dart

---

## 🎥 14. Animations
- Pulse animation
- Slide animation
- Fade-in result card
- Button ripple effect

---

## 🧪 15. Testing Plan
- Test APIs via Postman
- Test Flutter connection
- Validate inputs
- Check responsiveness

---

## 🚀 16. Final Flow
Home → ML Page → Input → API → Result

---

## 🔥 17. Optional Enhancements
- YouTube embed
- Recipe image
- Loading shimmer
- Firebase history

---

## ✅ 18. Execution Strategy
1. Create folder structure  
2. Build backend  
3. Train models  
4. Create APIs  
5. Build UI  
6. Modify HomePage  
7. Connect API  
8. Add animations  
9. Final testing  
