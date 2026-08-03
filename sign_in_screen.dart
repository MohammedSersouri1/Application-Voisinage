class Residence {
  final String id;
  final String name;
  final String code;
  final String? address;
  final String? city;

  const Residence({
    required this.id,
    required this.name,
    required this.code,
    this.address,
    this.city,
  });

  factory Residence.fromMap(Map<String, dynamic> map) {
    return Residence(
      id: map['id'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
      address: map['address'] as String?,
      city: map['city'] as String?,
    );
  }
}
