import 'package:cloud_functions/cloud_functions.dart';

class AIService {
  AIService();

  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  Future<String> generateQuestion(String role) async {
    try {
      final callable = _functions.httpsCallable(
        'mockmateAI',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 60),
        ),
      );

      final response = await callable.call({
        'action': 'generateQuestion',
        'role': role,
      });

      final data = Map<String, dynamic>.from(response.data as Map);

      final result = data['result'];

      if (result == null || result.toString().trim().isEmpty) {
        throw Exception('AI returned an empty question.');
      }

      return result.toString().trim();
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        e.message ?? 'Unable to generate interview question.',
      );
    } catch (e) {
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
      final callable = _functions.httpsCallable(
        'mockmateAI',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 60),
        ),
      );

      final response = await callable.call({
        'action': 'evaluateAnswer',
        'question': question,
        'answer': answer,
        'role': role,
      });

      final data = Map<String, dynamic>.from(response.data as Map);

      final result = data['result'];

      if (result == null || result.toString().trim().isEmpty) {
        throw Exception('AI returned an empty evaluation.');
      }

      return result.toString().trim();
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        e.message ?? 'Unable to evaluate your answer.',
      );
    } catch (e) {
      throw Exception(
        'Unable to evaluate your answer: $e',
      );
    }
  }
}