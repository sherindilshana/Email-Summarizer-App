import 'package:email_summarizer_app/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart'; // 1. Import Device Preview


// --- App Entry Point ---
void main() {
  // 2. Wrap the app with DevicePreview
  runApp(
    DevicePreview(
      // Only enable the device preview when not in production (best practice for performance)
      enabled: !const bool.fromEnvironment('dart.vm.product'),
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 3. Configure MaterialApp with DevicePreview settings
      locale: DevicePreview.locale(context), // Set app locale based on DevicePreview
      builder: DevicePreview.appBuilder, // Set the app builder for the preview functionality

      title: 'AI Email Summarizer',
      theme: ThemeData(
        // Set the primary theme colors for a pure white/black look
        primaryColor: const Color(0xFF204ECF), // Used for accent colors (buttons/highlights)
        scaffoldBackgroundColor: Colors.white, // Pure white background
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, // Black text on AppBar
          elevation: 1, // Subtle shadow for AppBar
        ),
        textTheme: const TextTheme(
          // Ensure all default text is black
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          titleLarge: TextStyle(color: Colors.black),
        ),
        // Use a dark color for elevated buttons for high contrast
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900], // Deep blue for the button box
            foregroundColor: Colors.white,
          ),
        ),
        useMaterial3: true,
      ),
      // Set the home screen to your input widget
      home: const SplashScreen(),
    );
  }
}