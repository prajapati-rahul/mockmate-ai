import 'package:flutter/material.dart';
import '../models/interview_result.dart';

class ResultScreen extends StatelessWidget {
  final InterviewResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Interview Result"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🎯 SCORE
            Center(
              child: Column(
                children: [
                  Text(
                    "${result.score}",
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const Text(
                    "Overall Score",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// 💪 Strengths
            const Text(
              "Strengths",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...result.strengths.map(
              (e) => ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(e),
              ),
            ),

            const SizedBox(height: 16),

            /// ⚠️ Improvements
            const Text(
              "Needs Improvement",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...result.improvements.map(
              (e) => ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: Text(e),
              ),
            ),

            const Spacer(),

            /// 🔁 Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Retry"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text("Home"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
