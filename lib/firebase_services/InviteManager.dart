import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventbooking/firebase_services/Firebase.dart';
import 'package:eventbooking/models/INotification.dart';

class InviteManager {
  static Future<void> createNotification(INotification iNotification) async {
    DocumentReference ref = inviteNotifyCollection.document();
    iNotification.id = ref.documentID;
    ref.setData(iNotification.toJson());
    return;
  }

  static Future<void> deleteNotifcations(String phoneNumber) async {
    var ds = inviteNotifyCollection
        .where('phone_number', isEqualTo: phoneNumber)
        .where('checked', isEqualTo: false);
    ds.snapshots().forEach((snapShot) {
      snapShot.documents.forEach((doc) {
        doc.reference.updateData({'checked': true});
      });
    });
  }
}
