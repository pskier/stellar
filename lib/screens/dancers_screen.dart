import 'package:flutter/material.dart';
import 'package:stellar/services/firestore_service.dart';
import 'package:stellar/model/dancer.dart';
import 'dancer_detail_screen.dart';
import 'edit_dancer_screen.dart';
import 'add_dancer_screen.dart';

class DancersScreen extends StatelessWidget {
  final String city;
  const DancersScreen({Key? key, required this.city}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dancersRef = FirestoreService.dancers;

    return Scaffold(
      appBar: AppBar(title: Text('Tancerki: $city')),
      body: StreamBuilder(
        stream: dancersRef.where('city', isEqualTo: city).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final dancers = snapshot.data!.docs
              .map((doc) => Dancer.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();

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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DancerDetailScreen(dancer: dancer),
                        ),
                      );
                    },
                    onLongPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditDancerScreen(dancer: dancer),
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
            MaterialPageRoute(builder: (_) => AddDancerScreen(city: city)),
          );
        },
      ),
    );
  }
}
