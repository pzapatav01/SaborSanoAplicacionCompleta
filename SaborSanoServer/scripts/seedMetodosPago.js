require('dotenv').config();
const { MetodoPago, sequelize } = require('../models');

// Datos de ejemplo para métodos de pago
const metodosPagoData = [
  { idMetodoPago: 'MP001', tipo_pago: 'Efectivo' },
  { idMetodoPago: 'MP002', tipo_pago: 'Tarjeta de Débito' },
  { idMetodoPago: 'MP003', tipo_pago: 'Tarjeta de Crédito' },
  { idMetodoPago: 'MP004', tipo_pago: 'Transferencia Bancaria' },
  { idMetodoPago: 'MP005', tipo_pago: 'Nequi' },
  { idMetodoPago: 'MP006', tipo_pago: 'Daviplata' },
  { idMetodoPago: 'MP007', tipo_pago: 'PayPal' },
  { idMetodoPago: 'MP008', tipo_pago: 'PSE (Pagos Seguros en Línea)' }
];

// Función para insertar datos
const seedMetodosPago = async () => {
  try {
    console.log('🔄 Conectando a la base de datos...');
    await sequelize.authenticate();
    console.log('✅ Conexión establecida correctamente.\n');

    // Insertar métodos de pago
    console.log('💳 Insertando métodos de pago...');
    for (const metodoPago of metodosPagoData) {
      const [metodoCreado, created] = await MetodoPago.findOrCreate({
        where: { idMetodoPago: metodoPago.idMetodoPago },
        defaults: metodoPago
      });
      
      if (created) {
        console.log(`  ✅ Método de pago creado: ${metodoPago.tipo_pago} (${metodoPago.idMetodoPago})`);
      } else {
        console.log(`  ⚠️  Método de pago ya existe: ${metodoPago.tipo_pago} (${metodoPago.idMetodoPago})`);
      }
    }

    console.log('\n✅ Datos insertados correctamente!');
    console.log(`📊 Resumen:`);
    console.log(`   - Métodos de pago: ${metodosPagoData.length}`);

  } catch (error) {
    console.error('❌ Error al insertar datos:', error.message);
    console.error(error);
  } finally {
    await sequelize.close();
    console.log('\n🔌 Conexión cerrada.');
    process.exit(0);
  }
};

// Ejecutar el script
seedMetodosPago();
