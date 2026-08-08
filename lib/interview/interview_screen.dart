import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'question_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


class InterviewScreen extends StatelessWidget {
  const InterviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text("Choose Interview Role"),
  actions: [
    IconButton(
      tooltip: "Logout",
      icon: const Icon(Icons.logout),
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      },
    ),
  ],
),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          roleTile(
            context,
            role: "Flutter Developer",
            lottie: "assets/lottie/flutter.json",
          ),
          roleTile(
            context,
            role: "Java Developer",
            lottie: "assets/lottie/java.json",
          ),
          roleTile(
            context,
            role: "AI / ML Engineer",
            lottie: "assets/lottie/ai.json",
          ),
          roleTile(
            context,
            role: "Cloud Engineer",
            lottie: "assets/lottie/cloud.json",
          ),
        ],
      ),
    );
  }

  Widget roleTile(
    BuildContext context, {
    required String role,
    required String lottie,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuestionScreen(role: role),
            ),
          );
        },
        child: Container(
          height: 140, // 🔥 FIXED HEIGHT → NO OVERFLOW
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.indigo.shade400,
                Colors.indigo.shade700,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              /// 🎞️ LOTTIE (LEFT)
              SizedBox(
                width: 130,
                child: Lottie.asset(
                  lottie,
                  fit: BoxFit.contain,
                ),
              ),

              /// 🧠 ROLE TEXT (RIGHT)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Tap to start mock interview",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// ➡️ ARROW
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
