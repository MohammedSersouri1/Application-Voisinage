import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/user_profile.dart';
import '../../services/app_session.dart';
import '../../services/auth_service.dart';
import '../auth/sign_in_screen.dart';
import '../home/main_nav_screen.dart';
import '../onboarding/join_residence_screen.dart';

/// Décide de l'écran à afficher : connexion, rejoindre sa résidence, ou
/// l'application principale. Se reconstruit automatiquement à chaque
/// changement d'état d'authentification Supabase (connexion/déconnexion).
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authService.onAuthStateChange,
      builder: (context, snapshot) {
        final session = _authService.currentSession;
        if (session == null) {
          return const SignInScreen();
        }
        return FutureBuilder<UserProfile?>(
          future: _authService.fetchCurrentProfile(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState != ConnectionState.done) {
              return const _LoadingScreen();
            }
            final profile = profileSnapshot.data;
            if (profile == null) {
              return const _LoadingScreen();
            }
            AppSession.profile = profile;
            if (profile.residenceId == null) {
              return const JoinResidenceScreen();
            }
            return const MainNavScreen();
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
