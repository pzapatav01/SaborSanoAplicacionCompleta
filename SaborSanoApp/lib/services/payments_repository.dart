import 'api_client.dart';
import 'client_session.dart';

class PaymentIntentResult {
  const PaymentIntentResult({
    required this.paymentIntentId,
    required this.clientSecret,
  });

  final String paymentIntentId;
  final String clientSecret;
}

/// Llamadas al backend para Payment Intents (Stripe).
class PaymentsRepository {
  PaymentsRepository._();

  static final ApiClient _client = ApiClient();
  static const String _createIntentPath = '/api/payments/create-intent';

  static Future<PaymentIntentResult> createIntent({
    required String orderId,
    String currency = 'usd',
    bool saveCard = false,
  }) async {
    final profile = await ClientSession.get();
    if (profile == null || profile.idCliente.trim().isEmpty) {
      throw Exception('Debes iniciar sesión como cliente');
    }

    final response = await _client.postJson(
      _createIntentPath,
      body: {
        'orderId': orderId,
        'userId': profile.idCliente,
        'currency': currency,
        'saveCard': saveCard,
      },
      headers: {'X-Client-ID': profile.idCliente},
    );

    if (response['success'] != true) {
      final message =
          response['message'] as String? ?? 'No se pudo crear el pago';
      throw Exception(message);
    }

    final clientSecret = response['clientSecret'] as String?;
    final paymentIntentId = response['paymentIntentId'] as String?;

    if (clientSecret == null ||
        clientSecret.isEmpty ||
        paymentIntentId == null ||
        paymentIntentId.isEmpty) {
      throw Exception('Respuesta de pago incompleta');
    }

    return PaymentIntentResult(
      paymentIntentId: paymentIntentId,
      clientSecret: clientSecret,
    );
  }
}
