import '../models/job_post.dart';
import 'supabase_service.dart';

class JobService {
  Future<List<JobPost>> fetchOpen(String residenceId) async {
    final data = await supabase
        .from('job_posts')
        .select()
        .eq('residence_id', residenceId)
        .eq('status', 'open')
        .order('created_at', ascending: false);
    return (data as List<dynamic>)
        .map((e) => JobPost.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> create({
    required String residenceId,
    required String creatorId,
    required String direction,
    required String category,
    required String title,
    String? description,
    DateTime? availableFrom,
  }) async {
    await supabase.from('job_posts').insert({
      'residence_id': residenceId,
      'creator_id': creatorId,
      'direction': direction,
      'category': category,
      'title': title,
      'description': description,
      'available_from':
          availableFrom?.toIso8601String().split('T').first,
    });
  }

  Future<void> respond({
    required String jobPostId,
    required String userId,
    String? message,
  }) async {
    await supabase.from('job_responses').insert({
      'job_post_id': jobPostId,
      'user_id': userId,
      'message': message,
    });
  }
}
