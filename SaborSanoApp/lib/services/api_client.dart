import 'dart:convert';

import 'package:http/http.dart' as http;

/// Cliente HTTP reutilizable para hablar con el backend Node.
class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
  })  : _http = httpClient ?? http.Client(),
        baseUrl = baseUrl ?? defaultBaseUrl;

  final http.Client _http;

  /// URL base del servidor.
  ///
  /// - En emulador Android suele ser `http://10.0.2.2:3000`.
  /// - En dispositivo físico usa la IP de tu PC en la red local.
  static const String defaultBaseUrl = 'http://10.0.2.2:3000';

  final String baseUrl;

  Uri _buildUri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('$baseUrl$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...query.map((k, v) => MapEntry(k, v.toString())),
      },
    );
  }

  /// Realiza un GET que devuelve una lista JSON.
  Future<List<dynamic>> getJsonList(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, query);
    final response = await _http.get(uri, headers: headers);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'GET $path falló (${response.statusCode}): ${response.body}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic> && decoded['data'] is List) {
      return decoded['data'] as List;
    }
    throw Exception('Respuesta inesperada para $path (se esperaba una lista)');
  }

  /// Realiza un GET que devuelve un mapa JSON.
  Future<Map<String, dynamic>> getJsonMap(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, query);
    final response = await _http.get(uri, headers: headers);

    final text = utf8.decode(response.bodyBytes);
    if (text.isEmpty) {
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('GET $path falló (${response.statusCode})');
      }
      return <String, dynamic>{};
    }

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      throw Exception(
          'GET $path devolvió una respuesta no válida (${response.statusCode}): $text');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          decoded['message'] as String? ?? 'Error al llamar a $path';
      throw Exception(message);
    }

    return decoded;
  }

  /// Realiza un POST con JSON y devuelve un mapa JSON.
  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    final response = await _http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body ?? <String, dynamic>{}),
    );

    final text = utf8.decode(response.bodyBytes);
    Map<String, dynamic> decoded;
    try {
      decoded = text.isNotEmpty
          ? (jsonDecode(text) as Map<String, dynamic>)
          : <String, dynamic>{};
    } catch (_) {
      throw Exception(
          'POST $path devolvió una respuesta no válida (${response.statusCode}): $text');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          decoded['message'] as String? ?? 'Error al llamar a $path';
      throw Exception(message);
    }

    return decoded;
  }
}

