import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../navigation/main_navigation.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),

              Image.asset(
                'assets/images/lost-and-found-app-logo.png',
                height: 120,
              ),

              const SizedBox(height: 20),

              const Text(
                "Welcome to Lost & Found!",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              const Text("Find & Reunite Lost Items Easily"),

              const SizedBox(height: 50),

              CustomTextField(
                hintText: "example@gmail.com",
                controller: emailController,
              ),

              const SizedBox(height: 20),

              CustomTextField(
                hintText: "************",
                obscureText: true,
                controller: passwordController,
              ),

              const SizedBox(height: 30),

              CustomButton(
                text: "SIGN IN",
                onPressed: () async {
                  try {
                    await context.read<AuthProvider>().login(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    );

                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainNavigation(),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Forgot password?",
                  style: TextStyle(color: Colors.red),
                ),
              ),

              const Spacer(),

              const Text("or"),

              const SizedBox(height: 20),

              Container(
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text(
                    "Continue with Google",
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
