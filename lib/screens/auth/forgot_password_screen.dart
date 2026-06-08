import 'package:flutter/material.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 50),

              const Text(
                "Reset your Password",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 50),

              const CustomTextField(hintText: "Email Address"),

              const SizedBox(height: 40),

              CustomButton(text: "Continue", onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
