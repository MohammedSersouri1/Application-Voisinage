const Map<String, String> kJobCategories = {
  'stage': 'Stage',
  'alternance': 'Alternance',
  'cdi': 'CDI',
  'freelance': 'Freelance',
  'conseil': 'Conseil',
  'recommandation': 'Recommandation',
};

class JobPost {
  final String id;
  final String residenceId;
  final String creatorId;
  final String direction; // propose | recherche
  final String category;
  final String title;
  final String? description;
  final DateTime? availableFrom;
  final String status;

  const JobPost({
    required this.id,
    required this.residenceId,
    required this.creatorId,
    required this.direction,
    required this.category,
    required this.title,
    this.description,
    this.availableFrom,
    required this.status,
  });

  factory JobPost.fromMap(Map<String, dynamic> map) {
    return JobPost(
      id: map['id'] as String,
      residenceId: map['residence_id'] as String,
      creatorId: map['creator_id'] as String,
      direction: map['direction'] as String,
      category: map['category'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      availableFrom: map['available_from'] != null
          ? DateTime.parse(map['available_from'] as String)
          : null,
      status: map['status'] as String,
    );
  }
}
