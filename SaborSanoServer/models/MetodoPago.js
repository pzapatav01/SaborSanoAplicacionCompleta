const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const MetodoPago = sequelize.define('MetodoPago', {
  idMetodoPago: {
    type: DataTypes.STRING(50),
    primaryKey: true,
    allowNull: false,
    field: 'idMetodoPago'
  },
  tipo_pago: {
    type: DataTypes.STRING(100),
    allowNull: false,
    field: 'tipo_pago'
  }
}, {
  tableName: 'MetodoPago',
  timestamps: false, // La tabla no tiene createdAt ni updatedAt
  underscored: false
});

module.exports = MetodoPago;
