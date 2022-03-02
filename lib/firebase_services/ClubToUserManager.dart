import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventbooking/firebase_services/Firebase.dart';
import 'package:eventbooking/models/ClubToUser.dart';

class ClubToUserManager {
  static Future<void> create(ClubToUser ctu) async {
    DocumentReference documentReference = clubToUserCollection.document();
    ctu.id = documentReference.documentID;
    print("clubTo user documentID: ${ctu.id}");
    await documentReference.setData(ctu.toJson());
  }

  static Future<List<ClubToUser>> getInviteListByClubId(String clubId) async {
    QuerySnapshot querySnapshot = await clubToUserCollection
        .where('club_id', isEqualTo: clubId)
        .getDocuments();
    if (querySnapshot == null) return [];
    return querySnapshot.documents
            .map((snapShot) => ClubToUser.fromJson(snapShot.data))
            .toList() ??
        [];
  }

  static Future<List<ClubToUser>> getInviteListByPhoneNumber(
      String phoneNumber) async {
    QuerySnapshot querySnapshot = await clubToUserCollection
        .where('phone_number', isEqualTo: phoneNumber)
        .getDocuments();
    if (QuerySnapshot == null) return [];
    return querySnapshot.documents
            .map((snapShot) => ClubToUser.fromJson(snapShot.data))
            .toList() ??
        [];
  }

  static Future<List<ClubToUser>> getInviteListForInvite(
      String phoneNumber, String clubId) async {
    QuerySnapshot querySnapshot = await clubToUserCollection
        .where('phone_number', isEqualTo: phoneNumber)
        .where('club_id', isEqualTo: clubId)
        .getDocuments();
    if (QuerySnapshot == null) return [];
    return querySnapshot.documents
            .map((snapShot) => ClubToUser.fromJson(snapShot.data))
            .toList() ??
        [];
  }

  static Future<void> acceptInvite(String docId, String userId) async {
    await clubToUserCollection.document(docId).updateData(
        {'user_id': userId, 'invite_status': 'done', 'crole': 'user'});
  }

  static Future<void> rejectInvite(String docId) async {
    await clubToUserCollection.document(docId).updateData({
      'invite_status': 'rejected',
    });
  }

  static Future<void> clearInvites(String phoneNumber) async {
    print("phone number for deleting the notifications: $phoneNumber");
    QuerySnapshot querySnapshot = await clubToUserCollection
        .where('phone_number', isEqualTo: phoneNumber)
        .where('checked', isEqualTo: false)
        .where('invite_status', isEqualTo: 'sent')
        .getDocuments();
    print("queryShapShot===> ${querySnapshot.documents.length}");

    querySnapshot.documents.forEach((docSnapShout) async {
      print("===> ${docSnapShout.data.toString()}");
      await docSnapShout.reference.updateData({'checked': true});
    });
  }

  static Future<List<ClubToUser>> getClubListByUserId(String userId) async {
    QuerySnapshot querySnapshot = await clubToUserCollection
        .where('user_id', isEqualTo: userId)
        .where('invite_status', isEqualTo: 'done')
        .getDocuments();
    return querySnapshot.documents
        .map((docSnapShot) => ClubToUser.fromJson(docSnapShot.data))
        .toList();
  }

  static Future<List<ClubToUser>> getMyClubListByUserId(String userId) async {
    QuerySnapshot querySnapshot = await clubToUserCollection
        .where('user_id', isEqualTo: userId)
        .where('crole', isEqualTo: 'admin')
        .getDocuments();
    print("=====> ${querySnapshot.documents.length}");
    return querySnapshot.documents
        .map((docSnapShot) => ClubToUser.fromJson(docSnapShot.data))
        .toList();
  }

  static Future<List<String>> getMemberIdListByClubId(String clubId) async {
    print("clubId: $clubId");
    QuerySnapshot querySnapshot = await clubToUserCollection
        .where('club_id', isEqualTo: clubId)
        .where('invite_status', isEqualTo: 'done')
        .getDocuments();
    if (querySnapshot == null) return [];
    List<String> memberIdList = querySnapshot.documents
            .map((docSnapShot) => ClubToUser.fromJson(docSnapShot.data).userId)
            .toList() ??
        [];
    return memberIdList;
  }
}
