import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';


class AIService {
  final String apiKey = dotenv.env['HF_API_KEY']!;

  final String baseUrl =
      "https://router.huggingface.co/v1/chat/completions";

  final String model = "meta-llama/Meta-Llama-3-8B-Instruct";

  /// 🔹 Generate Interview Question
  Future<String> generateQuestion(String role) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": model,
        "messages": [
          {
            "role": "system",
            "content":
                "You are a professional technical interviewer. Ask clear interview questions."
          },
          {
            "role": "user",
            "content":
                "Ask ONE interview question for a $role job role."
          }
        ],
        "max_tokens": 120,
        "temperature": 0.7
      }),
    );

    print("HF QUESTION STATUS: ${response.statusCode}");
    print("HF QUESTION BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("HF Question API Error");
    }

    final data = jsonDecode(response.body);
    return data["choices"][0]["message"]["content"]
        .toString()
        .trim();
  }

  /// 🔹 Evaluate Answer
  Future<String> evaluateAnswer(
      String question, String answer, String role) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": model,
        "messages": [
          {
            "role": "system",
            "content":
                "You are an interviewer evaluating a candidate answer."
          },
          {
            "role": "user",
            "content":
                "Evaluate this answer for a $role interview.\n\n"
                "Question: $question\n"
                "Answer: $answer\n\n"
                "Give:\n1. Score out of 10\n2. Strengths\n3. Improvements"
          }
        ],
        "max_tokens": 200,
        "temperature": 0.7
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("HF Evaluation API Error");
    }

    final data = jsonDecode(response.body);
    return data["choices"][0]["message"]["content"]
        .toString()
        .trim();
  }
}
