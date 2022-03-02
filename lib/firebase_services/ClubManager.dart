import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventbooking/models/Club.dart';

import 'Firebase.dart';

class ClubManager {
  static Future<Club> createClub(Club newClub) async {
    DocumentReference clubRef = clubCollection.document();
    String newDocId = clubRef.documentID;
    newClub.id = newDocId;
    await clubRef.setData(newClub.toJson());
    return newClub;
  }

  static Future<Club> getClubInfoById(String clubId) async {
    DocumentSnapshot documentSnapshot =
        await clubCollection.document(clubId).get();
    return Club.fromJson(documentSnapshot.data);
  }

  static Future<List<Club>> getAllClubs() async {
    var querySnapshot = await clubCollection.getDocuments();
    print(querySnapshot);
    if (querySnapshot == null) return [];
    return querySnapshot.documents
            ?.map((doc) => Club.fromJson(doc.data))
            .toList() ??
        [];
  }

  static Future<bool> updateClub(Club updatedClub) async {
    await clubCollection
        .document(updatedClub.id)
        .updateData(updatedClub.toJson());
    return true;
  }

  static Future<bool> addNewInvite(String clubId, Invite newInvite) async {
    List<dynamic> _inviteList;
    List<dynamic> _inviteList1 = [];
    final TransactionHandler txHandler = (Transaction tx) async {
      DocumentSnapshot ds = await tx.get(clubCollection.document(clubId));
      if (!ds.exists) return {'added': false};

      _inviteList = ds.data['invite_list'];
      _inviteList.forEach((data) {
        _inviteList1.add(data);
      });
      _inviteList1.add(newInvite.toJson());
      await tx.update(ds.reference, {'invite_list': _inviteList1});
      return {'added': true};
    };
    return db.runTransaction(txHandler).then((res) {
      return res['added'] as bool;
    }).catchError((error) {
      print("error: $error");
      return false;
    });
  }
}
