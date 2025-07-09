// lib/main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(const SmartTripApp());
}

class SmartTripApp extends StatelessWidget {
  const SmartTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Trip Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const Placeholder(), // temporary screen
    );
  }
}
