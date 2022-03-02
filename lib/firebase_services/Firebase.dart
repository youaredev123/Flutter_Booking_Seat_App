import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth authInstance = FirebaseAuth.instance;
Firestore firestoreInstance = Firestore.instance;
final db = Firestore.instance;
final slotBookListCollection = Firestore.instance.collection('SlotBookList');
final userCollection = Firestore.instance.collection("Users");
final slotBookCollection = Firestore.instance.collection('SlotBookList');
final rateCollection  = Firestore.instance.collection('RateList');
final clubCollection = Firestore.instance.collection('Clubs');
final inviteNotifyCollection = Firestore.instance.collection('InviteNotifications');
final clubToUserCollection = Firestore.instance.collection('ClubToUserList');
