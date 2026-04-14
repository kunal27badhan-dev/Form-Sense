import 'package:flutter/material.dart';

import '../../models/request_models.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/input_field.dart';
import '../../widgets/result_card.dart';

class WeightPage extends StatefulWidget {
  const WeightPage({super.key});

  static const String routeName = '/ml/weight';

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _currentWeightController = TextEditingController();
  final _targetCaloriesController = TextEditingController();
  final _weeksController = TextEditingController(text: '8');
  final _stepsController = TextEditingController(text: '8000');

  String _activityLevel = AppUiConstants.activityLevels.first;
  PredictionResponse? _response;
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentWeightController.dispose();
    _targetCaloriesController.dispose();
    _weeksController.dispose();
    _stepsController.dispose();
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
      final request = WeightRequest(
        currentWeight: double.parse(_currentWeightController.text.trim()),
        targetCalories: double.parse(_targetCaloriesController.text.trim()),
        weeks: int.parse(_weeksController.text.trim()),
        activityLevel: _activityLevel,
        avgDailySteps: double.parse(_stepsController.text.trim()),
      );
      final response = await _apiService.predictWeight(request);
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
        title: const Text('Weight Prediction'),
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
                      label: 'Current Weight (kg)',
                      hint: 'e.g. 72.5',
                      controller: _currentWeightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _numberValidator,
                    ),
                    const SizedBox(height: AppUiConstants.sectionGap),
                    InputField(
                      label: 'Target Calories / Day',
                      hint: 'e.g. 2200',
                      controller: _targetCaloriesController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _numberValidator,
                    ),
                    const SizedBox(height: AppUiConstants.sectionGap),
                    InputField(
                      label: 'Duration (weeks)',
                      hint: 'e.g. 8',
                      controller: _weeksController,
                      keyboardType: TextInputType.number,
                      validator: _intValidator,
                    ),
                    const SizedBox(height: AppUiConstants.sectionGap),
                    InputField(
                      label: 'Average Daily Steps',
                      hint: 'e.g. 8000',
                      controller: _stepsController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _numberValidator,
                    ),
                    const SizedBox(height: AppUiConstants.sectionGap),
                    _buildDropdown(
                      label: 'Activity Level',
                      value: _activityLevel,
                      values: AppUiConstants.activityLevels,
                      onChanged: (value) =>
                          setState(() => _activityLevel = value),
                    ),
                    const SizedBox(height: 18),
                    GlassButton(
                      label: 'Predict Weight',
                      icon: Icons.monitor_weight,
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
                  result: '${_response!.result} kg',
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
