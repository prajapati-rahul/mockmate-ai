import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class AIService {
  AIService();

  Future<String> generateQuestion(String role) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/generate-question',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'role': role,
        }),
      );

      debugPrint(
        'Generate Question Status: ${response.statusCode}',
      );

      debugPrint(
        'Generate Question Body: ${response.body}',
      );

      if (response.statusCode != 200) {
        String message =
            'Unable to generate interview question.';

        try {
          final data = jsonDecode(response.body);

          if (data['error'] != null) {
            message = data['error'].toString();
          }
        } catch (_) {}

        throw Exception(message);
      }

      final data = jsonDecode(response.body);

      final question = data['question'];

      if (question == null ||
          question.toString().trim().isEmpty) {
        throw Exception(
          'AI returned an empty question.',
        );
      }

      return question.toString().trim();
    } catch (e) {
      debugPrint(
        'Generate Question Error: $e',
      );

      throw Exception(
        'Unable to generate interview question: $e',
      );
    }
  }

  Future<String> evaluateAnswer(
    String question,
    String answer,
    String role,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/evaluate-answer',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'question': question,
          'answer': answer,
          'role': role,
        }),
      );

      debugPrint(
        'Evaluate Answer Status: ${response.statusCode}',
      );

      debugPrint(
        'Evaluate Answer Body: ${response.body}',
      );

      if (response.statusCode != 200) {
        String message =
            'Unable to evaluate your answer.';

        try {
          final data = jsonDecode(response.body);

          if (data['error'] != null) {
            message = data['error'].toString();
          }
        } catch (_) {}

        throw Exception(message);
      }

      final data = jsonDecode(response.body);

      final feedback = data['feedback'];

      if (feedback == null ||
          feedback.toString().trim().isEmpty) {
        throw Exception(
          'AI returned empty feedback.',
        );
      }

      return feedback.toString().trim();
    } catch (e) {
      debugPrint(
        'Evaluate Answer Error: $e',
      );

      throw Exception(
        'Unable to evaluate your answer: $e',
      );
    }
  }
}