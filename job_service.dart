import '../models/message.dart';
import '../models/user_profile.dart';
import 'supabase_service.dart';

class MessagingService {
  /// Retourne la conversation existante entre les deux utilisateurs dans
  /// cette résidence, ou en crée une nouvelle. `conversations` n'a pas
  /// d'ordre canonique (user_a/user_b), on vérifie donc les deux sens avant
  /// de créer pour éviter les doublons.
  Future<Conversation> getOrCreateConversation({
    required String residenceId,
    required String myUserId,
    required String otherUserId,
  }) async {
    final existing = await supabase
        .from('conversations')
        .select()
        .eq('residence_id', residenceId)
        .or(
          'and(user_a_id.eq.$myUserId,user_b_id.eq.$otherUserId),'
          'and(user_a_id.eq.$otherUserId,user_b_id.eq.$myUserId)',
        )
        .maybeSingle();

    if (existing != null) {
      return Conversation.fromMap(existing);
    }

    final created = await supabase
        .from('conversations')
        .insert({
          'residence_id': residenceId,
          'user_a_id': myUserId,
          'user_b_id': otherUserId,
        })
        .select()
        .single();

    return Conversation.fromMap(created);
  }

  Future<List<Conversation>> fetchMyConversations(String myUserId) async {
    final data = await supabase
        .from('conversations')
        .select()
        .or('user_a_id.eq.$myUserId,user_b_id.eq.$myUserId')
        .order('created_at', ascending: false);
    return (data as List<dynamic>)
        .map((e) => Conversation.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    final data = await supabase
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at');
    return (data as List<dynamic>)
        .map((e) => ChatMessage.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String body,
  }) async {
    await supabase.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': senderId,
      'body': body,
    });
  }

  /// Pour afficher le nom du contact dans la liste des conversations, sans
  /// requête dédiée par conversation : on récupère tous les voisins une
  /// fois et on cherche localement.
  UserProfile? findNeighbor(List<UserProfile> neighbors, String userId) {
    for (final n in neighbors) {
      if (n.id == userId) return n;
    }
    return null;
  }
}
