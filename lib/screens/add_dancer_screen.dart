import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stellar/model/dancer.dart';

class AddDancerScreen extends StatefulWidget {
  final String groupId;
  const AddDancerScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  State<AddDancerScreen> createState() => _AddDancerScreenState();
}

class _AddDancerScreenState extends State<AddDancerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _cityController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  List<String> availableHours = [];
  String? selectedHour;

  @override
  void initState() {
    super.initState();
    loadHours();
  }

  void loadHours() async {
    final doc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .get();
    final data = doc.data();
    if (data != null && data['hours'] != null) {
      setState(() {
        availableHours = List<String>.from(data['hours']);
        if (availableHours.isNotEmpty) {
          selectedHour = availableHours[0];
        }
      });
    }
  }

  void _saveDancer() async {
    if (!_formKey.currentState!.validate() || selectedHour == null) return;

    final newDancer = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'age': int.tryParse(_ageController.text) ?? 0,
      'city': _cityController.text,
      'hour': selectedHour!,
      'additionalInfo': _additionalInfoController.text,
    };

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('dancers')
        .add(newDancer);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dodaj tancerkę')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'Imię')),
              TextFormField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Nazwisko')),
              TextFormField(controller: _ageController, decoration: const InputDecoration(labelText: 'Wiek'), keyboardType: TextInputType.number),
              TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'Miejscowość')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedHour,
                decoration: const InputDecoration(labelText: 'Godzina'),
                items: availableHours.map((hour) => DropdownMenuItem(value: hour, child: Text(hour))).toList(),
                onChanged: (val) => setState(() => selectedHour = val),
                validator: (val) => val == null ? 'Wybierz godzinę' : null,
              ),
              TextFormField(controller: _additionalInfoController, decoration: const InputDecoration(labelText: 'Dodatkowe informacje')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveDancer, child: const Text('Zapisz')),
            ],
          ),
        ),
      ),
    );
  }
}

