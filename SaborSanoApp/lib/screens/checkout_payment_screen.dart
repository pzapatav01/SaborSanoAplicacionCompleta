import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../config/stripe_config.dart';
import '../services/payments_repository.dart';
import '../services/saved_card_storage.dart';
import '../theme/app_theme.dart';

/// Pantalla mínima: ingresa tarjeta test y confirma el PaymentIntent.
class CheckoutPaymentScreen extends StatefulWidget {
  const CheckoutPaymentScreen({
    super.key,
    required this.orderId,
    required this.total,
  });

  final String orderId;
  final double total;

  @override
  State<CheckoutPaymentScreen> createState() => _CheckoutPaymentScreenState();
}

class _CheckoutPaymentScreenState extends State<CheckoutPaymentScreen> {
  final _cardController = CardEditController();
  bool _saveCard = false;
  bool _paying = false;
  String? _error;

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!_cardController.details.complete) {
      setState(() => _error = 'Completa los datos de la tarjeta');
      return;
    }

    if (StripeConfig.publishableKey.contains('REEMPLAZA')) {
      setState(() => _error = 'Configura pk_test en lib/config/stripe_config.dart');
      return;
    }

    setState(() {
      _paying = true;
      _error = null;
    });

    try {
      final intent = await PaymentsRepository.createIntent(
        orderId: widget.orderId,
        saveCard: _saveCard,
      );

      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: intent.clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: const BillingDetails(),
          ),
        ),
      );

      if (_saveCard) {
        final last4 = _cardController.details.last4;
        if (last4 != null && last4.isNotEmpty) {
          await SavedCardStorage.save(last4: last4, brand: 'card');
        }
      }

      if (!mounted) return;
      await _showSuccess();
    } on StripeException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.error.localizedMessage ?? e.error.message ?? 'Pago rechazado';
        _paying = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _paying = false;
      });
    }
  }

  Future<void> _showSuccess() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppTheme.accentLime, size: 56),
            const SizedBox(height: 12),
            const Text(
              'Pago enviado',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pedido ${widget.orderId}\n'
              'El estado en tu BD se actualizará cuando actives el webhook.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/orders',
                (route) => route.isFirst,
              );
            },
            child: const Text('Ver mis pedidos'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagar con tarjeta'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Total: \$${widget.total.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pedido: ${widget.orderId}',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            'Tarjeta de prueba: 4242 4242 4242 4242 · 12/34 · 123',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.surfaceLight),
            ),
            child: CardField(
              controller: _cardController,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintStyle: TextStyle(color: AppTheme.textSecondary),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _saveCard,
            onChanged: _paying
                ? null
                : (v) => setState(() => _saveCard = v ?? false),
            title: const Text('Guardar tarjeta en Stripe (opcional)'),
            subtitle: const Text(
              'Permite reutilizar el método de pago en futuros cobros.',
              style: TextStyle(fontSize: 12),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _paying ? null : _pay,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.accentLime,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(_paying ? 'Procesando...' : 'Pagar ahora'),
          ),
        ],
      ),
    );
  }
}
