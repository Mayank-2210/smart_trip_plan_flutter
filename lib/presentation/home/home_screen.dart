import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_trip_plan/db/isar_service.dart';
import 'package:smart_trip_plan/models/itinerary_model.dart';
import 'package:smart_trip_plan/services/ollama_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _promptController = TextEditingController();
  final ollamaService = OllamaService();
  final isarService = IsarService();

  Map<String, dynamic>? itineraryJson;
  List<ItineraryModel> savedItineraries = [];

  bool isLoading = false;
  String previousPrompt = "";

  @override
  void initState() {
    super.initState();
    _loadItineraries();
  }

  /// Load all saved itineraries
  void _loadItineraries() async {
    final data = await isarService.getItineraries();
    setState(() => savedItineraries = data);
  }

  /// Generate itinerary using Ollama
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

  /// Open first location in Google Maps
  void _openMap() {
    if (itineraryJson == null) return;

    final coords = itineraryJson!['days'][0]['items'][0]['location'];
    final uri =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$coords");

    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Save itinerary to local storage
  void _saveItinerary() async {
    if (itineraryJson == null) return;

    final saved = ItineraryModel()
      ..prompt = previousPrompt
      ..jsonData = jsonEncode(itineraryJson)
      ..savedAt = DateTime.now();

    await isarService.saveItinerary(saved);
    _promptController.clear();
    _loadItineraries();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Itinerary saved")),
    );
  }

  /// Load previous prompt back into text box
  void _refineItinerary() {
    _promptController.text = previousPrompt;
  }

  /// Show full screen itinerary from saved JSON
  void _showSavedItinerary(ItineraryModel itinerary) {
    final json = jsonDecode(itinerary.jsonData);
    showDialog(
      context: context,
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(itinerary.prompt),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(json['title'],
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("${json['startDate']} → ${json['endDate']}"),
              const SizedBox(height: 16),
              for (var day in json['days']) ...[
                Text("${day['date']} - ${day['summary']}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                for (var item in day['items'])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                        " ${item['time']} - ${item['activity']} (${item['location']})"),
                  ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Delete a saved itinerary
  void _deleteItinerary(int id) async {
    await isarService.deleteItinerary(id);
    _loadItineraries();
  }

  /// Share itinerary via share_plus
  void _shareItinerary(String data) {
    Share.share(data);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Trip Planner"),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hi ${widget.username},",
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),

              const SizedBox(height: 8),
              const Text("Where do you want to go?"),

              const SizedBox(height: 16),

              // Prompt box + generate button
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
                  ElevatedButton(
                    onPressed: _refineItinerary,
                    child: const Text("Refine Itinerary"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _saveItinerary,
                    child: const Text("Save Itinerary"),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Generated Itinerary View
              if (itineraryJson != null)
                Expanded(
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView(
                        children: [
                          Text(itineraryJson!['title'],
                              style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("${itineraryJson!['startDate']} → ${itineraryJson!['endDate']}"),
                          const SizedBox(height: 16),
                          for (var day in itineraryJson!['days']) ...[
                            Text("${day['date']} - ${day['summary']}",
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            for (var item in day['items'])
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                    "${item['time']} - ${item['activity']} (${item['location']})"),
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

              // Saved Itineraries
              const Text("Your Saved Itineraries:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: savedItineraries.length,
                  itemBuilder: (context, index) {
                    final item = savedItineraries[index];
                    return GestureDetector(
                      onTap: () => _showSavedItinerary(item),
                      onLongPress: () => _deleteItinerary(item.id),
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: 200,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.prompt,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _deleteItinerary(item.id)),
                                  IconButton(
                                      icon: const Icon(Icons.share),
                                      onPressed: () =>
                                          _shareItinerary(item.jsonData)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
