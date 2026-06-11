import 'package:flutter/material.dart';

import '../services/client_session.dart';

/// Acciones compartidas del bottom navigation (índice 2: Perfil o Login).
class BottomNavActions {
  BottomNavActions._();

  static Future<bool> hasActiveSession() async {
    final profile = await ClientSession.get();
    return profile != null && profile.idCliente.trim().isNotEmpty;
  }

  static Future<void> goToProfileOrLogin(BuildContext context) async {
    final hasSession = await hasActiveSession();
    if (!context.mounted) return;
    if (hasSession) {
      Navigator.of(context).pushNamed('/orders');
    } else {
      Navigator.of(context).pushNamed('/login');
    }
  }
}
