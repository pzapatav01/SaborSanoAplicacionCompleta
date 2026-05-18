import 'api_client.dart';
import 'client_session.dart';

class Review {
  const Review({
    required this.id,
    required this.clientName,
    required this.rating,
    required this.comment,
  });

  final String id;
  final String clientName;
  final int rating;
  final String comment;
}

/// Repositorio de reseñas de productos.
class ReviewsRepository {
  ReviewsRepository._();

  static final ApiClient _client = ApiClient();

  static const String _basePath = '/api/resenias';

  /// Reseñas de un producto (GET /api/resenias/producto/:id).
  static Future<List<Review>> getByProduct(String productId) async {
    if (productId.trim().isEmpty) return [];
    final list = await _client.getJsonList('$_basePath/producto/$productId');
    return list
        .where((e) => e is Map<String, dynamic>)
        .map((e) => _fromApi(e as Map<String, dynamic>))
        .toList();
  }

  /// Crea una reseña para un producto (POST /api/resenias).
  /// Requiere sesión de cliente (ClientSession con idCliente).
  static Future<void> createReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    final profile = await ClientSession.get();
    if (profile == null || profile.idCliente.trim().isEmpty) {
      throw Exception('No hay cliente autenticado para crear reseñas');
    }

    await _client.postJson(
      _basePath,
      body: {
        'idCliente': profile.idCliente,
        'idProducto': productId,
        'comentario': comment,
        'calificacion': rating,
      },
    );
  }

  static Review _fromApi(Map<String, dynamic> json) {
    final id = (json['idResenia'] ?? json['id'] ?? '').toString();
    final cliente = json['cliente'] as Map<String, dynamic>?;
    final name = (cliente?['nombre'] ?? 'Cliente').toString();
    final rating = (json['calificacion'] is num)
        ? (json['calificacion'] as num).toInt()
        : 0;
    final comment = (json['comentario'] ?? '').toString();
    return Review(
      id: id,
      clientName: name,
      rating: rating,
      comment: comment,
    );
  }
}

