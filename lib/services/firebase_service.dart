import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/itinerary_firestore_model.dart';

class FirebaseService {
  final _db = FirebaseFirestore.instance;

  Future<void> saveItinerary(ItineraryFirestoreModel itinerary) async {
    await _db.collection("itineraries").add(itinerary.toMap());
  }

  Future<List<ItineraryFirestoreModel>> getItineraries() async {
    final snapshot = await _db.collection("itineraries").orderBy("savedAt", descending: true).get();

    return snapshot.docs.map((doc) =>
        ItineraryFirestoreModel.fromMap(doc.id, doc.data())).toList();
  }

  Future<void> deleteItinerary(String id) async {
    await _db.collection("itineraries").doc(id).delete();
  }
}
