import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stellar/model/dancer.dart';

class EditDancerScreen extends StatefulWidget {
  final String groupId;
  final Dancer dancer;

  const EditDancerScreen({Key? key, required this.groupId, required this.dancer}) : super(key: key);

  @override
  State<EditDancerScreen> createState() => _EditDancerScreenState();
}

class _EditDancerScreenState extends State<EditDancerScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _ageController;
  late TextEditingController _cityController;
  late TextEditingController _additionalInfoController;

  List<String> availableHours = [];
  String? selectedHour;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.dancer.firstName);
    _lastNameController = TextEditingController(text: widget.dancer.lastName);
    _ageController = TextEditingController(text: widget.dancer.age.toString());
    _cityController = TextEditingController(text: widget.dancer.city);
    _additionalInfoController = TextEditingController(text: widget.dancer.additionalInfo);
    selectedHour = widget.dancer.hour;

    loadHours();
  }

  /// Pobranie godzin z dokumentu grupy
  void loadHours() async {
    final doc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .get();

    final data = doc.data();
    if (data != null && data['hours'] != null) {
      setState(() {
        availableHours = List<String>.from(data['hours']);
        if (!availableHours.contains(selectedHour) && availableHours.isNotEmpty) {
          selectedHour = availableHours[0];
        }
      });
    }
  }

  /// Zapisanie zmian tancerki
  void _save() async {
    if (!_formKey.currentState!.validate() || selectedHour == null) return;

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('dancers')
        .doc(widget.dancer.id)
        .update({
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'age': int.tryParse(_ageController.text) ?? 0,
      'city': _cityController.text,
      'hour': selectedHour!,
      'additionalInfo': _additionalInfoController.text,
    });

    Navigator.pop(context);
  }

  /// Usunięcie tancerki
  void _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Usuń tancerkę?'),
        content: const Text('Czy na pewno chcesz usunąć tę tancerkę?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Anuluj')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Usuń', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('dancers')
          .doc(widget.dancer.id)
          .delete();

      Navigator.pop(context); // wyjście z ekranu edycji
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edytuj tancerkę')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Imię'),
                validator: (val) => val == null || val.isEmpty ? 'Wprowadź imię' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Nazwisko'),
                validator: (val) => val == null || val.isEmpty ? 'Wprowadź nazwisko' : null,
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Wiek'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || int.tryParse(val) == null ? 'Wprowadź poprawny wiek' : null,
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Miejscowość'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedHour,
                decoration: const InputDecoration(labelText: 'Godzina'),
                items: availableHours
                    .map((hour) => DropdownMenuItem(value: hour, child: Text(hour)))
                    .toList(),
                onChanged: (val) => setState(() => selectedHour = val),
                validator: (val) => val == null ? 'Wybierz godzinę' : null,
              ),
              TextFormField(
                controller: _additionalInfoController,
                decoration: const InputDecoration(labelText: 'Dodatkowe informacje'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Zapisz')),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _delete,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Usuń'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
