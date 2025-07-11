import 'package:flutter/material.dart';

class FullscreenItineraryScreen extends StatelessWidget {
  final Map<String, dynamic> itinerary;

  const FullscreenItineraryScreen({super.key, required this.itinerary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(itinerary['title'] ?? 'Itinerary'),
        leading: BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            itinerary.toString(), // Display raw JSON for now
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ),
    );
  }
}
