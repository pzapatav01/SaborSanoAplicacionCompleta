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
  /// - En dispositivo f?sico usa la IP de tu PC en la red local.
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
          'GET $path fall? (${response.statusCode}): ${response.body}');
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
        throw Exception('GET $path fall? (${response.statusCode})');
      }
      return <String, dynamic>{};
    }

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      throw Exception(
          'GET $path devolvi? una respuesta no v?lida (${response.statusCode}): $text');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          decoded['message'] as String? ?? 'Error al llamar a $path';
      throw Exception(message);
    }

    return decoded;
  }

  /// Construye URL p?blica para un archivo bajo `/public`.
  /// [relativePath] en BD suele ser `avatars/nombre.jpg`.
  static String? buildPublicUrl(String? relativePath) {
    if (relativePath == null || relativePath.trim().isEmpty) return null;
    var path = relativePath.trim().replaceAll('\\', '/');
    if (path.startsWith('/')) path = path.substring(1);
    if (path.startsWith('public/')) {
      return '$defaultBaseUrl/$path';
    }
    return '$defaultBaseUrl/public/$path';
  }

  /// POST multipart/form-data (registro con avatar opcional).
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    String fileField = 'avatar',
    String? filePath,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    final request = http.MultipartRequest('POST', uri);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    request.fields.addAll(fields);
    if (filePath != null && filePath.trim().isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(fileField, filePath),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final text = utf8.decode(response.bodyBytes);

    Map<String, dynamic> decoded;
    try {
      decoded = text.isNotEmpty
          ? (jsonDecode(text) as Map<String, dynamic>)
          : <String, dynamic>{};
    } catch (_) {
      throw Exception(
          'POST multipart $path devolvi? respuesta no v?lida (${response.statusCode}): $text');
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
          'POST $path devolvi? una respuesta no v?lida (${response.statusCode}): $text');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          decoded['message'] as String? ?? 'Error al llamar a $path';
      throw Exception(message);
    }

    return decoded;
  }

  /// Realiza un PUT con JSON y devuelve un mapa JSON.
  Future<Map<String, dynamic>> putJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    final response = await _http.put(
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
          'PUT $path devolvi? una respuesta no v?lida (${response.statusCode}): $text');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded['message'] as String? ??
          'PUT $path fall? (${response.statusCode})';
      throw Exception(message);
    }

    return decoded;
  }

  /// Realiza un PATCH con JSON y devuelve un mapa JSON.
  Future<Map<String, dynamic>> patchJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    final response = await _http.patch(
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
          'PATCH $path devolvi? una respuesta no v?lida (${response.statusCode}): $text');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded['message'] as String? ??
          'PATCH $path fall? (${response.statusCode})';
      throw Exception(message);
    }

    return decoded;
  }
}

