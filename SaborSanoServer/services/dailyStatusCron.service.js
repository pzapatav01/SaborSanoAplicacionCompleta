const cron = require('node-cron');
const { Pedido, Envio, sequelize } = require('../models');

const PEDIDO_ESTADO_ORIGEN = 'EN PREPARACIÓN';
const PEDIDO_ESTADO_DESTINO = 'FINALIZADO';
const ENVIO_ESTADO_ORIGEN = 'EN TRÁNSITO';
const ENVIO_ESTADO_DESTINO = 'ENTREGADO';

/**
 * Actualiza estados masivos:
 * - Pedidos: EN PREPARACIÓN → FINALIZADO
 * - Envíos: EN TRÁNSITO → ENTREGADO
 */
async function runDailyStatusUpdate() {
  const transaction = await sequelize.transaction();

  try {
    const [pedidosUpdated] = await Pedido.update(
      { estado: PEDIDO_ESTADO_DESTINO },
      { where: { estado: PEDIDO_ESTADO_ORIGEN }, transaction }
    );

    const [enviosUpdated] = await Envio.update(
      { estado: ENVIO_ESTADO_DESTINO },
      { where: { estado: ENVIO_ESTADO_ORIGEN }, transaction }
    );

    await transaction.commit();

    console.log(
      `✅ Cron diario: ${pedidosUpdated} pedido(s) → ${PEDIDO_ESTADO_DESTINO}, ` +
        `${enviosUpdated} envío(s) → ${ENVIO_ESTADO_DESTINO}`
    );

    return { pedidosUpdated, enviosUpdated };
  } catch (error) {
    await transaction.rollback();
    console.error('❌ Cron diario: error al actualizar estados', error);
    throw error;
  }
}

/**
 * Programa el cron todos los días a la 1:00 AM.
 * Zona horaria: CRON_TIMEZONE (por defecto Europe/Madrid).
 */
function startDailyStatusCron() {
  const timezone = process.env.CRON_TIMEZONE || 'Europe/Madrid';
  const enabled = process.env.ENABLE_DAILY_STATUS_CRON !== 'false';

  if (!enabled) {
    console.log('📅 Cron diario de estados desactivado (ENABLE_DAILY_STATUS_CRON=false)');
    return null;
  }

  const task = cron.schedule(
    '0 1 * * *',
    async () => {
      console.log(`🕐 Cron diario de estados (${timezone})...`);
      try {
        await runDailyStatusUpdate();
      } catch (_) {
        // Error ya registrado en runDailyStatusUpdate
      }
    },
    { timezone }
  );

  console.log(`📅 Cron programado: 1:00 AM diario (${timezone})`);
  return task;
}

module.exports = {
  runDailyStatusUpdate,
  startDailyStatusCron,
};
