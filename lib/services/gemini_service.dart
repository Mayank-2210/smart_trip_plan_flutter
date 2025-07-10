// lib/services/gemini_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

///GeminiService handles communication with Google Gemini AI
class GeminiService {
  // API key from https://makersuite.google.com/app/apikey
  final String apiKey = 'AIzaSyARpndvvT7al2p4uAMEJbZzLvXu2CHbQpE'; 

  // Gemini endpoint for text generation
  final String endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  /// Function to send prompt to Gemini and return structured itinerary
  Future<Map<String, dynamic>> generateItinerary(String prompt) async {
    try {
      // Compose Gemini-compatible request body
      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    "You are a travel planner assistant. Return only structured JSON like this:\n"
                    "{ \"title\": \"Tokyo 3-Day Solo Trip\", \"startDate\": \"2025-09-12\", \"endDate\": \"2025-09-14\","
                    "\"days\": [ {\"date\": \"2025-09-12\", \"summary\": \"Asakusa & Ueno\", \"items\": [ {\"time\": \"09:00\", \"activity\": \"Sensoji Temple visit\", \"location\": \"35.7148,139.7967\"} ] } ] }\n"
                    "Only return valid JSON.\n\nUser prompt: $prompt"
              }
            ]
          }
        ]
      });

      // Make HTTP POST request to Gemini
      final response = await http.post(
        Uri.parse('$endpoint?key=$apiKey'),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      // Check for valid response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Gemini returns text response, not JSON → Parse manually
        final text = data['candidates'][0]['content']['parts'][0]['text'];

        // Parse the text into JSON (our itinerary)
        final itinerary = jsonDecode(text);
        return itinerary;
      } else {
        throw Exception("Gemini API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Gemini Error: $e");
      rethrow;
    }
  }
}
