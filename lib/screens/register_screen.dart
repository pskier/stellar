import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '', _firstName = '', _lastName = '';
  bool _loading = false;
  String? _errorMessage;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    _formKey.currentState!.save();

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.trim(),
        password: _password,
      );

      // Opcjonalnie: zaktualizuj profil użytkownika o imię i nazwisko
      await credential.user?.updateDisplayName('$_firstName $_lastName');

      // Po rejestracji wróć do logowania lub innego ekranu
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rejestracja powiodła się. Zaloguj się.')),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Wystąpił nieoczekiwany błąd.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rejestracja')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Imię'),
                  validator: (val) => val == null || val.isEmpty ? 'Wpisz imię' : null,
                  onSaved: (val) => _firstName = val ?? '',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nazwisko'),
                  validator: (val) => val == null || val.isEmpty ? 'Wpisz nazwisko' : null,
                  onSaved: (val) => _lastName = val ?? '',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val == null || !val.contains('@') ? 'Wpisz poprawny email' : null,
                  onSaved: (val) => _email = val ?? '',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Hasło'),
                  obscureText: true,
                  validator: (val) => val == null || val.length < 6 ? 'Hasło musi mieć min. 6 znaków' : null,
                  onSaved: (val) => _password = val ?? '',
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null) ...[
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                ],
                ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Zarejestruj się'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
