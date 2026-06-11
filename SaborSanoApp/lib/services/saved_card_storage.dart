import 'package:shared_preferences/shared_preferences.dart';

/// Referencia local de la última tarjeta guardada (demo).
/// Stripe guarda el método de pago cuando `saveCard` está activo en el intent.
class SavedCardStorage {
  SavedCardStorage._();

  static const _keyLast4 = 'stripe_saved_card_last4';
  static const _keyBrand = 'stripe_saved_card_brand';

  static Future<void> save({required String last4, String? brand}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLast4, last4);
    if (brand != null && brand.isNotEmpty) {
      await prefs.setString(_keyBrand, brand);
    }
  }

  static Future<({String last4, String? brand})?> get() async {
    final prefs = await SharedPreferences.getInstance();
    final last4 = prefs.getString(_keyLast4);
    if (last4 == null || last4.isEmpty) return null;
    return (last4: last4, brand: prefs.getString(_keyBrand));
  }
}
