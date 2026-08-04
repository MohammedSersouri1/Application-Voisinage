const List<String> kSportTypes = [
  'foot',
  'padel',
  'tennis',
  'running',
  'petanque',
  'randonnee',
  'salle_de_sport',
  'jeux_de_societe',
  'autre',
];

const Map<String, String> kSportLabels = {
  'foot': '⚽ Foot',
  'padel': '🎾 Padel',
  'tennis': '🎾 Tennis',
  'running': '🏃 Running',
  'petanque': '🎳 Pétanque',
  'randonnee': '🥾 Randonnée',
  'salle_de_sport': '🏋️ Salle de sport',
  'jeux_de_societe': '🎲 Jeux de société',
  'autre': '🙂 Autre',
};

class Activity {
  final String id;
  final String residenceId;
  final String creatorId;
  final String sportType;
  final String title;
  final String? description;
  final String? location;
  final DateTime startsAt;
  final int maxParticipants;
  final String status;
  final int participantsCount;
  final bool isJoined;

  const Activity({
    required this.id,
    required this.residenceId,
    required this.creatorId,
    required this.sportType,
    required this.title,
    this.description,
    this.location,
    required this.startsAt,
    required this.maxParticipants,
    required this.status,
    this.participantsCount = 0,
    this.isJoined = false,
  });

  bool get isFull => participantsCount >= maxParticipants;

  bool isOwnedBy(String userId) => creatorId == userId;

  factory Activity.fromMap(Map<String, dynamic> map, {String? currentUserId}) {
    final participants =
        (map['activity_participants'] as List<dynamic>? ?? const []);
    return Activity(
      id: map['id'] as String,
      residenceId: map['residence_id'] as String,
      creatorId: map['creator_id'] as String,
      sportType: map['sport_type'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      location: map['location'] as String?,
      startsAt: DateTime.parse(map['starts_at'] as String),
      maxParticipants: map['max_participants'] as int,
      status: map['status'] as String,
      participantsCount: participants.length,
      isJoined: currentUserId != null &&
          participants.any((p) => (p as Map)['user_id'] == currentUserId),
    );
  }
}
