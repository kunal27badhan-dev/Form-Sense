import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ✅ correct imports based on your structure
import '../widgets/auth_background.dart';
import 'register_page.dart';
import 'main_navigator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> _loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill all fields"),
          backgroundColor: Colors.red.withOpacity(0.8),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Convert userId back to email for login
      String loginEmail = email.contains('@') ? email : "$email@formense.app";
      
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: loginEmail,
        password: password,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigator()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found. Please register first.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password. Please try again.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format.';
      } else {
        message = 'Login failed: ${e.message}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.withOpacity(0.8),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.withOpacity(0.8),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 🎨 colors only
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color sageGreen = Color(0xFF9FB5A7);
  static const Color textPrimary = Color(0xFFE6F1EA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const SizedBox(height: 8),
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                  color: Color.fromARGB(255, 254, 254, 254),
                  shadows: [
                    Shadow(
                      color: Color.fromARGB(255, 91, 236, 65),
                      blurRadius: 12,
                    ),
                    Shadow(
                      color: Color.fromARGB(255, 145, 186, 141),
                      blurRadius: 19,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: sageGreen),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: sageGreen),
                ),
              ),
              const SizedBox(height: 24),

  SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 62, 162, 69), // 🌿 dark olive / sage
      foregroundColor: const Color.fromARGB(255, 255, 255, 255), // text color (optional but recommended)
  ),
      onPressed: isLoading ? null : _loginUser,
      child: isLoading
          ? const CircularProgressIndicator(color: neonGreen)
          : const Text(
            'Login',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
    ),
  ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text(
                  "Don't have an account? Register",
                  style: TextStyle(color: textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
