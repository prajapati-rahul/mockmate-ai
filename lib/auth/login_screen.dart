import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import 'register_screen.dart';
import '../interview/interview_screen.dart';
import 'package:lottie/lottie.dart';
import '../common/welcome_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool loading = false;
  String error = '';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E3C72),
              Color(0xFF2A5298),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [

                /// 🔥 TOP SECTION (Brand + Animation)
                SizedBox(
                  height: size.height * 0.4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lottie/login.json',
                        height: 160,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "MockMate AI",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Practice interviews like real life",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                /// 🧾 LOGIN CARD (CENTER–BOTTOM)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Login",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// Email
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email_outlined),
                              labelText: "Email",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// Password
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
                              labelText: "Password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          if (error.isNotEmpty)
                            Text(
                              error,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),

                          const SizedBox(height: 18),

                          Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: () async {
      if (emailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter email first")),
        );
        return;
      }

      await _authService.resetPassword(emailController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent")),
      );
    },
    child: const Text("Forgot Password?"),
  ),
),


                          /// Login Button
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3C72),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: loading
                                  ? null
                                  : () async {
                                      setState(() {
                                        loading = true;
                                        error = '';
                                      });

                                      try {
                                        final user =
                                            await _authService.login(
                                          emailController.text,
                                          passwordController.text,
                                        );

                                        if (user != null && mounted) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                   WelcomeScreen(),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        setState(() {
                                          error = "Invalid email or password";
                                        });
                                      }

                                      setState(() => loading = false);
                                    },
                              child: loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Login",
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 14),

SizedBox(
  height: 48,
  child: OutlinedButton.icon(
    icon: const Icon(
      Icons.g_mobiledata,
      size: 28,
      color: Colors.red,
    ),
    label: const Text(
      "Continue with Google",
      style: TextStyle(fontSize: 15),
    ),
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      side: const BorderSide(color: Colors.grey),
    ),
    onPressed: () async {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WelcomeScreen(),
          ),
        );
      }
    },
  ),
),



                          const SizedBox(height: 14),

                          /// Register
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Create new account",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
