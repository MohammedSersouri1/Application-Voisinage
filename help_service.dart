import '../models/residence.dart';
import '../models/user_profile.dart';
import 'supabase_service.dart';

class ResidenceService {
  Future<Residence> joinByCode({
    required String code,
    String? apartmentNumber,
  }) async {
    final residenceData = await supabase
        .from('residences')
        .select()
        .eq('code', code.trim().toUpperCase())
        .maybeSingle();

    if (residenceData == null) {
      throw Exception('Code résidence introuvable.');
    }

    final residence = Residence.fromMap(residenceData);

    await supabase.from('users').update({
      'residence_id': residence.id,
      'apartment_number': apartmentNumber,
      'residence_status': 'active',
    }).eq('auth_id', supabase.auth.currentUser!.id);

    return residence;
  }

  Future<List<UserProfile>> fetchNeighbors(String residenceId) async {
    final data = await supabase
        .from('users')
        .select()
        .eq('residence_id', residenceId)
        .order('first_name');
    return (data as List<dynamic>)
        .map((e) => UserProfile.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
