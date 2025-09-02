import 'package:flutter/material.dart';
import 'package:stellar/services/firestore_service.dart';
import 'dancers_screen.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dancersRef = FirestoreService.dancers;

    return Scaffold(
      appBar: AppBar(title: const Text('Miasta / Grupy')),
      body: StreamBuilder(
        stream: dancersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final cities = <String>{};
          for (var doc in snapshot.data!.docs) {
            final city = doc['city'] ?? '';
            if (city.isNotEmpty) cities.add(city);
          }
          final cityList = cities.toList()..sort();

          return ListView.builder(
            itemCount: cityList.length,
            itemBuilder: (context, index) {
              final city = cityList[index];
              return ListTile(
                title: Text(city),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DancersScreen(city: city)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
