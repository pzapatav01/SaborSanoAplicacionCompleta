import 'api_client.dart';
import 'product_model.dart';

/// Repositorio de productos: encapsula el acceso al backend.
class ProductsRepository {
  ProductsRepository._();

  static final ApiClient _client = ApiClient();

  /// Path base para productos. Ajusta según tus rutas de Express.
  ///
  /// Si en tu servidor tienes algo como:
  ///   app.get('/api/productos', getAllProductos)
  ///   app.get('/api/productos/:id', getProductoById)
  /// entonces cambia esto a `/api/productos`.
  static const String _productsBasePath = '/api/productos';

  /// Obtiene productos del backend, con filtros opcionales.
  ///
  /// - [q]: texto de búsqueda (nombre/descripcion)
  /// - [idCategoria]: id de categoría (según backend)
  ///
  /// Nota: si [q] está vacío o solo espacios, no se envía.
  static Future<List<Product>> getProductos({
    String? q,
    String? idCategoria,
  }) async {
    final trimmedQ = q?.trim();
    final query = <String, dynamic>{};
    if (idCategoria != null && idCategoria.trim().isNotEmpty) {
      query['idCategoria'] = idCategoria.trim();
    }
    if (trimmedQ != null && trimmedQ.isNotEmpty) {
      query['q'] = trimmedQ;
    }

    final list = await _client.getJsonList(
      _productsBasePath,
      query: query.isEmpty ? null : query,
    );
    return list
        .where((e) => e is Map<String, dynamic>)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .where((p) => p.id.isNotEmpty && p.name.isNotEmpty)
        .toList();
  }

  /// Obtiene productos para la Home.
  static Future<List<Product>> getHomeProducts() async {
    return getProductos();
  }

  /// Obtiene productos filtrados por categoría (idCategoria en el backend).
  /// Si [categoryId] es null o 'all', devuelve la misma lista que Home.
  /// En esta app, al seleccionar un chip se usa este método pero
  /// la lógica de servidor se basa en búsqueda por texto (`q`),
  /// por lo que aquí utilizamos ese query en lugar de `idCategoria`.
  static Future<List<Product>> getByCategory(String? categoryId) async {
    if (categoryId == null || categoryId.trim().isEmpty || categoryId == 'all') {
      return getHomeProducts();
    }
    final list = await _client.getJsonList(
      _productsBasePath,
      // Usamos el parámetro de búsqueda `q` del backend para
      // filtrar productos según la categoría seleccionada.
      query: {'q': categoryId},
    );
    return list
        .where((e) => e is Map<String, dynamic>)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .where((p) => p.id.isNotEmpty && p.name.isNotEmpty)
        .toList();
  }

  /// Obtiene un producto único por ID usando `getProductoById`.
  static Future<Product> getProductById(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('id de producto vacío');
    }
    final path = '$_productsBasePath/$id';
    final response = await _client.getJsonMap(path);

    if (response['success'] != true) {
      final message =
          response['message'] as String? ?? 'Producto no encontrado';
      throw Exception(message);
    }

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return Product.fromJson(data);
    }

    throw Exception('Producto no encontrado');
  }
}


