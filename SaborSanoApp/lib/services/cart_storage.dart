import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Modelo de ítem del carrito. Persistido localmente.
class CartItem {
  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String price;
  final int quantity;
  final String? imageUrl;

  CartItem copyWith({
    String? id,
    String? name,
    String? price,
    int? quantity,
    String? imageUrl,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
        'imageUrl': imageUrl,
      };

  static CartItem fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: json['price'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

/// Persistencia local del carrito con SharedPreferences.
/// Validación: id/name/price no vacíos, quantity >= 1.
class CartStorage {
  CartStorage._();

  static const String _key = 'sabor_sano_cart';

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  /// Devuelve todos los ítems del carrito (vacíos si no hay datos).
  static Future<List<CartItem>> getCart() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>?;
      if (list == null) return [];
      return list
          .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .where((e) => e.id.isNotEmpty && e.name.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Guarda la lista completa (reemplaza). No exponer si no hace falta.
  static Future<void> _save(List<CartItem> items) async {
    final prefs = await _prefs;
    final valid = items
        .where((e) =>
            e.id.trim().isNotEmpty &&
            e.name.trim().isNotEmpty &&
            e.quantity > 0)
        .toList();
    await prefs.setString(
      _key,
      jsonEncode(valid.map((e) => e.toJson()).toList()),
    );
  }

  /// Añade un ítem o suma cantidad si ya existe el mismo id.
  static Future<void> addItem(CartItem item) async {
    if (item.id.trim().isEmpty || item.name.trim().isEmpty) return;
    final qty = item.quantity < 1 ? 1 : item.quantity;
    final normalized = item.copyWith(quantity: qty);
    final list = await getCart();
    final idx = list.indexWhere((e) => e.id == normalized.id);
    final updated = List<CartItem>.from(list);
    if (idx >= 0) {
      updated[idx] = updated[idx].copyWith(
        quantity: updated[idx].quantity + normalized.quantity,
      );
    } else {
      updated.add(normalized);
    }
    await _save(updated);
  }

  /// Elimina un ítem por id.
  static Future<void> removeItem(String id) async {
    if (id.trim().isEmpty) return;
    final list = await getCart();
    await _save(list.where((e) => e.id != id).toList());
  }

  /// Limpia todo el carrito.
  static Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_key);
  }
}
