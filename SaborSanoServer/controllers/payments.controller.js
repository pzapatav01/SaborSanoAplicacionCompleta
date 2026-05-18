const { createPaymentIntent } = require('../services/payment.service');
const { calculateOrderAmountCents } = require('../services/order.service');

function getIdempotencyKey(req, orderId) {
  const header =
    req.headers['idempotency-key'] ||
    req.headers['Idempotency-Key'] ||
    req.headers['x-idempotency-key'] ||
    req.headers['X-Idempotency-Key'];

  if (typeof header === 'string' && header.trim()) return header.trim().slice(0, 255);
  return `order:${orderId}`.slice(0, 255);
}

// POST /api/payments/create-intent
const createIntent = async (req, res, next) => {
  try {
    const { amount, currency, orderId, userId, saveCard } = req.body || {};

    if (!orderId || typeof orderId !== 'string' || !orderId.trim()) {
      return res.status(400).json({
        success: false,
        message: 'orderId es requerido',
      });
    }

    // Si viene autenticado por X-Client-ID, usamos eso como fuente de verdad.
    const authUserId = req.clientId;
    const effectiveUserId = authUserId || userId;

    if (!effectiveUserId || typeof effectiveUserId !== 'string' || !effectiveUserId.trim()) {
      return res.status(400).json({
        success: false,
        message: 'userId es requerido',
      });
    }

    if (authUserId && userId && authUserId !== userId) {
      return res.status(400).json({
        success: false,
        message: 'userId no coincide con el usuario autenticado',
      });
    }

    if (!currency || typeof currency !== 'string' || !/^[a-z]{3}$/i.test(currency)) {
      return res.status(400).json({
        success: false,
        message: 'currency inválida (ISO 4217, ej: "usd")',
      });
    }

    // amount viene del frontend pero NO se confía: recalculamos.
    // Igual validamos si lo mandaron para ayudar a detectar errores.
    if (amount != null && (!Number.isInteger(amount) || amount <= 0)) {
      return res.status(400).json({
        success: false,
        message: 'amount debe ser entero > 0 (en centavos) si se envía',
      });
    }

    // Lo convertimos a centavos para Stripe.
    const { amountCents } = await calculateOrderAmountCents({
      orderId: orderId.trim(),
      userId: effectiveUserId.trim(),
    });

    // Informacion adiional para stripe.
    const metadata = {
      userId: effectiveUserId.trim(),
      orderId: orderId.trim(),
      environment: process.env.NODE_ENV || 'development',
      appName: 'server-paloma',
    };

    const idempotencyKey = getIdempotencyKey(req, orderId.trim());

    const { clientSecret, id: paymentIntentId } = await createPaymentIntent({
      amount: amountCents,
      currency,
      metadata,
      idempotencyKey,
      saveCard: saveCard === true,
    });

    return res.json({
      success: true,
      paymentIntentId,
      clientSecret,
    });
  } catch (error) {
    if (error?.isStripeError) {
      console.error('❌ Stripe error (create intent):', {
        message: error.message,
        type: error.type,
        code: error.code,
        statusCode: error.statusCode,
      });
    }
    next(error);
  }
};

module.exports = {
  createIntent,
};
