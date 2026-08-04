import 'supabase_service.dart';

class ProfileService {
  Future<void> updateProfile({
    String? jobTitle,
    String? bio,
    List<String> sports = const [],
    List<String> languages = const [],
  }) async {
    final authId = supabase.auth.currentUser!.id;
    await supabase.from('users').update({
      'job_title': jobTitle,
      'bio': bio,
      'sports': sports,
      'languages': languages,
    }).eq('auth_id', authId);
  }
}
