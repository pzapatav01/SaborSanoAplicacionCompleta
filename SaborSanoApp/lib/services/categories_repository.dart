import 'api_client.dart';

/// Modelo simple de categoría que viene del backend.
class Category {
  const Category({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory Category.fromJson(Map<String, dynamic> json) {
    final id = (json['idCategoria'] ?? json['id'] ?? '').toString();
    final name = (json['nombre'] ?? json['name'] ?? '').toString();
    return Category(id: id, name: name);
  }
}

/// Repositorio de categorías: obtiene la lista desde `/api/categorias`.
class CategoriesRepository {
  CategoriesRepository._();

  static final ApiClient _client = ApiClient();

  static const String _categoriesPath = '/api/categorias';

  static Future<List<Category>> getAll() async {
    final list = await _client.getJsonList(_categoriesPath);
    return list
        .where((e) => e is Map<String, dynamic>)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .where((c) => c.id.isNotEmpty && c.name.isNotEmpty)
        .toList();
  }
}

