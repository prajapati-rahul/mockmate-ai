import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class QuestionScreen extends StatefulWidget {
  final String role;

  const QuestionScreen({
    super.key,
    required this.role,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}


class _QuestionScreenState extends State<QuestionScreen> {
  final FlutterTts tts = FlutterTts();
bool expanded = false;
// ✅ TIMER
  Timer? _timer;
  int timeLeft = 90;

  final AIService ai = AIService();
  final TextEditingController answerController = TextEditingController();

  String question = "";
  String feedback = "";
  bool loading = true;
  bool showNextButton = false;
  int questionCount = 1;

  @override
void initState() {
  super.initState();
  tts.setLanguage("en-US");
  tts.setSpeechRate(0.45);
  loadQuestion();
}


  Future<void> loadQuestion() async {
    setState(() {
      loading = true;
      feedback = "";
      showNextButton = false;
      answerController.clear();
    });

    try {
      question = await ai.generateQuestion(widget.role);
    } catch (e) {
      question = "❌ Failed to load question.\nCheck API or internet.";
    }

    setState(() => loading = false);
startTimer();

  }

  void startTimer() {
  _timer?.cancel();
  timeLeft = 90;

  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (timeLeft == 0) {
      timer.cancel();
      submitAnswer(auto: true);
    } else {
      setState(() {
        timeLeft--;
      });
    }
  });
}

void stopTimer() {
  _timer?.cancel();
}


  Future<void> submitAnswer({bool auto = false}) async {
    stopTimer();

    if (!auto && answerController.text.trim().isEmpty) return;


    setState(() => loading = true);

    final result = await ai.evaluateAnswer(
      question,
      answerController.text,
      widget.role,
    );

    setState(() {
      feedback = result;
      showNextButton = true;
      loading = false;
    });
  }


    String highlightKeywords(String text) {
    final keywords = [
      "flutter",
      "api",
      "state",
      "listview",
      "async",
      "java",
      "oop",
      "database",
      "widget",
      "http",
      "json",
    ];

    String result = text;

    for (final word in keywords) {
      result = result.replaceAllMapped(
        RegExp("\\b$word\\b", caseSensitive: false),
        (m) => "**${m.group(0)}**",
      );
    }

    return result;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.role} Interview"),
        centerTitle: true,
      ),

      // ✅ Prevent keyboard overflow
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: loading
            ? Center(
  child: Lottie.asset(
    'assets/lottie/loading.json',
    width: 150,
  ),
)

            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Question Counter
                    Text(
                      "Question $questionCount",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    /// ⏱️ TIMER ROW  (⬅️ YAHAN ADD KARO)
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      "Time Left: $timeLeft sec",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: timeLeft <= 10 ? Colors.red : Colors.green,
      ),
    ),
    const Icon(Icons.timer, color: Colors.indigo),
  ],
),
const SizedBox(height: 12),

                    /// Question Card
Card(
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  ),
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Top Row (Title + Actions)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Question",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            Row(
              children: [
                /// 🔊 Voice Button
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () {
                    tts.speak(question);
                  },
                ),

                /// ⬇️ Expand / Collapse
                IconButton(
                  icon: Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() => expanded = !expanded);
                  },
                ),
              ],
            ),
          ],
        ),

        const Divider(),

        /// 📜 Markdown Question View
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          constraints: BoxConstraints(
            maxHeight: expanded ? 500 : 220,
          ),
          child: SingleChildScrollView(
            child: MarkdownBody(
              selectable: true,
              data: highlightKeywords(question),
              styleSheet: MarkdownStyleSheet(
  p: TextStyle(
    fontSize: 16,
    height: 1.5,
    color: Theme.of(context).colorScheme.onSurface,
  ),

  code: TextStyle(
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade200,
    color: Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black,
    fontSize: 14,
  ),

  codeblockDecoration: BoxDecoration(
    color: Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors.grey.shade100,
    borderRadius: BorderRadius.circular(8),
  ),
),

            ),
          ),
        ),
      ],
    ),
  ),
),

                    const SizedBox(height: 20),

                    /// Answer Field
                    TextField(
  controller: answerController,
  maxLines: 5,
  decoration: InputDecoration(
    hintText: "Type your answer here...",
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),


                    const SizedBox(height: 20),

                    /// Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitAnswer,
                        child: const Text("Submit Answer"),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Feedback Card
                    if (feedback.isNotEmpty)
                      Card(
  color: Theme.of(context).colorScheme.surface,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Text(
      feedback,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 15,
        height: 1.4,
      ),
    ),
  ),
),


                    const SizedBox(height: 16),

                    /// Next Question Button
                    if (showNextButton)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.navigate_next),
                          label: const Text("Next Question"),
                          onPressed: () {
                            questionCount++;
                            loadQuestion();
                          },
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
  @override
void dispose() {
  _timer?.cancel();
  answerController.dispose();
  super.dispose();
}

}
