import 'package:flutter/material.dart';

import 'screens/root/auth_gate.dart';

class VoisinageApp extends StatelessWidget {
  const VoisinageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voisinage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2E7D32),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
