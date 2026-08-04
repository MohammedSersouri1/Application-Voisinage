import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import 'supabase_service.dart';

class AuthService {
  Session? get currentSession => supabase.auth.currentSession;

  User? get currentAuthUser => supabase.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => supabase.auth.onAuthStateChange;

  /// Le projet Supabase doit avoir "Confirm email" désactivé pour ce MVP
  /// (Authentication > Providers > Email), sans quoi aucune session n'est
  /// active juste après signUp() et l'insertion du profil ci-dessous échoue.
  /// Voir SETUP.md.
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw Exception('Inscription impossible, réessayez.');
    }
    await supabase.from('users').insert({
      'auth_id': user.id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'terms_accepted_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<UserProfile?> fetchCurrentProfile() async {
    final authUser = currentAuthUser;
    if (authUser == null) return null;
    final data = await supabase
        .from('users')
        .select()
        .eq('auth_id', authUser.id)
        .maybeSingle();
    if (data == null) return null;
    return UserProfile.fromMap(data);
  }
}
