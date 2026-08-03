import '../models/activity.dart';
import 'supabase_service.dart';

class ActivityService {
  Future<List<Activity>> fetchActivities(
    String residenceId, {
    String? currentUserId,
  }) async {
    final data = await supabase
        .from('activities')
        .select('*, activity_participants(user_id)')
        .eq('residence_id', residenceId)
        .eq('status', 'open')
        .order('starts_at');

    return (data as List<dynamic>)
        .map((raw) => Activity.fromMap(
              raw as Map<String, dynamic>,
              currentUserId: currentUserId,
            ))
        .toList();
  }

  Future<void> createActivity({
    required String residenceId,
    required String creatorId,
    required String sportType,
    required String title,
    String? description,
    String? location,
    required DateTime startsAt,
    required int maxParticipants,
  }) async {
    await supabase.from('activities').insert({
      'residence_id': residenceId,
      'creator_id': creatorId,
      'sport_type': sportType,
      'title': title,
      'description': description,
      'location': location,
      'starts_at': startsAt.toIso8601String(),
      'max_participants': maxParticipants,
    });
  }

  Future<void> join({required String activityId, required String userId}) async {
    await supabase.from('activity_participants').insert({
      'activity_id': activityId,
      'user_id': userId,
    });
  }

  Future<void> leave({
    required String activityId,
    required String userId,
  }) async {
    await supabase
        .from('activity_participants')
        .delete()
        .eq('activity_id', activityId)
        .eq('user_id', userId);
  }
}
