import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../widgets/skeleton_overlay_painter.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with TickerProviderStateMixin {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late AnimationController _loadingController;
  late AnimationController _alertController;
  
  bool _showSkeleton = true;
  bool _showConfidence = false;
  bool _isAnalyzing = false;
  
  // Exercise detection state
  String _currentExercise = "Detecting...";
  String _postureAlert = "";
  int _repCount = 0;
  double _formScore = 0.0;
  
  // Fake loading and analysis timers
  bool _modelLoaded = false;

  // Demo skeleton keypoints
  final List<Point> _demoKeypoints = [
    Point(x: 0.5, y: 0.15, confidence: 0.9, label: 'nose'),        // 0
    Point(x: 0.48, y: 0.12, confidence: 0.85, label: 'left_eye'),  // 1
    Point(x: 0.52, y: 0.12, confidence: 0.85, label: 'right_eye'), // 2
    Point(x: 0.46, y: 0.14, confidence: 0.8, label: 'left_ear'),   // 3
    Point(x: 0.54, y: 0.14, confidence: 0.8, label: 'right_ear'),  // 4
    Point(x: 0.42, y: 0.25, confidence: 0.9, label: 'left_shoulder'), // 5
    Point(x: 0.58, y: 0.25, confidence: 0.9, label: 'right_shoulder'), // 6
    Point(x: 0.38, y: 0.4, confidence: 0.85, label: 'left_elbow'),     // 7
    Point(x: 0.62, y: 0.4, confidence: 0.85, label: 'right_elbow'),    // 8
    Point(x: 0.35, y: 0.55, confidence: 0.8, label: 'left_wrist'),     // 9
    Point(x: 0.65, y: 0.55, confidence: 0.8, label: 'right_wrist'),    // 10
    Point(x: 0.45, y: 0.6, confidence: 0.9, label: 'left_hip'),        // 11
    Point(x: 0.55, y: 0.6, confidence: 0.9, label: 'right_hip'),       // 12
    Point(x: 0.44, y: 0.75, confidence: 0.85, label: 'left_knee'),     // 13
    Point(x: 0.56, y: 0.75, confidence: 0.85, label: 'right_knee'),    // 14
    Point(x: 0.43, y: 0.9, confidence: 0.8, label: 'left_ankle'),      // 15
    Point(x: 0.57, y: 0.9, confidence: 0.8, label: 'right_ankle'),     // 16
  ];

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
    
    // Animation controllers
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _alertController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Start fake loading and analysis
    _startFakeAnalysis();
  }

  @override
  void dispose() {
    _controller.dispose();
    _loadingController.dispose();
    _alertController.dispose();
    super.dispose();
  }

  void _startFakeAnalysis() async {
    // Fake loading phase
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _modelLoaded = true;
        _currentExercise = "Push-ups";
        _isAnalyzing = true;
      });
    }

    // Start fake rep counting and form analysis
    _simulateWorkout();
  }

  void _simulateWorkout() async {
    while (mounted && _isAnalyzing) {
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _repCount++;
          _formScore = (80 + (DateTime.now().millisecond % 20)).toDouble();
          
          // Simulate posture alerts
          if (_repCount % 3 == 0) {
            _postureAlert = "Keep back straight!";
            _alertController.forward().then((_) {
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  setState(() => _postureAlert = "");
                  _alertController.reverse();
                }
              });
            });
          } else if (_repCount % 5 == 0) {
            _postureAlert = "Great form! 💪";
            _alertController.forward().then((_) {
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  setState(() => _postureAlert = "");
                  _alertController.reverse();
                }
              });
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Workout Camera"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showSkeleton ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _showSkeleton = !_showSkeleton),
          ),
          IconButton(
            icon: Icon(_showConfidence ? Icons.info : Icons.info_outline),
            onPressed: () => setState(() => _showConfidence = !_showConfidence),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // Camera preview
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.previewSize?.height ?? 1,
                      height: _controller.value.previewSize?.width ?? 1,
                      child: CameraPreview(_controller),
                    ),
                  ),
                ),
                
                // Skeleton overlay
                if (_showSkeleton && _modelLoaded)
                  SkeletonOverlay(
                    keypoints: _demoKeypoints,
                    showConfidence: _showConfidence,
                  ),
                
                // Loading overlay
                if (!_modelLoaded) _buildLoadingOverlay(),
                
                // Exercise detection overlay
                if (_modelLoaded) _buildExerciseDetectionOverlay(),
                
                // Posture alert overlay
                if (_postureAlert.isNotEmpty) _buildPostureAlert(),
                
                // Status overlay
                _buildStatusOverlay(),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }
        },
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _loadingController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _loadingController.value * 2 * 3.14159,
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.green,
                    size: 48,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Running pose detection model...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Initializing AI analysis engine",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseDetectionOverlay() {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fitness_center, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  _currentExercise,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric("Reps", _repCount.toString(), Colors.cyan),
                _buildMetric("Form", "${_formScore.toInt()}%", _getFormColor()),
                _buildMetric("Status", _isAnalyzing ? "ACTIVE" : "PAUSED", Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPostureAlert() {
    return AnimatedBuilder(
      animation: _alertController,
      builder: (context, child) {
        return Positioned(
          top: 200 + (50 * _alertController.value),
          left: 20,
          right: 20,
          child: Opacity(
            opacity: _alertController.value,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _postureAlert.contains("Great") 
                    ? Colors.green.withOpacity(0.9)
                    : Colors.orange.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _postureAlert.contains("Great") 
                        ? Icons.thumb_up 
                        : Icons.warning,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _postureAlert,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusOverlay() {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pose Detection: ${_showSkeleton && _modelLoaded ? "ON" : "OFF"}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  'Confidence: ${_showConfidence ? "VISIBLE" : "HIDDEN"}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            Icon(
              _modelLoaded ? Icons.check_circle : Icons.hourglass_empty,
              color: _modelLoaded ? Colors.green : Colors.orange,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Color _getFormColor() {
    if (_formScore >= 90) return Colors.green;
    if (_formScore >= 75) return Colors.yellow;
    return Colors.orange;
  }
}