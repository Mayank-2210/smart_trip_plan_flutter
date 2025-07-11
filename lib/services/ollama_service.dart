import 'dart:convert';
import 'package:http/http.dart' as http;

/// OllamaService communicates with Node.js backend to get itineraries from Ollama
class OllamaService {
  // Update to your backend URL (localhost or production IP)
  final String backendUrl = 'http://localhost:5000/api/ai/generate-itinerary';

  /// Sends prompt and gets structured itinerary
  Future<Map<String, dynamic>> generateItinerary(String prompt) async {
    final uri = Uri.parse(backendUrl);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'prompt': prompt});

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate itinerary from backend: ${response.statusCode}');
    }
  }
}
