import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import '../../providers/auth_provider.dart';

import '../navigation/main_navigation.dart';
import '../admin/admin_dashboard_screen.dart';

import 'signup_screen.dart';

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

  bool isLoading = false;
  bool obscurePassword = true;

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
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),

              const SizedBox(height: 20),

              CustomTextField(
                hintText: "Password",
                controller: passwordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 30),

              CustomButton(
                text: "SIGN IN",
                onPressed: () async {
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();

                  // Empty validation
                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter your email."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter your password."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Email format validation
                  final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

                  if (!emailRegex.hasMatch(email)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a valid email address."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  setState(() {
                    isLoading = true;
                  });

                  try {
                    await context.read<AuthProvider>().login(
                      email: email,
                      password: password,
                    );

                    final user = FirebaseAuth.instance.currentUser;

                    setState(() {
                      isLoading = false;
                    });

                    if (user != null) {
                      final doc = await FirebaseFirestore.instance
                          .collection("users")
                          .doc(user.uid)
                          .get();

                      final data = doc.data();

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Login successful!"),
                          backgroundColor: Colors.green,
                        ),
                      );

                      if (data?["role"] == "admin") {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminDashboardScreen(),
                          ),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainNavigation(),
                          ),
                        );
                      }
                    }
                  } on FirebaseAuthException catch (e) {
                    String message;

                    switch (e.code) {
                      case "user-not-found":
                        message = "No account found with this email.";
                        break;

                      case "wrong-password":
                        message = "Incorrect password.";
                        break;

                      case "invalid-email":
                        message = "Please enter a valid email address.";
                        break;

                      case "invalid-credential":
                        message = "Incorrect email or password.";
                        break;

                      case "user-disabled":
                        message = "This account has been disabled.";
                        break;

                      case "too-many-requests":
                        message =
                            "Too many login attempts. Please try again later.";
                        break;

                      default:
                        message = "Login failed. Please try again.";
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } catch (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Something went wrong. Please try again.",
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 15),

              const Spacer(),

              const Text("or"),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  icon: Image.asset(
                    "assets/images/google_logo.jpg",
                    height: 22,
                  ),
                  label: const Text(
                    "Continue with Google",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      final credential = await context
                          .read<AuthProvider>()
                          .signInWithGoogle();

                      if (credential == null) return;

                      final user = credential.user;

                      if (user != null) {
                        final doc = await FirebaseFirestore.instance
                            .collection("users")
                            .doc(user.uid)
                            .get();

                        final data = doc.data();

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Google Sign-In Successful!"),
                            backgroundColor: Colors.green,
                          ),
                        );

                        if (data?["role"] == "admin") {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminDashboardScreen(),
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainNavigation(),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Google Sign-In failed.\n$e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
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
