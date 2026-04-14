import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

class ProgressDashboard extends StatefulWidget {
  const ProgressDashboard({super.key});

  @override
  State<ProgressDashboard> createState() => _ProgressDashboardState();
}

class _ProgressDashboardState extends State<ProgressDashboard> {
  static const Color backgroundDark = Color(0xFF0E141B);
  static const Color cardDark = Color(0xFF1B2430);
  static const Color accentGreen = Color(0xFF6BFF95);
  static const Color accentCyan = Color(0xFF4DD6FF);
  static const Color softText = Color(0xFFB6C2CF);

  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        userProfile = userDoc.exists ? userDoc.data() : null;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading progress data: $e');
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
          "Progress Tracking",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fitness Score
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Overall Fitness Score",
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProfile?['fitnessScore']?.toString() ?? '87',
                              style: TextStyle(
                                color: accentGreen,
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Excellent Form",
                              style: TextStyle(color: softText, fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: 87 / 100,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(accentGreen),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [accentGreen, accentCyan],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.trending_up, color: Colors.black, size: 32),
                            SizedBox(height: 8),
                            Text(
                              "+12",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "vs last week",
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

            // Body Metrics
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Body Measurements",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildMetricCard(
                        userProfile?['profile']?['weight']?.toString() ?? "72.5", 
                        "kg", 
                        "Weight", 
                        accentCyan, 
                        "-1.2 kg"
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        userProfile?['profile']?['bodyFat']?.toString() ?? "15.8", 
                        "%", 
                        "Body Fat", 
                        Colors.orange, 
                        "-0.8%"
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        userProfile?['profile']?['muscle']?.toString() ?? "68.2", 
                        "kg", 
                        "Muscle", 
                        accentGreen, 
                        "+0.4 kg"
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Workout Streaks
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Workout Consistency",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStreakCard(
                        "🔥", 
                        "Current Streak", 
                        userProfile?['currentStreak']?.toString() ?? "12", 
                        "days"
                      ),
                      const SizedBox(width: 12),
                      _buildStreakCard(
                        "💪", 
                        "This Month", 
                        userProfile?['totalWorkouts']?.toString() ?? "18", 
                        "workouts"
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStreakCard("📈", "Weekly Goal", "5/6", "achieved"),
                      const SizedBox(width: 12),
                      _buildStreakCard("🎯", "Best Streak", "28", "days"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Performance Goals
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Monthly Goals",
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
                          "On Track",
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
                  _buildGoalProgress("Run 100km", 78.5, 100, "km"),
                  const SizedBox(height: 12),
                  _buildGoalProgress("20 Workouts", 18, 20, "sessions"),
                  const SizedBox(height: 12),
                  _buildGoalProgress("5000 Calories Burned", 4240, 5000, "kcal"),
                  const SizedBox(height: 12),
                  _buildGoalProgress("Perfect Form Rate", 85, 90, "%"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Recent Achievements
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recent Achievements",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAchievementItem("🏆", "Form Master", "95% accuracy on push-ups", "2 hours ago"),
                  _buildAchievementItem("⚡", "Speed Demon", "Personal best 5K time", "1 day ago"),
                  _buildAchievementItem("💪", "Strength Gain", "10kg increase in deadlift", "3 days ago"),
                  _buildAchievementItem("🎯", "Consistency King", "14 day workout streak", "5 days ago"),
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

  Widget _buildMetricCard(String value, String unit, String label, Color color, String change) {
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
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              change,
              style: TextStyle(
                color: change.startsWith('-') || change.startsWith('+') 
                    ? (change.startsWith('-') ? Colors.red : accentGreen)
                    : softText,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(String emoji, String title, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: accentGreen,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(
                color: softText,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgress(String title, double current, double target, String unit) {
    final progress = current / target;
    final isCompleted = progress >= 1.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text(
                  "${current.toStringAsFixed(unit == "%" ? 0 : 1)} / ${target.toStringAsFixed(0)} $unit",
                  style: TextStyle(
                    color: isCompleted ? accentGreen : softText,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isCompleted) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.check_circle, color: accentGreen, size: 16),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress > 1.0 ? 1.0 : progress,
          backgroundColor: Colors.white.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(
            isCompleted ? accentGreen : accentCyan,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildAchievementItem(String emoji, String title, String description, String time) {
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [accentGreen, accentCyan],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(color: softText, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(color: softText, fontSize: 10),
          ),
        ],
      ),
    );
  }
}