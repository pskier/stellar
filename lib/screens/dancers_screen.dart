import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stellar/screens/edit_dancer_screen.dart';
import 'dancer_detail_screen.dart';
import 'package:stellar/model/dancer.dart';
import 'add_dancer_screen.dart';

class DancersScreen extends StatelessWidget {
  final String groupId;
  DancersScreen({Key? key, required this.groupId}) : super(key: key);

  final CollectionReference dancersRef = FirebaseFirestore.instance
      .collection('groups');

  @override
  Widget build(BuildContext context) {
    final groupDancersRef = dancersRef.doc(groupId).collection('dancers');
    return Scaffold(
      appBar: AppBar(title: const Text('Tancerki')),
      body: StreamBuilder<QuerySnapshot>(
        stream: groupDancersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final dancers = snapshot.data!.docs
              .map((doc) => Dancer.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();

          // Grupa tancerek po godzinach
          final groupedDancers = <String, List<Dancer>>{};
          for (var dancer in dancers) {
            groupedDancers.putIfAbsent(dancer.hour, () => []).add(dancer);
          }

          return ListView(
            children: groupedDancers.entries.map((entry) {
              return ExpansionTile(
                title: Text('Godzina: ${entry.key}'),
                children: entry.value.map((dancer) {
                  return ListTile(
                    title: Text('${dancer.firstName} ${dancer.lastName[0]}.'),

                    // Kliknięcie: wchodzimy w szczegóły
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DancerDetailScreen(
                            groupId: groupId,
                            dancer: dancer,
                          ),
                        ),
                      );
                    },

                    // Przytrzymanie: wchodzimy w edycję
                    onLongPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditDancerScreen(
                            groupId: groupId,
                            dancer: dancer,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddDancerScreen(groupId: groupId),
            ),
          );
        },
      ),
    );
  }
}
