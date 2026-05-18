import '../services/cart_storage.dart';

/// Modelo de producto que viene del backend Node.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });

  final String id;
  final String name;
  final double price;
  final String? imageUrl;

  /// Precio en formato texto, ej: $12.00
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  /// Crea un [Product] a partir del JSON del backend.
  /// Intenta ser tolerante con distintos nombres de campos.
  factory Product.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ??
            json['_id'] ??
            json['idProducto'] ??
            json['productoId'] ??
            '')
        .toString();
    final name = (json['name'] ?? json['nombre'] ?? json['titulo'] ?? '')
        .toString();

    final rawPrice = json['price'] ?? json['precio'] ?? json['monto'];
    double price;
    if (rawPrice is num) {
      price = rawPrice.toDouble();
    } else if (rawPrice is String) {
      price = double.tryParse(
              rawPrice.replaceAll('\$', '').replaceAll(',', '.').trim()) ??
          0;
    } else {
      price = 0;
    }

    final imageUrl =
        (json['imageUrl'] ?? json['imagen'] ?? json['urlImagen']) as String?;

    return Product(
      id: id,
      name: name,
      price: price,
      imageUrl: imageUrl,
    );
  }

  /// Convierte un producto a [CartItem] para reutilizar en el detalle / carrito.
  CartItem toCartItem({int quantity = 1}) {
    return CartItem(
      id: id,
      name: name,
      price: formattedPrice,
      quantity: quantity,
      imageUrl: imageUrl,
    );
  }
}

