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
}
