class ItineraryFirestoreModel {
  final String id;
  final String prompt;
  final String jsonData;
  final DateTime savedAt;

  ItineraryFirestoreModel({
    required this.id,
    required this.prompt,
    required this.jsonData,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'prompt': prompt,
      'jsonData': jsonData,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory ItineraryFirestoreModel.fromMap(String id, Map<String, dynamic> map) {
    return ItineraryFirestoreModel(
      id: id,
      prompt: map['prompt'],
      jsonData: map['jsonData'],
      savedAt: DateTime.parse(map['savedAt']),
    );
  }
}
