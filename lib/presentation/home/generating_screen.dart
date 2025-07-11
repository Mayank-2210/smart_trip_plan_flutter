import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_trip_plan/presentation/home/itinerary_screen.dart';
import 'package:smart_trip_plan/services/ollama_service.dart';

class GeneratingScreen extends StatefulWidget {
  final String prompt;
  final String username;

  const GeneratingScreen({super.key, required this.prompt, required this.username});

  @override
  State<GeneratingScreen> createState() => _GeneratingScreenState();
}

class _GeneratingScreenState extends State<GeneratingScreen> {
  final ollamaService = OllamaService();

  @override
  void initState() {
    super.initState();
    _generate();
  }

  /// Sending the prompt to Ollama and navigate to ItineraryScreen
  void _generate() async {
    try {
      final result = await ollamaService.generateItinerary(widget.prompt);

      final int promptTokens = (widget.prompt.length / 4).ceil();
      final int responseTokens = (jsonEncode(result).length / 4).ceil();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ItineraryScreen(
              itineraryJson: result,
              prompt: widget.prompt,
              username: widget.username,
              promptTokens: promptTokens,
              responseTokens: responseTokens,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to generate itinerary: $e")),
        );
        Navigator.pop(context); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF065F46),
        title: const Text("Generating..."),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Generating itinerary...",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: widget.prompt),
              readOnly: true,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
