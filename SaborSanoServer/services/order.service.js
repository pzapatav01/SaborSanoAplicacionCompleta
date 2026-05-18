const { Pedido, DetallePedido, Producto } = require('../models');

function moneyStringToCents(value) {
  // value puede venir como string DECIMAL de Sequelize, ej: "12.50"
  if (typeof value === 'number' && Number.isFinite(value)) {
    return Math.round(value * 100);
  }
  if (typeof value !== 'string') return null;

  const s = value.trim();
  if (!/^\d+(\.\d{1,2})?$/.test(s)) return null;

  const [whole, fracRaw = ''] = s.split('.');
  const frac = (fracRaw + '00').slice(0, 2);
  return Number(whole) * 100 + Number(frac);
}

async function calculateOrderAmountCents({ orderId, userId }) {
  const pedido = await Pedido.findByPk(orderId, {
    include: [
      {
        model: DetallePedido,
        as: 'detalles',
        include: [{ model: Producto, as: 'producto', attributes: ['precio'] }],
      },
    ],
  });

  if (!pedido) {
    const err = new Error('Pedido no encontrado');
    err.status = 404;
    throw err;
  }

  if (userId && pedido.idCliente !== userId) {
    const err = new Error('No tienes permiso para pagar este pedido');
    err.status = 403;
    throw err;
  }

  const detalles = Array.isArray(pedido.detalles) ? pedido.detalles : [];
  if (detalles.length === 0) {
    const err = new Error('El pedido no tiene detalles para calcular el total');
    err.status = 400;
    throw err;
  }

  let totalCents = 0;
  for (const d of detalles) {
    const qty = Number(d.cantidad);
    const precio = d.producto?.precio;
    const unitCents = moneyStringToCents(precio);

    if (!Number.isInteger(qty) || qty <= 0 || unitCents == null || unitCents < 0) {
      const err = new Error('Detalle de pedido inválido para calcular monto');
      err.status = 400;
      throw err;
    }
    totalCents += unitCents * qty;
  }

  if (!Number.isInteger(totalCents) || totalCents <= 0) {
    const err = new Error('Total del pedido inválido');
    err.status = 400;
    throw err;
  }

  return { amountCents: totalCents, pedido };
}

async function markOrderPaid({ orderId }) {
  const pedido = await Pedido.findByPk(orderId);
  if (!pedido) return false;
  await pedido.update({ estado: 'PAGADO' });
  return true;
}

async function markOrderPaymentFailed({ orderId }) {
  const pedido = await Pedido.findByPk(orderId);
  if (!pedido) return false;
  await pedido.update({ estado: 'PAGO_FALLIDO' });
  return true;
}

module.exports = {
  calculateOrderAmountCents,
  markOrderPaid,
  markOrderPaymentFailed,
};

