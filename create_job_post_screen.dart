class Conversation {
  final String id;
  final String residenceId;
  final String userAId;
  final String userBId;

  const Conversation({
    required this.id,
    required this.residenceId,
    required this.userAId,
    required this.userBId,
  });

  String otherUserId(String myId) => userAId == myId ? userBId : userAId;

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] as String,
      residenceId: map['residence_id'] as String,
      userAId: map['user_a_id'] as String,
      userBId: map['user_b_id'] as String,
    );
  }
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String body;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      senderId: map['sender_id'] as String,
      body: map['body'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
