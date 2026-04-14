import 'package:flutter/material.dart';

import '../../models/request_models.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/input_field.dart';
import '../../widgets/result_card.dart';

class FitnessPage extends StatefulWidget {
  const FitnessPage({super.key});

  static const String routeName = '/ml/fitness';

  @override
  State<FitnessPage> createState() => _FitnessPageState();
}

class _FitnessPageState extends State<FitnessPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _bmiController = TextEditingController();
  final _restingHeartRateController = TextEditingController();
  final _weeklyWorkoutsController = TextEditingController(text: '3');

  String _activityLevel = AppUiConstants.activityLevels.first;
  String _dietQuality = AppUiConstants.dietQualityLevels[1];
  PredictionResponse? _response;
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _bmiController.dispose();
    _restingHeartRateController.dispose();
    _weeklyWorkoutsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final request = FitnessRequest(
        bmi: double.parse(_bmiController.text.trim()),
        restingHeartRate: double.parse(_restingHeartRateController.text.trim()),
        weeklyWorkouts: int.parse(_weeklyWorkoutsController.text.trim()),
        activityLevel: _activityLevel,
        dietQuality: _dietQuality,
      );
      final response = await _apiService.predictFitness(request);
      if (!mounted) {
        return;
      }
      setState(() => _response = response);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppUiConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Fitness Level Classification'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppUiConstants.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                child: Column(
                  children: [
                    InputField(
                      label: 'BMI',
                      hint: 'e.g. 22.4',
                      controller: _bmiController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _numberValidator,
                    ),
                    const SizedBox(height: AppUiConstants.sectionGap),
                    InputField(
                      label: 'Resting Heart Rate',
                      hint: 'e.g. 62',
                      controller: _restingHeartRateController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _numberValidator,
                    ),
                    const SizedBox(height: AppUiConstants.sectionGap),
                    InputField(
                      label: 'Weekly Workouts',
                      hint: 'e.g. 4',
                      controller: _weeklyWorkoutsController,
                      keyboardType: TextInputType.number,
                      validator: _intValidator,
                    ),
                    const SizedBox(height: AppUiConstants.sectionGap),
                    _buildDropdown(
                      label: 'Activity Level',
                      value: _activityLevel,
                      values: AppUiConstants.activityLevels,
                      onChanged: (value) =>
                          setState(() => _activityLevel = value),
                    ),
                    const SizedBox(height: AppUiConstants.sectionGap),
                    _buildDropdown(
                      label: 'Diet Quality',
                      value: _dietQuality,
                      values: AppUiConstants.dietQualityLevels,
                      onChanged: (value) =>
                          setState(() => _dietQuality = value),
                    ),
                    const SizedBox(height: 18),
                    GlassButton(
                      label: 'Classify Fitness Level',
                      icon: Icons.insights,
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppUiConstants.sectionGap),
                GlassCard(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
              if (_response != null) ...[
                const SizedBox(height: AppUiConstants.sectionGap),
                ResultCard(
                  result: _response!.result,
                  extra: _response!.extra,
                  confidence: _response!.confidence,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          dropdownColor: const Color(0xFF1B2430),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
          style: const TextStyle(color: Colors.white),
          items: values
              .map(
                (entry) => DropdownMenuItem<String>(
                  value: entry,
                  child: Text(entry.replaceAll('_', ' ')),
                ),
              )
              .toList(),
          onChanged: (selected) {
            if (selected != null) {
              onChanged(selected);
            }
          },
        ),
      ],
    );
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required field';
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Enter a valid number';
    }
    return null;
  }

  String? _intValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required field';
    }
    if (int.tryParse(value.trim()) == null) {
      return 'Enter a valid integer';
    }
    return null;
  }
}
