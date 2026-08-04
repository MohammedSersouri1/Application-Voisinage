import '../models/help_request.dart';
import 'supabase_service.dart';

class HelpService {
  Future<List<HelpRequest>> fetchOpenRequests(String residenceId) async {
    final data = await supabase
        .from('help_requests')
        .select()
        .eq('residence_id', residenceId)
        .inFilter('status', ['open', 'in_progress'])
        .order('created_at', ascending: false);
    return (data as List<dynamic>)
        .map((e) => HelpRequest.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> create({
    required String residenceId,
    required String creatorId,
    required String direction,
    required String category,
    required String title,
    String? description,
    DateTime? neededAt,
  }) async {
    await supabase.from('help_requests').insert({
      'residence_id': residenceId,
      'creator_id': creatorId,
      'direction': direction,
      'category': category,
      'title': title,
      'description': description,
      'needed_at': neededAt?.toIso8601String(),
    });
  }

  Future<void> respond({
    required String helpRequestId,
    required String userId,
    String? message,
  }) async {
    await supabase.from('help_responses').insert({
      'help_request_id': helpRequestId,
      'user_id': userId,
      'message': message,
    });
  }

  Future<void> markResolved(String helpRequestId) async {
    await supabase
        .from('help_requests')
        .update({'status': 'resolved'})
        .eq('id', helpRequestId);
  }
}
