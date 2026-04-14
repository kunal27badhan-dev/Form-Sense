import 'package:flutter/material.dart';

import '../../models/request_models.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/input_field.dart';
import '../../widgets/result_card.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  static const String routeName = '/ml/workout';

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _sessionMinutesController = TextEditingController(text: '45');

  String _fitnessLevel = AppUiConstants.fitnessLevels.first;
  String _goal = AppUiConstants.goals.first;
  String _activityLevel = AppUiConstants.activityLevels.first;
  PredictionResponse? _response;
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _sessionMinutesController.dispose();
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
      final request = WorkoutRequest(
        fitnessLevel: _fitnessLevel,
        goal: _goal,
        sessionMinutes: int.parse(_sessionMinutesController.text.trim()),
        activityLevel: _activityLevel,
      );
      final response = await _apiService.predictWorkout(request);
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
        title: const Text('Workout Recommendation'),
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
                    _buildDropdown(
                      label: 'Fitness Level',
                      value: _fitnessLevel,
                      values: AppUiConstants.fitnessLevels,
                      onChanged: (value) =>
                          setState(() => _fitnessLevel = value),
                    ),
                    const SizedBox(height: AppUiConstants.sectionGap),
                    _buildDropdown(
                      label: 'Goal',
                      value: _goal,
                      values: AppUiConstants.goals,
                      onChanged: (value) => setState(() => _goal = value),
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
                    InputField(
                      label: 'Session Minutes',
                      hint: 'e.g. 45',
                      controller: _sessionMinutesController,
                      keyboardType: TextInputType.number,
                      validator: _intValidator,
                    ),
                    const SizedBox(height: 18),
                    GlassButton(
                      label: 'Predict Workout',
                      icon: Icons.fitness_center,
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
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
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
