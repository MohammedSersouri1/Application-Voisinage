const Map<String, String> kHelpCategories = {
  'service_ponctuel': '📦 Service ponctuel',
  'bon_plan': '🔧 Bon plan / recommandation',
  'garde': '🐶 Garde (enfants, animaux)',
  'bricolage': '🛠️ Bricolage',
  'autre': '🙂 Autre',
};

class HelpRequest {
  final String id;
  final String residenceId;
  final String creatorId;
  final String direction; // demande | proposition
  final String category;
  final String title;
  final String? description;
  final DateTime? neededAt;
  final String status;

  const HelpRequest({
    required this.id,
    required this.residenceId,
    required this.creatorId,
    required this.direction,
    required this.category,
    required this.title,
    this.description,
    this.neededAt,
    required this.status,
  });

  factory HelpRequest.fromMap(Map<String, dynamic> map) {
    return HelpRequest(
      id: map['id'] as String,
      residenceId: map['residence_id'] as String,
      creatorId: map['creator_id'] as String,
      direction: map['direction'] as String,
      category: map['category'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      neededAt: map['needed_at'] != null
          ? DateTime.parse(map['needed_at'] as String)
          : null,
      status: map['status'] as String,
    );
  }
}
