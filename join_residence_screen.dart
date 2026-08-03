import 'package:flutter/material.dart';

import '../../services/app_session.dart';
import '../../services/auth_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = AppSession.profile!;
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(
                profile.firstName.isNotEmpty ? profile.firstName[0] : '?',
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              profile.fullName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (profile.jobTitle != null)
              Text('💼 ${profile.jobTitle}', textAlign: TextAlign.center),
            if (profile.sports.isNotEmpty)
              Text(
                '⚽ ${profile.sports.join(' / ')}',
                textAlign: TextAlign.center,
              ),
            if (profile.languages.isNotEmpty)
              Text(profile.languages.join(' · '), textAlign: TextAlign.center),
            if (profile.bio != null) ...[
              const SizedBox(height: 12),
              Text(profile.bio!, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
              child: const Text('Modifier mon profil'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                await AuthService().signOut();
                // AuthGate (racine de l'app) réagit à onAuthStateChange et
                // affichera l'écran de connexion, mais seulement une fois
                // cette route (poussée par-dessus) retirée de la pile.
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              child: const Text('Se déconnecter'),
            ),
          ],
        ),
      ),
    );
  }
}
