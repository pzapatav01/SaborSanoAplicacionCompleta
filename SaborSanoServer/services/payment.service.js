const Stripe = require('stripe');

let stripeClient;

function getStripe() {
  if (stripeClient) return stripeClient;

  const secretKey = process.env.STRIPE_SECRET_KEY;
  if (!secretKey) {
    const err = new Error('Falta STRIPE_SECRET_KEY en variables de entorno');
    err.status = 500;
    throw err;
  }

  stripeClient = new Stripe(secretKey, {
    apiVersion: '2024-06-20',
  });
  return stripeClient;
}

/**
 * Crea un PaymentIntent y devuelve su client_secret.
 *
 * @param {Object} params
 * @param {number} params.amount - integer (cents)
 * @param {string} params.currency - e.g. "usd"
 * @param {Object} params.metadata - key/value strings
 * @param {string} [params.idempotencyKey]
 */
async function createPaymentIntent({ amount, currency, metadata, idempotencyKey, saveCard }) {
  const stripe = getStripe();

  if (!Number.isInteger(amount) || amount <= 0) {
    const err = new Error('amount debe ser un entero > 0 (en centavos)');
    err.status = 400;
    throw err;
  }
  if (typeof currency !== 'string' || !/^[a-z]{3}$/i.test(currency)) {
    const err = new Error('currency inválida (ISO 4217, ej: "usd")');
    err.status = 400;
    throw err;
  }
  if (metadata == null || typeof metadata !== 'object' || Array.isArray(metadata)) {
    const err = new Error('metadata debe ser un objeto');
    err.status = 400;
    throw err;
  }

  try {
    const intentParams = {
      amount,
      currency: currency.toLowerCase(),
      metadata,
      automatic_payment_methods: {
        enabled: true,
        allow_redirects: 'never',
      },
    };

    if (saveCard === true) {
      intentParams.setup_future_usage = 'off_session';
    }

    const intent = await stripe.paymentIntents.create(
      intentParams,
      idempotencyKey ? { idempotencyKey } : undefined
    );

    if (!intent.client_secret) {
      const err = new Error('Stripe no devolvió client_secret');
      err.status = 502;
      throw err;
    }

    return { clientSecret: intent.client_secret, id: intent.id };
  } catch (error) {
    error.isStripeError = true;
    throw error;
  }
}

module.exports = {
  createPaymentIntent,
  getStripe,
};

