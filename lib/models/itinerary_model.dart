// lib/models/itinerary_model.dart

import 'package:isar/isar.dart';

part 'itinerary_model.g.dart';

@collection
class ItineraryModel {
  Id id = Isar.autoIncrement;

  late String title;
  late String startDate;
  late String endDate;
  late String rawJson; 
  late DateTime savedAt;
  late String prompt;
  late String jsonData;
}
