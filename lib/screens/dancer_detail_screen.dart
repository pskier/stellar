import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stellar/model/dancer.dart';

class DancerDetailScreen extends StatefulWidget {
  final Dancer dancer;
  final String groupId;

  const DancerDetailScreen({Key? key, required this.dancer, required this.groupId}) : super(key: key);

  @override
  State<DancerDetailScreen> createState() => _DancerDetailScreenState();
}

class _DancerDetailScreenState extends State<DancerDetailScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController ageController;
  late TextEditingController cityController;
  late TextEditingController hourController;
  late TextEditingController additionalInfoController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.dancer.firstName);
    lastNameController = TextEditingController(text: widget.dancer.lastName);
    ageController = TextEditingController(text: widget.dancer.age.toString());
    cityController = TextEditingController(text: widget.dancer.city);
    hourController = TextEditingController(text: widget.dancer.hour);
    additionalInfoController = TextEditingController(text: widget.dancer.additionalInfo);
  }

  void _save() async {
    final docRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('dancers')
        .doc(widget.dancer.id);

    await docRef.update({
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'age': int.tryParse(ageController.text) ?? 0,
      'city': cityController.text,
      'hour': hourController.text,
      'additionalInfo': additionalInfoController.text,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Szczegóły Tancerki')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: firstNameController, decoration: const InputDecoration(labelText: 'Imię')),
            TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Nazwisko')),
            TextField(controller: ageController, decoration: const InputDecoration(labelText: 'Wiek'), keyboardType: TextInputType.number),
            TextField(controller: cityController, decoration: const InputDecoration(labelText: 'Miejscowość')),
            TextField(controller: hourController, decoration: const InputDecoration(labelText: 'Godzina')), // później można zamienić na dropdown
            TextField(controller: additionalInfoController, decoration: const InputDecoration(labelText: 'Dodatkowe informacje')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Zapisz')),
          ],
        ),
      ),
    );
  }
}
