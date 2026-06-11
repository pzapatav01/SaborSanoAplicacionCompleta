import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

/// Modelo ligero del perfil de cliente guardado localmente (sesión).
class ClientProfile {
  const ClientProfile({
    required this.idCliente,
    required this.nombre,
    required this.dni,
    required this.telefono,
    required this.email,
    required this.direccion,
    this.avatar,
  });

  final String idCliente;
  final String nombre;
  final String dni;
  final String telefono;
  final String email;
  final String direccion;

  /// Ruta relativa en servidor, ej: `avatars/avatar-123.jpg`
  final String? avatar;

  /// URL completa: `{host}/public/avatars/archivo.jpg`
  String? get avatarUrl => ApiClient.buildPublicUrl(avatar);

  Map<String, dynamic> toJson() => {
        'idCliente': idCliente,
        'nombre': nombre,
        'dni': dni,
        'telefono': telefono,
        'email': email,
        'direccion': direccion,
        if (avatar != null && avatar!.isNotEmpty) 'avatar': avatar,
      };

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    final avatarRaw = json['avatar'];
    return ClientProfile(
      idCliente: (json['idCliente'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      dni: (json['dni'] ?? '').toString(),
      telefono: (json['telefono'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      direccion: (json['direccion'] ?? '').toString(),
      avatar: avatarRaw == null || avatarRaw.toString().trim().isEmpty
          ? null
          : avatarRaw.toString(),
    );
  }
}

/// Gestión de sesión de cliente usando SharedPreferences.
class ClientSession {
  ClientSession._();

  static const String _key = 'sabor_sano_client_profile';

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  /// Guarda el perfil del cliente (como si fuera una sesión).
  static Future<void> save(ClientProfile profile) async {
    final prefs = await _prefs;
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  /// Recupera el perfil del cliente si existe.
  static Future<ClientProfile?> get() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return ClientProfile.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Elimina la sesión local del cliente.
  static Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_key);
  }
}
