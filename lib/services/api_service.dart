import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/request_models.dart';
import 'endpoints.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const Duration _timeout = Duration(seconds: 15);

  Future<PredictionResponse> predictMeal(MealRequest request) {
    return _post(Endpoints.meal, request.toJson());
  }

  Future<PredictionResponse> predictWorkout(WorkoutRequest request) {
    return _post(Endpoints.workout, request.toJson());
  }

  Future<PredictionResponse> predictWeight(WeightRequest request) {
    return _post(Endpoints.weight, request.toJson());
  }

  Future<PredictionResponse> predictFitness(FitnessRequest request) {
    return _post(Endpoints.fitness, request.toJson());
  }

  Future<PredictionResponse> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http
        .post(
          Endpoints.uri(endpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const ApiException('Invalid response from server.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorMessage = decoded['error']?.toString() ?? 'Request failed.';
      throw ApiException(errorMessage);
    }

    return PredictionResponse.fromJson(decoded);
  }
}
