const Map<String, String> kAnnouncementLabels = {
  'urgent': '🔴 Urgent',
  'maintenance': '🛗 Maintenance',
  'general': 'ℹ️ Général',
};

class Announcement {
  final String id;
  final String residenceId;
  final String authorId;
  final String type; // urgent | maintenance | general
  final String title;
  final String? body;
  final DateTime startsAt;
  final DateTime? endsAt;

  const Announcement({
    required this.id,
    required this.residenceId,
    required this.authorId,
    required this.type,
    required this.title,
    this.body,
    required this.startsAt,
    this.endsAt,
  });

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'] as String,
      residenceId: map['residence_id'] as String,
      authorId: map['author_id'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      body: map['body'] as String?,
      startsAt: DateTime.parse(map['starts_at'] as String),
      endsAt: map['ends_at'] != null
          ? DateTime.parse(map['ends_at'] as String)
          : null,
    );
  }
}
