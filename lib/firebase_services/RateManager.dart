import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventbooking/models/Rate.dart';
import 'Firebase.dart';

class RateManager {
  static Future<String> createRate(Rate newRate) async {
    DocumentReference rateRef = db.collection('RateList').document();
    String _newRateId = rateRef.documentID;
    newRate.id = _newRateId;
    await rateRef.setData(newRate.toJson());
    return _newRateId;
  }
}
