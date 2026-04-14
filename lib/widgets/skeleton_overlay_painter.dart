import 'package:flutter/material.dart';

/// Custom painter for skeleton overlay on camera feed
class SkeletonOverlayPainter extends CustomPainter {
  final List<Point> keypoints;
  final bool showConfidence;
  
  SkeletonOverlayPainter({
    required this.keypoints,
    this.showConfidence = false,
  });

  // Skeleton connections (human pose joints)
  static const List<List<int>> connections = [
    [0, 1], [1, 2], [2, 3], [3, 7],  // head to shoulder
    [0, 4], [4, 5], [5, 6], [6, 8],  // head to other shoulder
    [7, 9], [8, 10],                  // shoulders to hips
    [9, 11], [11, 13], [13, 15],      // left hip to ankle
    [10, 12], [12, 14], [14, 16],     // right hip to ankle
    [7, 8], [9, 10],                  // shoulder and hip connections
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (keypoints.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final jointPaint = Paint()
      ..strokeWidth = 8.0
      ..style = PaintingStyle.fill;

    // Draw skeleton connections
    for (final connection in connections) {
      final startIdx = connection[0];
      final endIdx = connection[1];
      
      if (startIdx < keypoints.length && endIdx < keypoints.length) {
        final start = keypoints[startIdx];
        final end = keypoints[endIdx];
        
        // Only draw if both points have sufficient confidence
        if (start.confidence > 0.3 && end.confidence > 0.3) {
          paint.color = _getConnectionColor(start.confidence, end.confidence);
          
          canvas.drawLine(
            Offset(start.x * size.width, start.y * size.height),
            Offset(end.x * size.width, end.y * size.height),
            paint,
          );
        }
      }
    }

    // Draw keypoint joints
    for (int i = 0; i < keypoints.length; i++) {
      final point = keypoints[i];
      if (point.confidence > 0.3) {
        jointPaint.color = _getJointColor(point.confidence);
        
        canvas.drawCircle(
          Offset(point.x * size.width, point.y * size.height),
          _getJointRadius(point.confidence),
          jointPaint,
        );

        // Draw confidence text if enabled
        if (showConfidence) {
          _drawConfidenceText(
            canvas, 
            point, 
            size, 
            point.confidence.toStringAsFixed(2)
          );
        }
      }
    }
  }

  Color _getConnectionColor(double conf1, double conf2) {
    final avgConf = (conf1 + conf2) / 2;
    if (avgConf > 0.8) return Colors.green;
    if (avgConf > 0.6) return Colors.yellow;
    return Colors.orange;
  }

  Color _getJointColor(double confidence) {
    if (confidence > 0.8) return Colors.green.shade600;
    if (confidence > 0.6) return Colors.yellow.shade600;
    return Colors.orange.shade600;
  }

  double _getJointRadius(double confidence) {
    return 4.0 + (confidence * 3.0);
  }

  void _drawConfidenceText(Canvas canvas, Point point, Size size, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        point.x * size.width + 8,
        point.y * size.height - 8,
      ),
    );
  }

  @override
  bool shouldRepaint(SkeletonOverlayPainter oldDelegate) {
    return keypoints != oldDelegate.keypoints || 
           showConfidence != oldDelegate.showConfidence;
  }
}

/// Represents a keypoint in the skeleton
class Point {
  final double x;
  final double y;
  final double confidence;
  final String label;

  const Point({
    required this.x,
    required this.y,
    required this.confidence,
    this.label = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          confidence == other.confidence &&
          label == other.label;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ confidence.hashCode ^ label.hashCode;
}

/// Widget that displays skeleton overlay
class SkeletonOverlay extends StatelessWidget {
  final List<Point> keypoints;
  final bool showConfidence;
  final Widget? child;

  const SkeletonOverlay({
    super.key,
    required this.keypoints,
    this.showConfidence = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ?child,
        CustomPaint(
          painter: SkeletonOverlayPainter(
            keypoints: keypoints,
            showConfidence: showConfidence,
          ),
          child: Container(),
        ),
      ],
    );
  }
}