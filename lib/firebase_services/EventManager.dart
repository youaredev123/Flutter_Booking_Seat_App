import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventbooking/models/Event.dart';
import 'package:eventbooking/models/Slot.dart';
import 'package:eventbooking/models/SlotBook.dart';

import 'Firebase.dart';

final CollectionReference eventCollection = db.collection('Events');

class EventManager {
  static final EventManager _instance = new EventManager.internal();

  factory EventManager() => _instance;

  EventManager.internal();

  Future<bool> createEventNDefaultSlotBook(Event event, SlotBook sB) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(eventCollection.document());
      final eventId = ds.documentID;
      event.id = eventId;
      final DocumentSnapshot dsSB =
          await tx.get(slotBookListCollection.document());
      sB.id = dsSB.documentID;
      sB.eventId = eventId;
      await tx.set(ds.reference, event.toJson());
      await tx.set(dsSB.reference, sB.toJson());
    };

    return db.runTransaction(createTransaction).then((res) {
      return true;
    }).catchError((error) {
      print("error: ${error.toString()}");
      return false;
    });
  }

  static Future<List<Event>> getEventList(int nowTs) async {
    var querySnapshot = await eventCollection
        .where('timestamp', isGreaterThanOrEqualTo: nowTs)
        .orderBy('timestamp', descending: false)
        .getDocuments();
    if (querySnapshot == null) return [];
    return querySnapshot.documents
            ?.map((snapshot) => Event.fromJson(snapshot.data))
            .toList() ??
        [];
  }

  static Future<List<Event>> getEventHistoryList(int nowTs,
      {int limit = 10}) async {
    var querySnapshot = await eventCollection
        .where('timestamp', isLessThan: nowTs)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .getDocuments();
    if (querySnapshot == null) return [];
    return querySnapshot.documents
            ?.map((snapshot) => Event.fromJson(snapshot.data))
            .toList() ??
        [];
  }

  static Future<bool> bookSlotNCreateSlotBook(
      Event eventInfo, List<Slot> updatedSlotList, SlotBook newSB) async {
    final DocumentReference eventRef = eventCollection.document(eventInfo.id);
    final TransactionHandler txHandler = (Transaction tx) async {
      DocumentSnapshot dsEve =
          await tx.get(eventCollection.document(eventInfo.id));
      DocumentSnapshot dsSB = await tx.get(slotBookListCollection.document());
      newSB.id = dsSB.documentID;
      if (dsEve.exists) {
        tx.update(eventRef, {
          'owner_id': eventInfo.ownerId,
          'owner_name': eventInfo.ownerName,
          'event_status': eventStatustoString(eventInfo.eventStatus),
          'slot_list': updatedSlotList.map((slot) => slot.toJson()).toList(),
        });
        tx.set(dsSB.reference, newSB.toJson());
      }
    };
    return db.runTransaction(txHandler).then((res) => true).catchError((error) {
      return false;
    });
  }

  static Future<bool> updateEvent(Event updatedEvent) async {
    final TransactionHandler txHandler = (Transaction tx) async {
      DocumentSnapshot ds =
          await tx.get(db.collection('Events').document(updatedEvent.id));
      if (!ds.exists) return {'updated': false};
      await tx.update(ds.reference, updatedEvent.toJson());
      return {'updated': true};
    };
    return db.runTransaction(txHandler).then((res) {
      return res['updated'] as bool;
    }).catchError((error) {
      print("error: $error");
      return false;
    });
  }

  static Future<void> cancelEvent(String eventId) async {
    await db.collection('Events').document(eventId).updateData({
      'event_status': eventStatustoString(EventStatus.CANCELLED),
    });
    return;
  }

  static Future<void> reopenEvent(String eventId) async {
    await db.collection('Events').document(eventId).updateData({
      'event_status': eventStatustoString(EventStatus.OPENED),
    });
    return;
  }

  static Future<void> lockEvent(String eventId) async {
    await db.collection('Events').document(eventId).updateData({
      'event_status': eventStatustoString(EventStatus.LOCKED),
    });
    return;
  }

  static Future<void> cancelBookingNUpdateEvent(Event eventInfo) async {
    await db
        .collection('Events')
        .document(eventInfo.id)
        .updateData(eventInfo.toJson());
    return;
  }

  static Future<Event> getEventInfoById(String eId) async {
    DocumentSnapshot documentSnapshot =
        await db.collection('Events').document(eId).get();
    if (documentSnapshot.data == null) return null;
    return Event.fromJson(documentSnapshot.data);
  }

  static Future<void> deleteEvent(String eventId) async {
    var querySnapshot = await db
        .collection('Events')
        .where('id', isEqualTo: eventId)
        .getDocuments();
    if (querySnapshot.documents.length == 0) return;
    await db
        .collection('Events')
        .document(querySnapshot.documents[0].documentID)
        .delete();
    return;
  }
}
