import 'package:flutter/material.dart';
import 'package:stellar/model/dancer.dart';

class DancerDetailScreen extends StatelessWidget {
  final Dancer dancer;
  const DancerDetailScreen({Key? key, required this.dancer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Szczegóły tancerki')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Imię: ${dancer.firstName}', style: const TextStyle(fontSize: 18)),
            Text('Nazwisko: ${dancer.lastName}', style: const TextStyle(fontSize: 18)),
            Text('Wiek: ${dancer.age}', style: const TextStyle(fontSize: 18)),
            Text('Miasto: ${dancer.city}', style: const TextStyle(fontSize: 18)),
            Text('Godzina: ${dancer.hour}', style: const TextStyle(fontSize: 18)),
            Text('Dodatkowe info: ${dancer.additionalInfo}', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
