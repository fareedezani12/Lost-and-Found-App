import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    await firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
