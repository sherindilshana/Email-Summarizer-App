import 'package:flutter/material.dart';
import 'package:email_summarizer_app/homeScreen.dart'; 
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Define the primary blue color used for highlighting text/icons
  static const Color primaryBlue = Color(0xFF204ECF); 

  @override
  void initState() {
    super.initState();
    
    // Animation for the pulsing effect on the icon/text
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), 
    );

    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start pulsing animation
    _controller.repeat(reverse: true);

    // Set timer for 3-second navigation
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Pure white background
      body: Center(
        child: FadeTransition(
          opacity: _animation, // Applying the pulse effect
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Placeholder Icon in primary blue color
              Icon(
                Icons.mark_email_read_outlined, 
                size: 70,
                color: primaryBlue,
              ),
              const SizedBox(height: 10),
              // Main title in primary blue color
              const Text(
                'Email Summarizer',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: primaryBlue, 
                ),
              ),
              const SizedBox(height: 5),
              // Subtitle in a slightly lighter blue or grey
              Text(
                'Powered by Gemini',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: primaryBlue.withOpacity(0.7), 
                ),
              ),
              const SizedBox(height: 50),
              // Loading Dots (simplified)
              SizedBox(
                width: 50,
                child: LinearProgressIndicator(
                  backgroundColor: primaryBlue.withOpacity(0.2), // Light blue track
                  valueColor: AlwaysStoppedAnimation<Color>(primaryBlue), // Primary blue indicator
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
