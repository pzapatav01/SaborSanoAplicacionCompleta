import 'api_client.dart';
import 'client_session.dart';

/// Repositorio para operaciones relacionadas con clientes.
class ClientsRepository {
  ClientsRepository._();

  static final ApiClient _client = ApiClient();

  static const String _clientsPath = '/api/clientes';

  /// Inicia sesión con email y contraseña (POST /api/clientes/login).
  /// Guarda el perfil en sesión local igual que el registro.
  static Future<ClientProfile> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.postJson(
      '$_clientsPath/login',
      body: {
        'email': email.trim(),
        'password': password,
      },
    );

    if (response['success'] != true || response['data'] == null) {
      final message =
          response['message'] as String? ?? 'No se pudo iniciar sesión.';
      throw Exception(message);
    }

    final profile =
        ClientProfile.fromJson(response['data'] as Map<String, dynamic>);
    await ClientSession.save(profile);
    return profile;
  }

  /// Registra un nuevo cliente usando el endpoint POST /api/clientes.
  /// Devuelve el perfil guardado localmente.
  static Future<ClientProfile> register({
    required String nombre,
    required String dni,
    required String telefono,
    required String email,
    required String direccion,
    required String password,
    String? avatarPath,
  }) async {
    final fields = {
      'nombre': nombre,
      'dni': dni,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'password': password,
    };

    final Map<String, dynamic> response;
    if (avatarPath != null && avatarPath.trim().isNotEmpty) {
      response = await _client.postMultipart(
        _clientsPath,
        fields: fields,
        filePath: avatarPath,
      );
    } else {
      response = await _client.postJson(_clientsPath, body: fields);
    }

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
        _myProfilePath,
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

  static const String _myProfilePath = '/api/clientes/mi-perfil';

  /// Actualiza el perfil del cliente autenticado (PUT /api/clientes/mi-perfil).
  static Future<ClientProfile> updateProfile({
    required String nombre,
    required String dni,
    required String telefono,
    required String email,
    required String direccion,
  }) async {
    final local = await ClientSession.get();
    if (local == null || local.idCliente.trim().isEmpty) {
      throw Exception('No hay cliente autenticado');
    }

    final body = {
      'nombre': nombre,
      'dni': dni,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
    };
    final headers = {'X-Client-ID': local.idCliente};

    Map<String, dynamic> response;
    try {
      response = await _client.putJson(
        _myProfilePath,
        body: body,
        headers: headers,
      );
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('404') || msg.toLowerCase().contains('no encontrada')) {
        response = await _client.patchJson(
          _myProfilePath,
          body: body,
          headers: headers,
        );
      } else {
        rethrow;
      }
    }

    if (response['success'] != true || response['data'] == null) {
      final message =
          response['message'] as String? ?? 'No se pudo actualizar el perfil.';
      throw Exception(message);
    }

    final profile =
        ClientProfile.fromJson(response['data'] as Map<String, dynamic>);
    await ClientSession.save(profile);
    return profile;
  }
}

