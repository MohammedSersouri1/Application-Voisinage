class UserProfile {
  final String id;
  final String authId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? jobTitle;
  final String? bio;
  final List<String> languages;
  final List<String> sports;
  final String? residenceId;
  final String? apartmentNumber;
  final String residenceStatus;

  const UserProfile({
    required this.id,
    required this.authId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.jobTitle,
    this.bio,
    this.languages = const [],
    this.sports = const [],
    this.residenceId,
    this.apartmentNumber,
    this.residenceStatus = 'pending',
  });

  String get fullName => '$firstName $lastName';

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      authId: map['auth_id'] as String,
      firstName: map['first_name'] as String? ?? '',
      lastName: map['last_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      jobTitle: map['job_title'] as String?,
      bio: map['bio'] as String?,
      languages: (map['languages'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      sports: (map['sports'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      residenceId: map['residence_id'] as String?,
      apartmentNumber: map['apartment_number'] as String?,
      residenceStatus: map['residence_status'] as String? ?? 'pending',
    );
  }
}
