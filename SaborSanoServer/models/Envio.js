const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Envio = sequelize.define('Envio', {
  idEnvio: {
    type: DataTypes.STRING(50),
    primaryKey: true,
    allowNull: false,
    field: 'idEnvio'
  },
  idPedido: {
    type: DataTypes.STRING(50),
    allowNull: false,
    field: 'idPedido',
    references: {
      model: 'Pedido',
      key: 'idPedido'
    }
  },
  idMetodo: {
    type: DataTypes.STRING(50),
    allowNull: false,
    field: 'idMetodo',
    references: {
      model: 'MetodoPago',
      key: 'idMetodoPago'
    }
  },
  estado: {
    type: DataTypes.STRING(50),
    allowNull: false
  }
}, {
  tableName: 'envio',
  timestamps: false, // La tabla no tiene createdAt ni updatedAt
  underscored: false
});

module.exports = Envio;
