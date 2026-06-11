/**
 * Añade la columna password a clientes si no existe (clientes registrados antes del login).
 * Uso: node scripts/addClientePasswordColumn.js
 */
require('dotenv').config();
const { sequelize } = require('../config/database');

const run = async () => {
  try {
    await sequelize.authenticate();
    const [rows] = await sequelize.query(`
      SELECT COLUMN_NAME
      FROM INFORMATION_SCHEMA.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'clientes'
        AND COLUMN_NAME = 'password'
    `);

    if (rows.length > 0) {
      console.log('✅ La columna password ya existe en clientes.');
      return;
    }

    await sequelize.query(`
      ALTER TABLE clientes
      ADD COLUMN password VARCHAR(255) NULL
      AFTER direccion
    `);
    console.log('✅ Columna password añadida a clientes.');
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exitCode = 1;
  } finally {
    await sequelize.close();
  }
};

run();
