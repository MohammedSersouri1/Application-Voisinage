import '../models/announcement.dart';
import 'supabase_service.dart';

class AnnouncementService {
  Future<List<Announcement>> fetchAll(String residenceId) async {
    final data = await supabase
        .from('announcements')
        .select()
        .eq('residence_id', residenceId)
        .order('starts_at', ascending: false);
    return (data as List<dynamic>)
        .map((e) => Announcement.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Ouvert à tout résident (pas seulement le gestionnaire) : voir policy
  /// RLS "announcements_insert_residents" dans databaseschema.sql.
  Future<void> create({
    required String residenceId,
    required String authorId,
    required String authorName,
    required String type,
    required String title,
    String? body,
  }) async {
    await supabase.from('announcements').insert({
      'residence_id': residenceId,
      'author_id': authorId,
      'author_name': authorName,
      'type': type,
      'title': title,
      'body': body,
    });
  }
}
