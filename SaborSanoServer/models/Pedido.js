const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Pedido = sequelize.define('Pedido', {
  idPedido: {
    type: DataTypes.STRING(50),
    primaryKey: true,
    allowNull: false,
    field: 'idPedido'
  },
  idCliente: {
    type: DataTypes.STRING(50),
    allowNull: false,
    field: 'idCliente',
    references: {
      model: 'clientes',
      key: 'idCliente'
    }
  },
  estado: {
    type: DataTypes.STRING(50),
    allowNull: false
  },
  fecha_pedido: {
    type: DataTypes.DATEONLY,
    allowNull: false,
    field: 'fecha_pedido'
  }
}, {
  tableName: 'Pedido',
  timestamps: false, // La tabla no tiene createdAt ni updatedAt
  underscored: false
});

module.exports = Pedido;
