import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dancers_screen.dart';

class GroupsScreen extends StatelessWidget {
  final CollectionReference groupsRef =
  FirebaseFirestore.instance.collection('groups');

  GroupsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grupy')),
      body: StreamBuilder<QuerySnapshot>(
        stream: groupsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final groups = snapshot.data!.docs;
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return ListTile(
                title: Text(group['name']),
                subtitle: Text(group['location'] ?? ''),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DancersScreen(groupId: group.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // TODO: Dodawanie grupy lub tancerki (ewentualnie tylko tancerki)
        },
      ),
    );
  }
}
