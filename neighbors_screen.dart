import 'package:flutter/material.dart';

import '../../services/app_session.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _jobTitleController;
  late final TextEditingController _bioController;
  late final TextEditingController _sportsController;
  late final TextEditingController _languagesController;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final profile = AppSession.profile!;
    _jobTitleController = TextEditingController(text: profile.jobTitle ?? '');
    _bioController = TextEditingController(text: profile.bio ?? '');
    _sportsController = TextEditingController(text: profile.sports.join(', '));
    _languagesController =
        TextEditingController(text: profile.languages.join(', '));
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _bioController.dispose();
    _sportsController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  List<String> _parseList(String text) => text
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ProfileService().updateProfile(
        jobTitle: _jobTitleController.text.trim().isEmpty
            ? null
            : _jobTitleController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        sports: _parseList(_sportsController.text),
        languages: _parseList(_languagesController.text),
      );
      AppSession.profile = await AuthService().fetchCurrentProfile();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier mon profil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _jobTitleController,
                decoration: const InputDecoration(labelText: 'Métier'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _sportsController,
                decoration: const InputDecoration(
                  labelText: 'Sports (séparés par des virgules)',
                  hintText: 'Football, Padel',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _languagesController,
                decoration: const InputDecoration(
                  labelText: 'Langues (séparées par des virgules)',
                  hintText: 'Français, Anglais',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
