import 'package:flutter/material.dart';

import '../../models/request_models.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/input_field.dart';
import '../../widgets/result_card.dart';

class MealPage extends StatefulWidget {
  const MealPage({super.key});

  static const String routeName = '/ml/meal';

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _proteinController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _allergyNoteController = TextEditingController();

  String _dietType = AppUiConstants.dietTypes.first;
  String _goal = AppUiConstants.goals.first;
  Set<String> _selectedRestrictions = {'none'};
  PredictionResponse? _response;
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _proteinController.dispose();
    _caloriesController.dispose();
    _allergyNoteController.dispose();
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
      final request = MealRequest(
        protein: double.parse(_proteinController.text.trim()),
        calories: double.parse(_caloriesController.text.trim()),
        dietType: _dietType,
        dietaryRestrictions: _selectedRestrictions.toList(),
        allergyNote: _allergyNoteController.text.trim(),
        goal: _goal,
      );
      final response = await _apiService.predictMeal(request);
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

  void _toggleRestriction(String value, bool enabled) {
    setState(() {
      if (value == 'none') {
        _selectedRestrictions = {'none'};
        return;
      }

      _selectedRestrictions.remove('none');
      if (enabled) {
        _selectedRestrictions.add(value);
      } else {
        _selectedRestrictions.remove(value);
      }

      if (_selectedRestrictions.isEmpty) {
        _selectedRestrictions = {'none'};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppUiConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Meal Recommendation'),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputField(
                      label: 'Protein (g)',
                      hint: 'e.g. 30',
                      controller: _proteinController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _numberValidator,
                    ),
                    const SizedBox(height: AppUiConstants.sectionGap),
                    InputField(
                      label: 'Calories (kcal)',
                      hint: 'e.g. 400',
                      controller: _caloriesController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _numberValidator,
                    ),
                    const SizedBox(height: AppUiConstants.sectionGap),
                    _buildDropdown(
                      label: 'Diet Type',
                      value: _dietType,
                      values: AppUiConstants.dietTypes,
                      onChanged: (value) => setState(() => _dietType = value),
                    ),
                    const SizedBox(height: AppUiConstants.sectionGap),
                    _buildDropdown(
                      label: 'Goal',
                      value: _goal,
                      values: AppUiConstants.goals,
                      onChanged: (value) => setState(() => _goal = value),
                    ),
                    const SizedBox(height: AppUiConstants.sectionGap),
                    Text(
                      'Dietary Restrictions',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppUiConstants.dietaryRestrictions
                          .map(
                            (restriction) => FilterChip(
                              label: Text(
                                restriction.replaceAll('_', ' '),
                                style: const TextStyle(color: Colors.white),
                              ),
                              selected: _selectedRestrictions.contains(
                                restriction,
                              ),
                              selectedColor: AppUiConstants.accentCyan
                                  .withValues(alpha: 0.35),
                              checkmarkColor: Colors.white,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.08,
                              ),
                              onSelected: (enabled) =>
                                  _toggleRestriction(restriction, enabled),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: AppUiConstants.sectionGap),
                    InputField(
                      label: 'Allergy Note (optional)',
                      hint: 'e.g. avoid milk and whey',
                      controller: _allergyNoteController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 18),
                    GlassButton(
                      label: 'Predict Meal',
                      icon: Icons.restaurant_menu,
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
}
