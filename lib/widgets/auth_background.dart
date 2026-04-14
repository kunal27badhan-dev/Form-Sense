import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            'assets/images/bg_image.jpeg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.black);
            },
          ),
        ),

        // 🔹 FIX: lighter overlay so blur can see image
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.45), // was 0.7 ❌
          ),
        ),

        // Page content (blur happens here)
        SafeArea(
          child: child,
        ),
      ],
    );
  }
}
