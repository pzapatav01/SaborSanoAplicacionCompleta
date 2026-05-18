import 'api_client.dart';
import 'client_session.dart';

/// Repositorio para operaciones relacionadas con clientes.
class ClientsRepository {
  ClientsRepository._();

  static final ApiClient _client = ApiClient();

  static const String _clientsPath = '/api/clientes';

  /// Registra un nuevo cliente usando el endpoint POST /api/clientes.
  /// Devuelve el perfil guardado localmente.
  static Future<ClientProfile> register({
    required String nombre,
    required String dni,
    required String telefono,
    required String email,
    required String direccion,
  }) async {
    final response = await _client.postJson(
      _clientsPath,
      body: {
        'nombre': nombre,
        'dni': dni,
        'telefono': telefono,
        'email': email,
        'direccion': direccion,
      },
    );

    if (response['success'] != true || response['data'] == null) {
      final message =
          response['message'] as String? ?? 'No se pudo registrar el cliente.';
      throw Exception(message);
    }

    final data = response['data'] as Map<String, dynamic>;
    final profile = ClientProfile.fromJson(data);
    await ClientSession.save(profile);
    return profile;
  }

  /// Obtiene el perfil del cliente desde el endpoint protegido /api/clientes/mi-perfil.
  /// Usa el header X-Client-ID con el idCliente guardado en sesión.
  static Future<ClientProfile?> fetchMyProfile() async {
    final local = await ClientSession.get();
    if (local == null || local.idCliente.trim().isEmpty) {
      return null;
    }

    try {
      final response = await _client.getJsonMap(
        '$_clientsPath/mi-perfil',
        headers: {'X-Client-ID': local.idCliente},
      );
      if (response['success'] == true && response['data'] is Map) {
        final data = response['data'] as Map<String, dynamic>;
        final profile = ClientProfile.fromJson(data);
        await ClientSession.save(profile);
        return profile;
      }
      return local;
    } catch (_) {
      // Si falla la API, devolvemos el perfil local.
      return local;
    }
  }
}

