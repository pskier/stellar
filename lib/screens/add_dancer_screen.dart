import 'package:flutter/material.dart';
import 'package:stellar/services/firestore_service.dart';

class AddDancerScreen extends StatefulWidget {
  final String city;
  const AddDancerScreen({Key? key, required this.city}) : super(key: key);

  @override
  State<AddDancerScreen> createState() => _AddDancerScreenState();
}

class _AddDancerScreenState extends State<AddDancerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  final List<String> availableHours = ['10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00'];
  String? selectedHour;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || selectedHour == null) return;

    try {
      await FirestoreService.dancers.add({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'age': int.tryParse(_ageController.text) ?? 0,
        'city': widget.city,
        'hour': selectedHour!,
        'additionalInfo': _additionalInfoController.text.trim(),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd dodawania tancerki: $e')),
      );
    }
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
              TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'Imię'),
                validator: (val) => val == null || val.isEmpty ? 'Wpisz imię' : null,
              ),
              TextFormField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Nazwisko'),
                validator: (val) => val == null || val.isEmpty ? 'Wpisz nazwisko' : null,
              ),
              TextFormField(controller: _ageController, decoration: const InputDecoration(labelText: 'Wiek'), keyboardType: TextInputType.number,
                validator: (val) {
                  final age = int.tryParse(val ?? '');
                  if (age == null || age <= 0) return 'Wpisz poprawny wiek';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedHour,
                decoration: const InputDecoration(labelText: 'Godzina'),
                items: availableHours.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
                onChanged: (val) => setState(() => selectedHour = val),
                validator: (val) => val == null ? 'Wybierz godzinę' : null,
              ),
              TextFormField(controller: _additionalInfoController, decoration: const InputDecoration(labelText: 'Dodatkowe informacje')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Dodaj')),
            ],
          ),
        ),
      ),
    );
  }
}
