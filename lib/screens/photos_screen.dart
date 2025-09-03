import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stellar/services/firestore_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({Key? key}) : super(key: key);

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  final _postsCollection = FirestoreService.posts;

  Future<void> _pickAndUploadMedia() async {
    final picker = ImagePicker();
    final XFile? file = await showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text("Dodaj media"),
        children: [
          SimpleDialogOption(
            onPressed: () async => Navigator.pop(ctx, await picker.pickImage(source: ImageSource.gallery)),
            child: const Text("Zdjęcie z galerii"),
          ),
          SimpleDialogOption(
            onPressed: () async => Navigator.pop(ctx, await picker.pickImage(source: ImageSource.camera)),
            child: const Text("Zrób zdjęcie"),
          ),
        ],
      ),
    );

    if (file == null) return;

    String description = "";
    await showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text("Dodaj opis"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Opis..."),
          ),
          actions: [
            TextButton(
              onPressed: () {
                description = controller.text.trim();
                Navigator.pop(ctx);
              },
              child: const Text("Zapisz"),
            ),
          ],
        );
      },
    );

    await FirestoreService.uploadPost(File(file.path), description);
  }

  Future<void> _deletePost(String docId, String url) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      await ref.delete();
    } catch (_) {}
    await _postsCollection.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Galeria")),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: StreamBuilder<QuerySnapshot>(
          stream: _postsCollection.orderBy("created_at", descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Brak postów"));
            }

            final posts = snapshot.data!.docs;

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final doc = posts[index];
                final data = doc.data() as Map<String, dynamic>;
                final url = data["url"] ?? "";
                final description = data["description"] ?? "";

                return GestureDetector(
                  onLongPress: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Usuń post"),
                        content: const Text("Czy na pewno chcesz usunąć ten post?"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Anuluj")),
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text("Usuń")),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _deletePost(doc.id, url);
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              description,
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadMedia,
        child: const Icon(Icons.add),
      ),
    );
  }
}
