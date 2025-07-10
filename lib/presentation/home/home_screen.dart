import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ NEW: For opening Google Maps
import 'package:share_plus/share_plus.dart'; // ✅ NEW: For sharing
import 'package:firebase_auth/firebase_auth.dart'; // ✅ For logout
import '../auth/signup_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _promptController = TextEditingController();
  String? previousPrompt;

  // ✅ Mocked AI response for now
  Map<String, dynamic>? itineraryJson;

  /// ✅ MOCK: Simulate sending prompt to AI
  void _sendPrompt() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      itineraryJson = {
        "title": "Kyoto 5-Day Solo Trip",
        "startDate": "2025-04-10",
        "endDate": "2025-04-15",
        "days": [
          {
            "date": "2025-04-10",
            "summary": "Fushimi Inari & Gion",
            "items": [
              {
                "time": "09:00",
                "activity": "Climb Fushimi Inari Shrine",
                "location": "34.9671,135.7727"
              },
              {
                "time": "14:00",
                "activity": "Lunch at Nishiki Market",
                "location": "35.0047,135.7630"
              },
              {
                "time": "18:30",
                "activity": "Evening walk in Gion",
                "location": "35.0037,135.7788"
              }
            ]
          }
        ]
      };
      previousPrompt = prompt;
    });
  }

  /// ✅ Open Google Maps with first location
  void _openFirstLocation() {
    if (itineraryJson != null &&
        itineraryJson!["days"] != null &&
        itineraryJson!["days"].isNotEmpty) {
      final firstLocation = itineraryJson!["days"][0]["items"][0]["location"];
      final url = "https://www.google.com/maps/search/?api=1&query=$firstLocation";
      launchUrl(Uri.parse(url));
    }
  }

  /// ✅ Save itinerary to local cache (placeholder for Isar)
  void _saveItinerary() {
    if (itineraryJson != null) {
      print("Saving itinerary...");
      // TODO: Use Isar to save prompt + response
      setState(() {
        _promptController.clear(); // ✅ Clear input after save
      });
    }
  }

  /// ✅ Refine prompt (bring old back to box)
  void _refinePrompt() {
    if (previousPrompt != null) {
      setState(() {
        _promptController.text = previousPrompt!;
      });
    }
  }

  /// ✅ Share itinerary (share title for now)
  void _shareItinerary() {
    if (itineraryJson != null) {
      final title = itineraryJson!["title"];
      Share.share("Check out my trip plan: $title");
    }
  }

  /// ✅ Delete itinerary from memory (mock)
  void _deleteItinerary() {
    setState(() {
      itineraryJson = null;
      previousPrompt = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trip Planner"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                labelText: "Describe your trip",
                hintText: "e.g. 4 days in Tokyo for a solo traveler...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _refinePrompt,
                    child: const Text("Refine"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveItinerary,
                    child: const Text("Save"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _sendPrompt,
              child: const Text("Create My Itinerary"),
            ),

            const SizedBox(height: 20),

            if (itineraryJson != null) ...[
              Text(
                itineraryJson!["title"] ?? "Your Itinerary",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                "Start: ${itineraryJson!["startDate"]}  →  End: ${itineraryJson!["endDate"]}",
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                itemCount: itineraryJson!["days"].length,
                itemBuilder: (context, index) {
                  final day = itineraryJson!["days"][index];
                  return Card(
                    child: ListTile(
                      title: Text("${day["date"]}: ${day["summary"]}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          day["items"].length,
                          (i) {
                            final item = day["items"][i];
                            return Text("${item["time"]} - ${item["activity"]}");
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.map),
                    onPressed: _openFirstLocation,
                    tooltip: "Open Map",
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: _shareItinerary,
                    tooltip: "Share Itinerary",
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteItinerary,
                    tooltip: "Delete",
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
