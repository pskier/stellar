import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'groups_screen.dart';
import 'calendar_screen.dart';
import 'photos_screen.dart';
import 'info_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas wylogowania: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tileColor = Theme.of(context).colorScheme.primary.withOpacity(0.15);
    final iconColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('StellApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Wyloguj',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          children: [
            _buildTile(
              context,
              icon: Icons.group,
              label: 'Grupy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GroupsScreen()),
                );
              },
              backgroundColor: tileColor,
              iconColor: iconColor,
            ),
            _buildTile(
              context,
              icon: Icons.calendar_today,
              label: 'Kalendarz',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalendarScreen()),
                );
              },
              backgroundColor: tileColor,
              iconColor: iconColor,
            ),
            _buildTile(
              context,
              icon: Icons.fitness_center,
              label: 'Trening',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PhotosScreen()),
                );
              },
              backgroundColor: tileColor,
              iconColor: iconColor,
            ),
            _buildTile(
              context,
              icon: Icons.info,
              label: 'Info',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InfoScreen()),
                );
              },
              backgroundColor: tileColor,
              iconColor: iconColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
        required Color backgroundColor,
        required Color iconColor,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: iconColor,
              semanticLabel: label,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
