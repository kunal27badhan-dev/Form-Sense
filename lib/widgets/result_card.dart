import 'package:flutter/material.dart';

import 'glass_card.dart';

class ResultCard extends StatelessWidget {
  final Object result;
  final String extra;
  final double? confidence;

  const ResultCard({
    super.key,
    required this.result,
    required this.extra,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final confidenceText = confidence == null
        ? null
        : '${(confidence! * 100).toStringAsFixed(1)}%';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prediction Result',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            result.toString(),
            style: const TextStyle(
              color: Colors.tealAccent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            extra,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
          if (confidenceText != null) ...[
            const SizedBox(height: 10),
            Text(
              'Confidence: $confidenceText',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
