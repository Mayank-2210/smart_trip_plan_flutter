import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_trip_plan/models/itinerary_firestore_model.dart';
import 'package:smart_trip_plan/presentation/home/refine_prompt_screen.dart';
import 'package:smart_trip_plan/services/firebase_service.dart';

class ItineraryScreen extends StatelessWidget {
  final Map<String, dynamic> itineraryJson;
  final String prompt;
  final String username;
  final int promptTokens;
  final int responseTokens;

  const ItineraryScreen({
    super.key,
    required this.itineraryJson,
    required this.prompt,
    required this.username,
    required this.promptTokens,
    required this.responseTokens,
  });

  void _save(BuildContext context) async {
  final model = ItineraryFirestoreModel(
    id: '',
    prompt: prompt,
    jsonData: jsonEncode(itineraryJson),
    savedAt: DateTime.now(),
  );

  await FirebaseService().saveItinerary(model);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Itinerary saved successfully")),
  );
}


  void _refine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RefinePromptScreen(previousPrompt: prompt, username: username),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalTokens = promptTokens + responseTokens;
    final tokenCost = (totalTokens * 0.0001).toStringAsFixed(4); // Simulated cost

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF065F46),
        title: const Text("Your Itinerary"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: ListView(
          children: [
            Text("Hi $username,", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            const Text("Your Prompt:", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(prompt),
            ),

            const SizedBox(height: 20),
            const Text("Your Itinerary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            for (var day in itineraryJson['days']) ...[
              Text(
                "${day['date'] ?? 'Unknown Date'} - ${day['summary'] ?? 'No summary'}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              for (var item in day['items']) Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  "${item['time'] ?? ''} - ${item['activity'] ?? 'No activity'} (${item['location'] ?? 'Unknown location'})",
                ),
              ),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _refine(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Refine"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _save(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF065F46),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Save"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Center(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context), 
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF065F46)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Generate New Itinerary"),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Token bar widget
  Widget _buildProgressBar(String label, int value, Color color) {
    final width = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: $value"),
        const SizedBox(height: 4),
        Container(
          height: 10,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
          child: FractionallySizedBox(
            widthFactor: (value / 1000).clamp(0.05, 1.0),
            child: Container(
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
