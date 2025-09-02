import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreService {
  static final FirebaseFirestore instance = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'groups',
  );

  static CollectionReference get dancers => instance.collection('dancers');
  static CollectionReference get info => instance.collection('info');

  static Future<void> addInfo(String text) async {
    await info.add({
      'info': text,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteInfo(String docId) async {
    await info.doc(docId).delete();
  }

  static Stream<QuerySnapshot> getInfoStream() {
    return info.orderBy('created_at', descending: true).snapshots();
  }
}
