// lib/presentation/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:smart_trip_plan/services/ollama_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _promptController = TextEditingController();
  final ollamaService = OllamaService();

  Map<String, dynamic>? itineraryJson;
  bool isLoading = false;

  String previousPrompt = "";

  /// 🔁 Send prompt to backend via Ollama
  void _sendPrompt() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      isLoading = true;
      itineraryJson = null;
    });

    try {
      final result = await ollamaService.generateItinerary(prompt);

      setState(() {
        itineraryJson = result;
        previousPrompt = prompt;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Itinerary generated successfully")),
      );
    } catch (e) {
      print("AI Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to generate itinerary: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// 🌍 Open first location in Maps
  void _openMap() {
    if (itineraryJson == null) return;

    final coords = itineraryJson!['days'][0]['items'][0]['location'];
    final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$coords");

    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// 📝 Refine prompt
  void _refinePrompt() {
    _promptController.text = previousPrompt;
  }

  /// 💾 Save itinerary (placeholder)
  void _saveItinerary() {
    print("TODO: Save to local Isar DB.");
    _promptController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Smart Trip Planner"), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text("Hi ${widget.username},", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Where do you want to go?"),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promptController,
                      decoration: const InputDecoration(
                        hintText: "Generate your itinerary",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isLoading ? null : _sendPrompt,
                    child: isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Go"),
                  )
                ],
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(onPressed: _refinePrompt, child: const Text("Refine")),
                  const SizedBox(width: 10),
                  ElevatedButton(onPressed: _saveItinerary, child: const Text("Save")),
                ],
              ),

              const SizedBox(height: 16),
              if (itineraryJson != null)
                Expanded(
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView(
                        children: [
                          Text(itineraryJson!['title'],
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),

                          const SizedBox(height: 8),
                          Text("${itineraryJson!['startDate']} → ${itineraryJson!['endDate']}"),

                          const SizedBox(height: 16),

                          for (var day in itineraryJson!['days']) ...[
                            Text(" ${day['date']} - ${day['summary']}",
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            for (var item in day['items'])
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text("${item['time']} - ${item['activity']} (${item['location']})"),
                              ),
                            const SizedBox(height: 12),
                          ],

                          ElevatedButton.icon(
                            onPressed: _openMap,
                            icon: const Icon(Icons.map),
                            label: const Text("Open First Location in Maps"),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Placeholder for saved itineraries
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Card(
                      child: Container(
                        width: 200,
                        padding: const EdgeInsets.all(12),
                        child: const Text("Saved itinerary placeholder..."),
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
