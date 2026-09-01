import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AIService {
  AIService();

  // Local backend for development.
  //
  // Flutter Web running on the same PC:
  // localhost works.
  //
  // Android emulator:
  // 10.0.2.2 points to your PC's localhost.
  //
  // Physical phone:
  // Replace this with your PC's local network IP.
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }

    return 'http://localhost:3000';
  }

  Future<String> generateQuestion(String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/generate-question'),
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
        String message = 'Unable to generate interview question.';

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
        throw Exception('AI returned an empty question.');
      }

      return question.toString().trim();
    } catch (e) {
      debugPrint('Generate Question Error: $e');

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
        Uri.parse('$baseUrl/api/evaluate-answer'),
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
        String message = 'Unable to evaluate your answer.';

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
        throw Exception('AI returned empty feedback.');
      }

      return feedback.toString().trim();
    } catch (e) {
      debugPrint('Evaluate Answer Error: $e');

      throw Exception(
        'Unable to evaluate your answer: $e',
      );
    }
  }
}