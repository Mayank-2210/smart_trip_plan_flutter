// lib/db/isar_service.dart

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_trip_plan/models/itinerary_model.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = _initDb();
  }

  Future<Isar> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [ItineraryModelSchema],
      directory: dir.path,
    );
  }

  Future<void> saveItinerary(ItineraryModel itinerary) async {
    final isar = await db;
    await isar.writeTxn(() => isar.itineraryModels.put(itinerary));
  }

  Future<List<ItineraryModel>> getItineraries() async {
    final isar = await db;
    return await isar.itineraryModels.where().sortBySavedAtDesc().findAll();
  }

  Future<void> deleteItinerary(int id) async {
    final isar = await db;
    await isar.writeTxn(() => isar.itineraryModels.delete(id));
  }
}
