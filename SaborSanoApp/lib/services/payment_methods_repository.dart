import 'api_client.dart';

class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

/// Repositorio de métodos de pago desde /api/metodos-pago.
class PaymentMethodsRepository {
  PaymentMethodsRepository._();

  static final ApiClient _client = ApiClient();

  static const String _path = '/api/metodos-pago';

  static Future<List<PaymentMethod>> getAll() async {
    final list = await _client.getJsonList(_path);
    return list
        .where((e) => e is Map<String, dynamic>)
        .map((e) => _fromApi(e as Map<String, dynamic>))
        .where((m) => m.id.isNotEmpty && m.label.isNotEmpty)
        .toList();
  }

  static PaymentMethod _fromApi(Map<String, dynamic> json) {
    final id = (json['idMetodoPago'] ?? json['id'] ?? '').toString();
    final tipo = (json['tipo_pago'] ?? '').toString();
    return PaymentMethod(id: id, label: tipo);
  }
}

