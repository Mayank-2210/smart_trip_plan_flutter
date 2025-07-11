import 'package:flutter/material.dart';
import 'package:smart_trip_plan/presentation/home/generating_screen.dart';

class RefinePromptScreen extends StatefulWidget {
  final String previousPrompt;
  final String username;

  const RefinePromptScreen({
    super.key,
    required this.previousPrompt,
    required this.username,
  });

  @override
  State<RefinePromptScreen> createState() => _RefinePromptScreenState();
}

class _RefinePromptScreenState extends State<RefinePromptScreen> {
  late TextEditingController _refineController;

  @override
  void initState() {
    super.initState();
    _refineController = TextEditingController(text: widget.previousPrompt);
  }

  @override
  void dispose() {
    _refineController.dispose();
    super.dispose();
  }

  void _submitRefinedPrompt() {
    final refinedPrompt = _refineController.text.trim();
    if (refinedPrompt.isEmpty) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GeneratingScreen(
          prompt: refinedPrompt,
          username: widget.username,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF065F46),
        title: const Text("Refine Itinerary Prompt"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Edit your prompt to refine the itinerary:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _refineController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Refine your travel preferences...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitRefinedPrompt,
                icon: const Icon(Icons.refresh),
                label: const Text("Generate Refined Itinerary"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF065F46),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
