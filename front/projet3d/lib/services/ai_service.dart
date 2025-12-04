import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  final String baseUrl;
  
  AIService({this.baseUrl = 'http://localhost:8000'});

  /// Vérifie si le diagnostic proposé par l'étudiant est correct
  Future<CheckAnswerResponse> checkAnswer({
    required List<int> symptoms,
    required String studentAnswer,
    String? expectedDisease,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check_answer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'symptoms': symptoms,
          'student_answer': studentAnswer,
          'expected_disease': expectedDisease,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CheckAnswerResponse.fromJson(data);
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la vérification: $e');
    }
  }

  /// Prédit une maladie basée sur les symptômes
  Future<DiagnosticResponse> predictDisease({
    required List<int> symptoms,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'symptoms': symptoms,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DiagnosticResponse.fromJson(data);
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la prédiction: $e');
    }
  }

  /// Recommande les prochains cas cliniques
  Future<RecommendationResponse> recommendCases({
    required String currentCase,
    List<String>? completedCases,
    int nRecommendations = 3,
    String? difficulty,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'current_case': currentCase,
          'completed_cases': completedCases ?? [],
          'n_recommendations': nRecommendations,
          'difficulty': difficulty,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RecommendationResponse.fromJson(data);
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la recommandation: $e');
    }
  }

  /// Vérifie la santé de l'API
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

class CheckAnswerResponse {
  final bool isCorrect;
  final String predictedDisease;
  final double confidence;
  final String feedback;

  CheckAnswerResponse({
    required this.isCorrect,
    required this.predictedDisease,
    required this.confidence,
    required this.feedback,
  });

  factory CheckAnswerResponse.fromJson(Map<String, dynamic> json) {
    return CheckAnswerResponse(
      isCorrect: json['is_correct'] ?? false,
      predictedDisease: json['predicted_disease'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      feedback: json['feedback'] ?? '',
    );
  }
}

class DiagnosticResponse {
  final String predictedDisease;
  final double confidence;
  final Map<String, double>? allProbabilities;

  DiagnosticResponse({
    required this.predictedDisease,
    required this.confidence,
    this.allProbabilities,
  });

  factory DiagnosticResponse.fromJson(Map<String, dynamic> json) {
    return DiagnosticResponse(
      predictedDisease: json['predicted_disease'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      allProbabilities: json['all_probabilities'] != null
          ? Map<String, double>.from(
              (json['all_probabilities'] as Map).map(
                (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
              ),
            )
          : null,
    );
  }
}

class RecommendationResponse {
  final List<String> recommendations;
  final int? currentCluster;

  RecommendationResponse({
    required this.recommendations,
    this.currentCluster,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      recommendations: List<String>.from(json['recommendations'] ?? []),
      currentCluster: json['current_cluster'],
    );
  }
}

