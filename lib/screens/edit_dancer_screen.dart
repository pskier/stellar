import 'package:flutter/material.dart';
import 'package:stellar/services/firestore_service.dart';
import 'package:stellar/model/dancer.dart';

class EditDancerScreen extends StatefulWidget {
  final Dancer dancer;
  const EditDancerScreen({Key? key, required this.dancer}) : super(key: key);

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
  final List<String> availableHours = ['10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00'];
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
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || selectedHour == null) return;

    try {
      await FirestoreService.dancers.doc(widget.dancer.id).update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'age': int.tryParse(_ageController.text) ?? 0,
        'city': _cityController.text.trim(),
        'hour': selectedHour!,
        'additionalInfo': _additionalInfoController.text.trim(),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd aktualizacji: $e')),
      );
    }
  }

  Future<void> _delete() async {
    try {
      await FirestoreService.dancers.doc(widget.dancer.id).delete();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd usuwania: $e')),
      );
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
              TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'Miasto'),
                validator: (val) => val == null || val.isEmpty ? 'Wpisz miasto' : null,
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
              ElevatedButton(onPressed: _save, child: const Text('Zapisz')),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _delete,
                child: const Text('Usuń'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
