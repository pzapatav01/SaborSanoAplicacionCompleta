const { getStripe } = require('../services/payment.service');
const { markOrderPaid, markOrderPaymentFailed } = require('../services/order.service');

// POST /api/webhooks/stripe (raw body)
const handleStripeWebhook = async (req, res) => {
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
  if (!webhookSecret) {
    console.error('❌ Falta STRIPE_WEBHOOK_SECRET en variables de entorno');
    return res.status(500).json({ success: false, message: 'Webhook no configurado' });
  }

  const sig = req.headers['stripe-signature'];
  if (!sig) {
    return res.status(400).json({ success: false, message: 'Falta stripe-signature' });
  }

  let event;
  try {
    const stripe = getStripe();
    event = stripe.webhooks.constructEvent(req.body, sig, webhookSecret);
  } catch (err) {
    console.error('❌ Stripe webhook signature error:', err.message);
    return res.status(400).json({ success: false, message: 'Firma inválida' });
  }

  try {
    switch (event.type) {
      case 'payment_intent.succeeded': {
        const intent = event.data.object;
        const orderId = intent?.metadata?.orderId;
        if (!orderId) {
          console.error('⚠️ payment_intent.succeeded sin metadata.orderId', {
            intentId: intent?.id,
            metadata: intent?.metadata,
          });
          break;
        }

        const updated = await markOrderPaid({ orderId });
        console.log('✅ payment_intent.succeeded', {
          eventId: event.id,
          intentId: intent.id,
          orderId,
          updated,
        });
        break;
      }

      case 'payment_intent.payment_failed': {
        const intent = event.data.object;
        const orderId = intent?.metadata?.orderId;
        if (!orderId) {
          console.error('⚠️ payment_intent.payment_failed sin metadata.orderId', {
            intentId: intent?.id,
            metadata: intent?.metadata,
          });
          break;
        }

        const updated = await markOrderPaymentFailed({ orderId });
        console.log('⚠️ payment_intent.payment_failed', {
          eventId: event.id,
          intentId: intent.id,
          orderId,
          updated,
        });
        break;
      }

      default:
        // Ignorar eventos no usados, pero responder 200 para que Stripe no reintente.
        break;
    }

    return res.json({ received: true });
  } catch (error) {
    console.error('❌ Error procesando webhook Stripe:', error);
    // 500 hace que Stripe reintente (correcto si hubo fallo interno).
    return res.status(500).json({ success: false, message: 'Webhook processing failed' });
  }
};

module.exports = {
  handleStripeWebhook,
};

