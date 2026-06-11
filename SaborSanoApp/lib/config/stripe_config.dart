/// Clave publicable de Stripe (modo test).
/// Cópiala desde Stripe Dashboard → Developers → API keys.
class StripeConfig {
  StripeConfig._();

  /// Debe ser pk_test_... (NUNCA sk_test_..., esa es la secret key del servidor).
  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_REEMPLAZA_CON_TU_CLAVE_PUBLICA',
  );
}
