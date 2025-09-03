import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService {
  static final FirebaseFirestore instance = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'groups',
  );

  static CollectionReference get dancers => instance.collection('dancers');
  static CollectionReference get info => instance.collection('info');
  static CollectionReference get posts => instance.collection('posts');

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

  static Future<void> uploadPost(File file, String description) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref().child('posts').child(fileName);

    await ref.putFile(file);

    final downloadUrl = await ref.getDownloadURL();

    await posts.add({
      'url': downloadUrl,
      'description': description,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> getPosts() {
    return posts.orderBy('createdAt', descending: true).snapshots();
  }
}
