import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventbooking/models/SlotBooking.dart';
import 'package:eventbooking/models/User.dart';
import 'package:eventbooking/utils/SessionManager.dart';

import 'Firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthManager {
  static Function onPhoneAuthSuccess;
  static Function onPhoneAuthFailure;
  static String verificationId;

  // Functions That Relates with Phone Authentication
  static final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
    verificationId = verId;
  };

  static final PhoneCodeSent smsCodeSent =
      (String verId, [int forceCodeResend]) {
    onPhoneAuthSuccess(verId);
  };

  static final PhoneVerificationFailed verfiFailed = (AuthException exception) {
    onPhoneAuthFailure(exception);
  };

  static Future<void> requestPhoneAuthentication(
      {phoneNo: String, onSuccess: Function, onFailure: Function}) async {
    onPhoneAuthSuccess = onSuccess;
    onPhoneAuthFailure = onFailure;
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 30),
        verificationFailed: verfiFailed);
  }

  static Future<FirebaseUser> verifyPhoneNumberWithSmsCode(
      {verificationId: String, verificationCode: String}) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: verificationCode,
    );
    var user = await authInstance.currentUser();
    if (user != null) {
      print("current User user total info===> $user");
      return user;
    } else {
      var user = await signIn(credential);
      return user;
    }
  }

  static Future<dynamic> signIn(credential) async {
    var user = await FirebaseAuth.instance.signInWithCredential(credential);
    print("sign info user $user.user");
    return user.user;
  }

  static Future<bool> loggedIn() async {
    var user = await await authInstance.currentUser();
    if (user != null) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> logOut() async {
    await FirebaseAuth.instance.signOut();
    return true;
  }

  // Get Current Firebase Authenticated User Instance
  static Future<FirebaseUser> getCurrentUser() async {
    final FirebaseUser user = await authInstance.currentUser();
    return user;
  }

  // Get Current Firebase Authenticated User ID
  static Future<String> getFirebaseUserId() async {
    final FirebaseUser user = await authInstance.currentUser();
    return user.uid;
  }

  // Get all User List
  static Future<List<User>> getAllUser() async {
    var querySnapshot = await userCollection.getDocuments();
    if (querySnapshot == null) return [];
    return querySnapshot.documents
            .map((snapshot) => User.fromJson(snapshot.data))
            ?.toList() ??
        [];
  }

  // Get User Information
  static Future<User> getUserInfo() async {
    var userId = await AuthManager.getFirebaseUserId();
    DocumentSnapshot documentSnapshot =
        await userCollection.document(userId).get();
    return User.fromJson(documentSnapshot.data);
  }

  static Future<User> getUserInfoById(String userId) async {
    DocumentSnapshot docRef = await userCollection.document(userId).get();
    print("-----> ${docRef.data}");
    return User.fromJson(docRef.data);
  }

  static Future<bool> setUserInfo(User user) async {
    var userId = SessionManager.getUserId();
    await userCollection.document(userId).updateData(user.toJson());
    return true;
  }

  static Future<void> updateSlotBookingHistory(
      String userId, List<SlotBooking> slotBookingHistory) async {
    List<String> slotBookingHistoryStrList = slotBookingHistory
        .map<String>((slotBooking) => json.encode(slotBooking.toJson()))
        .toList();
    await db.collection('Users').document(userId).updateData({
      'slot_booking_history': slotBookingHistoryStrList,
    });
  }

  static Future<bool> updateUserInfo(Map<String, String> payload) async {
    var userId = await getFirebaseUserId();
    try {
      await firestoreInstance.collection('Users').document(userId).updateData({
        'name': payload['name'],
        'gender': payload['gender'],
        'birthday': payload['birthday'],
        'email': payload['email'],
        'code': payload['code']
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> updateUserRole(String userId, String roleStr) async {
    try {
      await firestoreInstance
          .collection('Users')
          .document(userId)
          .updateData({'role': roleStr});
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
