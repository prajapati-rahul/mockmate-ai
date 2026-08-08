import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

import '../services/ai_service.dart';

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
  final AIService ai = AIService();
  final TextEditingController answerController =
      TextEditingController();

  Timer? _timer;

  bool expanded = false;
  bool loading = true;
  bool showNextButton = false;

  int timeLeft = 90;
  int questionCount = 1;

  String question = "";
  String feedback = "";
  String errorMessage = "";

  @override
  void initState() {
    super.initState();

    tts.setLanguage("en-US");
    tts.setSpeechRate(0.45);

    loadQuestion();
  }

  Future<void> loadQuestion() async {
    _timer?.cancel();

    if (!mounted) return;

    setState(() {
      loading = true;
      feedback = "";
      errorMessage = "";
      showNextButton = false;
      answerController.clear();
      question = "";
    });

    try {
      final generatedQuestion =
          await ai.generateQuestion(widget.role);

      if (!mounted) return;

      setState(() {
        question = generatedQuestion;
        loading = false;
      });

      startTimer();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
        question =
            "Unable to generate an interview question.";
      });
    }
  }

  void startTimer() {
    _timer?.cancel();

    setState(() {
      timeLeft = 90;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (timeLeft <= 1) {
          timer.cancel();
          setState(() {
            timeLeft = 0;
          });
          submitAnswer(auto: true);
        } else {
          setState(() {
            timeLeft--;
          });
        }
      },
    );
  }

  void stopTimer() {
    _timer?.cancel();
  }

  Future<void> submitAnswer({bool auto = false}) async {
    stopTimer();

    final answer = answerController.text.trim();

    if (!auto && answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your answer first."),
        ),
      );
      return;
    }

    if (question.isEmpty ||
        question.startsWith("Unable to generate")) {
      return;
    }

    if (!mounted) return;

    setState(() {
      loading = true;
      errorMessage = "";
      feedback = "";
      showNextButton = false;
    });

    try {
      final result = await ai.evaluateAnswer(
        question,
        answer,
        widget.role,
      );

      if (!mounted) return;

      setState(() {
        feedback = result;
        loading = false;
        showNextButton = true;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
      });
    }
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
        RegExp(
          "\\b$word\\b",
          caseSensitive: false,
        ),
        (match) => "**${match.group(0)}**",
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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: loading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'assets/lottie/loading.json',
                      width: 150,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      feedback.isEmpty
                          ? "Preparing your AI interview..."
                          : "Evaluating your answer...",
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Question $questionCount",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Time Left: $timeLeft sec",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: timeLeft <= 10
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        const Icon(
                          Icons.timer,
                          color: Colors.indigo,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (errorMessage.isNotEmpty)
                      Card(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  errorMessage,
                                  style: const TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (errorMessage.isNotEmpty)
                      const SizedBox(height: 12),

                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                const Text(
                                  "Question",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.volume_up,
                                      ),
                                      onPressed:
                                          question.isEmpty
                                              ? null
                                              : () {
                                                  tts.speak(
                                                    question,
                                                  );
                                                },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        expanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          expanded =
                                              !expanded;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const Divider(),

                            AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 250,
                              ),
                              constraints:
                                  BoxConstraints(
                                maxHeight:
                                    expanded ? 500 : 220,
                              ),
                              child:
                                  SingleChildScrollView(
                                child: MarkdownBody(
                                  selectable: true,
                                  data:
                                      highlightKeywords(
                                    question,
                                  ),
                                  styleSheet:
                                      MarkdownStyleSheet(
                                    p: TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      color: Theme.of(
                                        context,
                                      )
                                          .colorScheme
                                          .onSurface,
                                    ),
                                    code: TextStyle(
                                      backgroundColor:
                                          Theme.of(
                                        context,
                                      ).brightness ==
                                              Brightness.dark
                                          ? Colors
                                              .grey.shade800
                                          : Colors
                                              .grey.shade200,
                                      color: Theme.of(
                                        context,
                                      ).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 14,
                                    ),
                                    codeblockDecoration:
                                        BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).brightness ==
                                              Brightness.dark
                                          ? Colors
                                              .grey.shade900
                                          : Colors
                                              .grey.shade100,
                                      borderRadius:
                                          BorderRadius
                                              .circular(8),
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

                    TextField(
                      controller: answerController,
                      maxLines: 5,
                      enabled: !showNextButton,
                      decoration: InputDecoration(
                        hintText:
                            "Type your answer here...",
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: showNextButton
                            ? null
                            : submitAnswer,
                        child: const Text(
                          "Submit Answer",
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (feedback.isNotEmpty)
                      Card(
                        color: Theme.of(context)
                            .colorScheme
                            .surface,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(12),
                          child: Text(
                            feedback,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    if (showNextButton)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.navigate_next,
                          ),
                          label: const Text(
                            "Next Question",
                          ),
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
    tts.stop();
    super.dispose();
  }
}