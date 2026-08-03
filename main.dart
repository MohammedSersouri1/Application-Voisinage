import '../models/user_profile.dart';

/// Profil de l'utilisateur connecté, chargé une fois par AuthGate et
/// rafraîchi après toute modification (rejoindre résidence, éditer profil).
/// Suffisant pour un MVP à état simple ; à remplacer par un vrai gestionnaire
/// d'état (Provider/Riverpod) si l'app grossit au-delà du pilote.
class AppSession {
  AppSession._();

  static UserProfile? profile;
}
