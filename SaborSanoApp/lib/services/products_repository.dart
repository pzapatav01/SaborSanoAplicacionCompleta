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

  /// Obtiene productos para la Home.
  static Future<List<Product>> getHomeProducts() async {
    final list = await _client.getJsonList(_productsBasePath);
    return list
        .where((e) => e is Map<String, dynamic>)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .where((p) => p.id.isNotEmpty && p.name.isNotEmpty)
        .toList();
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
    // El controlador devuelve { success: true, data: producto }
    final list = await _client.getJsonList(path);
    // Si por alguna razón la API devolviera una lista, tomamos el primero.
    if (list.isNotEmpty && list.first is Map<String, dynamic>) {
      return Product.fromJson(list.first as Map<String, dynamic>);
    }
    throw Exception('Producto no encontrado');
  }
}


