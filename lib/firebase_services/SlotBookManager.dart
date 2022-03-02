import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventbooking/models/SlotBook.dart';
import 'package:eventbooking/utils/DateUtils.dart';
import 'Firebase.dart';

class SlotBookManager {
  static Future<String> createSlotBook(SlotBook newSB) async {
    DocumentReference sBRef = db.collection('SlotBookList').document();
    String sBId = sBRef.documentID;
    newSB.id = sBId;
    await sBRef.setData(newSB.toJson());
    return sBId;
  }

  static Future<void> cancelSlotBook(eventId, userId, slotNo) async {
    var querySnapshot = await db
        .collection('SlotBookList')
        .where('event_id', isEqualTo: eventId)
        .where('booker_id', isEqualTo: userId)
        .getDocuments();
    if (querySnapshot.documents.length == 0) return;
    await db
        .collection('SlotBookList')
        .document(querySnapshot.documents[0].documentID)
        .delete();
    return;
  }

  static Future<SlotBook> findWillRateBookingInfo(
      String userId, int nowTs) async {
    var querySnapshot = await db
        .collection('SlotBookList')
        .where('booker_id', isEqualTo: userId)
        .where('is_rated', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .where('timestamp', isLessThan: nowTs)
        .getDocuments();
    if (querySnapshot.documents.length == 0) {
      return null;
    }

    var sBDocs = querySnapshot.documents;
    var sBDoc;
    int ind = -1;
    int cnt;
    String _eId;
    var eventData;
    for (sBDoc in sBDocs) {
      ind++;
      _eId = sBDoc.data['event_id'];
      if (_eId.length == 0) continue;
      eventData = (await db.collection('Events').document(_eId).get()).data;
      cnt = 0;
      for (int i = 0; i < 4; i++) {
        if (eventData['slot_list'][i]['user_id'] != null &&
            eventData['slot_list'][i]['user_id'] != "") {
          cnt++;
        }
      }
      if (cnt > 1) {
        break;
      }
      await slotBookCollection
          .document(sBDoc['id'])
          .updateData({'is_rated': true});
    }
    if (cnt < 2) return null;
    return SlotBook.fromJson(sBDocs[ind].data);
  }

  static Future<bool> handlePreProcessor(String userId) async {
    int nowTs = DateUtils.getMiliseconds(new DateTime.now());
    var querySnapshot = await db
        .collection('SlotBookList')
        .where('booker_id', isEqualTo: userId)
        .where('is_rated', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .where('timestamp', isLessThan: nowTs)
        .getDocuments();
    if (querySnapshot.documents.length == 0) {
      return true;
    }
    var sBDocs = querySnapshot.documents;
    var sBDocData;
    int ind = -1;
    int cnt;
    String _eId;
    var eventData;
    for (var sBDoc in sBDocs) {
      ind++;
      sBDocData = sBDoc.data;
      _eId = sBDocData['event_id'];
      if (_eId.length == 0) continue;
      eventData = (await db.collection('Events').document(_eId).get()).data;
      cnt = 0;
      for (int i = 0; i < 4; i++) {
        if (eventData['slot_list'][i]['user_id'] != null &&
            eventData['slot_list'][i]['user_id'] != "") {
          cnt++;
        }
      }
      if (cnt < 2) {
        await slotBookCollection
            .document(sBDocData['id'])
            .updateData({'is_rated': true});
      }
    }
    return true;
  }

  static Future<bool> updateRate(slotBookId, isRated) async {
    await slotBookListCollection
        .document(slotBookId)
        .updateData({'is_rated': isRated});
    return true;
  }
}
