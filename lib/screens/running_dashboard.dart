import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

class RunningDashboard extends StatefulWidget {
  const RunningDashboard({super.key});

  @override
  State<RunningDashboard> createState() => _RunningDashboardState();
}

class _RunningDashboardState extends State<RunningDashboard> {
  static const Color backgroundDark = Color(0xFF0E141B);
  static const Color cardDark = Color(0xFF1B2430);
  static const Color accentGreen = Color(0xFF6BFF95);
  static const Color accentCyan = Color(0xFF4DD6FF);
  static const Color softText = Color(0xFFB6C2CF);

  bool isLoading = true;
  Map<String, dynamic>? runningData;
  Map<String, dynamic>? weeklyGoals;

  @override
  void initState() {
    super.initState();
    _loadRunningData();
  }

  Future<void> _loadRunningData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Load latest running session
      final runningSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('running')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      // Load weekly goals
      final goalsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .where('type', isEqualTo: 'weekly')
          .limit(1)
          .get();

      setState(() {
        runningData = runningSnapshot.docs.isNotEmpty 
            ? runningSnapshot.docs.first.data()
            : null;
        weeklyGoals = goalsSnapshot.docs.isNotEmpty
            ? goalsSnapshot.docs.first.data()
            : null;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading running data: $e');
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
          "Running Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Stats
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Run",
                    style: TextStyle(
                      color: accentCyan,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildMetricCard(
                        runningData?['distance']?.toStringAsFixed(1) ?? "0.0", 
                        "KM", 
                        accentGreen
                      ),
                      const SizedBox(width: 16),
                      _buildMetricCard(
                        _formatDuration(runningData?['duration'] ?? 0), 
                        "MIN", 
                        accentCyan
                      ),
                      const SizedBox(width: 16),
                      _buildMetricCard(
                        _formatPace(runningData?['pace'] ?? 0), 
                        "PACE", 
                        Colors.orange
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Weekly Progress
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "This Week",
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
                        child: Text(
                          "Goal: ${weeklyGoals?['goals']?['distance']?['target']?.toStringAsFixed(0) ?? '25'}km",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildProgressBar(
                    "Distance", 
                    weeklyGoals?['goals']?['distance']?['current']?.toDouble() ?? 18.4, 
                    weeklyGoals?['goals']?['distance']?['target']?.toDouble() ?? 25, 
                    "km"
                  ),
                  const SizedBox(height: 12),
                  _buildProgressBar(
                    "Runs", 
                    weeklyGoals?['goals']?['runs']?['current']?.toDouble() ?? 4, 
                    weeklyGoals?['goals']?['runs']?['target']?.toDouble() ?? 5, 
                    "runs"
                  ),
                  const SizedBox(height: 12),
                  _buildProgressBar(
                    "Calories", 
                    weeklyGoals?['goals']?['calories']?['current']?.toDouble() ?? 850, 
                    weeklyGoals?['goals']?['calories']?['target']?.toDouble() ?? 1200, 
                    "kcal"
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Recent Runs
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recent Runs",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRunItem(
                    runningData?['type'] ?? "Morning Run", 
                    "${runningData?['distance']?.toStringAsFixed(1) ?? '5.2'} km", 
                    _formatDuration(runningData?['duration'] ?? 28.75), 
                    "Today"
                  ),
                  _buildRunItem("Evening Jog", "3.8 km", "22:15", "Yesterday"),
                  _buildRunItem("Park Loop", "7.1 km", "41:30", "2 days ago"),
                  _buildRunItem("Hill Training", "4.5 km", "35:20", "3 days ago"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Achievements
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Achievements",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildAchievementBadge("🏃‍♂️", "5K Master", accentGreen),
                      const SizedBox(width: 12),
                      _buildAchievementBadge("🔥", "7 Day Streak", Colors.orange),
                      const SizedBox(width: 12),
                      _buildAchievementBadge("⚡", "Speed Demon", accentCyan),
                    ],
                  ),
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

  Widget _buildMetricCard(String value, String unit, Color color) {
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double current, double target, String unit) {
    final progress = current / target;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            Text(
              "${current.toStringAsFixed(1)}/${target.toStringAsFixed(0)} $unit",
              style: const TextStyle(color: softText, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 1.0 ? accentGreen : accentCyan,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildRunItem(String name, String distance, String time, String date) {
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
            child: const Icon(Icons.directions_run, color: Colors.black, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  "$distance • $time",
                  style: const TextStyle(color: softText, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: const TextStyle(color: softText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(String emoji, String title, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(double minutes) {
    final totalMinutes = minutes.round();
    final mins = totalMinutes % 60;
    final seconds = ((minutes - totalMinutes) * 60).round();
    return "${mins.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  String _formatPace(double paceMinutes) {
    final mins = paceMinutes.floor();
    final seconds = ((paceMinutes - mins) * 60).round();
    return "$mins:${seconds.toString().padLeft(2, '0')}";
  }
}