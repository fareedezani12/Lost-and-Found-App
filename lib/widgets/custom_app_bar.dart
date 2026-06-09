import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final String? logoPath;
  final bool showBackButton;

  const CustomHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.logoPath,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: const Color(0xff1565C0),
      foregroundColor: Colors.white,
      titleSpacing: 0,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              if (showBackButton)
                const BackButton(color: Colors.white)
              else
                const SizedBox(width: 48),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.all(8),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Image.asset(
                  logoPath ?? "assets/images/lost-and-found-app-logo.png",
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
