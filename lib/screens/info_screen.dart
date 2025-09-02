import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  Future<void> _addInfo() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _loading = true);

    try {
      await FirestoreService.addInfo(text);
      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd dodawania ogłoszenia: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteInfo(String docId) async {
    try {
      await FirestoreService.deleteInfo(docId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd usuwania ogłoszenia: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ogłoszenia')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Dodaj ogłoszenie',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _addInfo,
                  child: _loading
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Dodaj'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirestoreService.getInfoStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Błąd pobierania ogłoszeń: ${snapshot.error}'),
                    );
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('Brak ogłoszeń.'));
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final info = data['info'] ?? '';
                      final timestamp = data['created_at'] as Timestamp?;
                      final dateString = timestamp != null
                          ? DateFormat('dd.MM HH:mm') //
                          .format(timestamp.toDate())
                          : '';

                      return Card(
                        child: ListTile(
                          title: Text(info),
                          subtitle: Text(dateString),
                          onLongPress: () => _deleteInfo(doc.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
