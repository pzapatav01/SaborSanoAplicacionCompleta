/**
 * Añade la columna avatar a clientes si no existe.
 * Uso: node scripts/addClienteAvatarColumn.js
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
        AND COLUMN_NAME = 'avatar'
    `);

    if (rows.length > 0) {
      console.log('✅ La columna avatar ya existe en clientes.');
      return;
    }

    await sequelize.query(`
      ALTER TABLE clientes
      ADD COLUMN avatar VARCHAR(255) NULL
      AFTER password
    `);
    console.log('✅ Columna avatar añadida a clientes.');
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exitCode = 1;
  } finally {
    await sequelize.close();
  }
};

run();
