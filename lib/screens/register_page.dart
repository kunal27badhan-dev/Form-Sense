import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import '../widgets/auth_background.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String errorMessage = "";
  bool isLoading = false;

  Future<void> _createUserWithMockData(String email, String password, String userId) async {
    try {
      // Create Firebase Auth user
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(userId);

      // Create user profile in Firestore with mock fitness data
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'userId': userId,
        'email': email,
        'displayName': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'fitnessScore': 87,
        'currentStreak': 12,
        'programsCompleted': 3,
        'totalWorkouts': 18,
        'completionRate': 94,
        'profile': {
          'weight': 72.5,
          'bodyFat': 15.8,
          'muscle': 68.2,
          'height': 175,
          'age': 25,
          'gender': 'male',
        },
      });

      // Create mock running data
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).collection('running').add({
        'date': Timestamp.now(),
        'distance': 5.2,
        'duration': 28.75, // 28:45 in minutes
        'pace': 5.53, // 5:32 pace
        'type': 'Morning Run',
        'calories': 420,
      });

      // Create mock meal data
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).collection('nutrition').add({
        'date': Timestamp.now(),
        'totalCalories': 1847,
        'targetCalories': 2200,
        'protein': 142,
        'carbs': 198,
        'fat': 67,
        'water': 6,
        'meals': [
          {'type': 'Breakfast', 'name': 'Oatmeal with berries', 'calories': 387},
          {'type': 'Lunch', 'name': 'Grilled chicken salad', 'calories': 520},
          {'type': 'Snack', 'name': 'Greek yogurt & almonds', 'calories': 215},
          {'type': 'Dinner', 'name': 'Salmon with vegetables', 'calories': 725},
        ],
      });

      // Create mock program data
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).collection('programs').add({
        'name': 'Strength Builder Pro',
        'description': 'Build muscle mass & strength',
        'currentWeek': 3,
        'totalWeeks': 12,
        'isActive': true,
        'startDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 21))),
      });

      // Create weekly goals
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).collection('goals').add({
        'type': 'weekly',
        'goals': {
          'distance': {'current': 18.4, 'target': 25.0, 'unit': 'km'},
          'runs': {'current': 4, 'target': 5, 'unit': 'runs'},
          'calories': {'current': 850, 'target': 1200, 'unit': 'kcal'},
        },
        'weekStart': Timestamp.fromDate(DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1))),
      });

    } catch (e) {
      rethrow;
    }
  }

  bool isUserAlreadyRegistered(String userId) {
    return userId == "kunal_27" || userId == "7827";
  }

  @override
  void dispose() {
    userIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AuthBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Glassmorphism header card
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6BFF95), Color(0xFF4DD6FF)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_add,
                              color: Colors.black,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Create Account",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Join the fitness revolution",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Form container with glassmorphism
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          _glassInput(
                            "User ID / Username / Phone",
                            userIdController,
                            Icons.person_outline,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),
                          _glassInput(
                            "Password",
                            passwordController,
                            Icons.lock_outline,
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                          ),

                          if (errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      errorMessage,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 30),

                          // Register button with gradient
                          _GlassButton(
                            text: isLoading ? "CREATING ACCOUNT..." : "CREATE ACCOUNT",
                            onPressed: isLoading ? () {} : () async {
                              final userId = userIdController.text.trim();
                              final password = passwordController.text.trim();

                              if (userId.isEmpty || password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text("Please fill all fields"),
                                    backgroundColor: Colors.red.withOpacity(0.8),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              if (password.length < 6) {
                                setState(() {
                                  errorMessage = "Password must be at least 6 characters";
                                });
                                return;
                              }

                              setState(() {
                                isLoading = true;
                                errorMessage = "";
                              });

                              try {
                                // Create email from userId for Firebase Auth
                                String email = "$userId@formense.app";
                                
                                await _createUserWithMockData(email, password, userId);

                                // Success feedback
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text("Account created successfully!"),
                                    backgroundColor: const Color(0xFF6BFF95),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                );
                              } catch (e) {
                                setState(() {
                                  errorMessage = "Registration failed: ${e.toString()}";
                                  isLoading = false;
                                });
                              }
                            },
                          ),

                          const SizedBox(height: 16),

                          // Login link
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                children: const [
                                  TextSpan(
                                    text: "Login",
                                    style: TextStyle(
                                      color: Color(0xFF6BFF95),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassInput(
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    TextInputAction? textInputAction,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            textInputAction: textInputAction,
            onChanged: (_) {
              if (errorMessage.isNotEmpty) {
                setState(() => errorMessage = "");
              }
            },
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF6BFF95),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const _GlassButton({
    required this.text,
    required this.onPressed,
  });

  @override
  State<_GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<_GlassButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6BFF95), Color(0xFF4DD6FF)],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6BFF95).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
