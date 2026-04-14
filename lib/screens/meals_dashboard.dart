import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

class MealsDashboard extends StatefulWidget {
  const MealsDashboard({super.key});

  @override
  State<MealsDashboard> createState() => _MealsDashboardState();
}

class _MealsDashboardState extends State<MealsDashboard> {
  static const Color backgroundDark = Color(0xFF0E141B);
  static const Color cardDark = Color(0xFF1B2430);
  static const Color accentGreen = Color(0xFF6BFF95);
  static const Color accentCyan = Color(0xFF4DD6FF);
  static const Color softText = Color(0xFFB6C2CF);

  Map<String, dynamic>? nutritionData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNutritionData();
  }

  Future<void> _loadNutritionData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final nutritionSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('nutrition')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      setState(() {
        nutritionData = nutritionSnapshot.docs.isNotEmpty
            ? nutritionSnapshot.docs.first.data()
            : null;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading nutrition data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Nutrition Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Calories
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Calories",
                    style: TextStyle(
                      color: accentCyan,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "1,847",
                              style: TextStyle(
                                color: accentGreen,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "of 2,200 kcal",
                              style: TextStyle(color: softText, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: 1847 / 2200,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(accentGreen),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [accentGreen, accentCyan],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.local_fire_department, color: Colors.black, size: 24),
                            SizedBox(height: 4),
                            Text(
                              "353",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "left",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Macros
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Macronutrients",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildMacroCard("Protein", 142, 165, "g", accentGreen),
                      const SizedBox(width: 12),
                      _buildMacroCard("Carbs", 198, 275, "g", accentCyan),
                      const SizedBox(width: 12),
                      _buildMacroCard("Fat", 67, 73, "g", Colors.orange),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Water Intake
            _buildGlassCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Water Intake",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              "6",
                              style: TextStyle(
                                color: accentCyan,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              " / 8 glasses",
                              style: TextStyle(color: softText, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: 6 / 8,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(accentCyan),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accentCyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accentCyan.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: accentCyan,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Today's Meals
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Meals",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMealItem("🍳", "Breakfast", "Oatmeal with berries", 387, "kcal"),
                  _buildMealItem("🥗", "Lunch", "Grilled chicken salad", 520, "kcal"),
                  _buildMealItem("🍎", "Snack", "Greek yogurt & almonds", 215, "kcal"),
                  _buildMealItem("🍽️", "Dinner", "Salmon with vegetables", 725, "kcal"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Meal Planning
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tomorrow's Plan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [accentGreen, accentCyan],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "2,150 kcal",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPlannedMeal("Breakfast", "Protein smoothie bowl", 420),
                  _buildPlannedMeal("Lunch", "Turkey wrap with avocado", 580),
                  _buildPlannedMeal("Snack", "Mixed nuts & fruit", 180),
                  _buildPlannedMeal("Dinner", "Lean beef stir-fry", 670),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildMacroCard(String name, int current, int target, String unit, Color color) {
    final progress = current / target;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              current.toString(),
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "/ $target$unit",
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(2),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(String emoji, String mealType, String description, int calories, String unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(color: softText, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [accentGreen, accentCyan],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "$calories $unit",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlannedMeal(String mealType, String description, int calories) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(color: softText, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "$calories kcal",
            style: const TextStyle(color: accentCyan, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}