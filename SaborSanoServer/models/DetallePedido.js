const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const DetallePedido = sequelize.define('DetallePedido', {
  idDetallePedido: {
    type: DataTypes.STRING(50),
    primaryKey: true,
    allowNull: false,
    field: 'idDetallePedido'
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
  idProducto: {
    type: DataTypes.STRING(50),
    allowNull: false,
    field: 'idProducto',
    references: {
      model: 'productos',
      key: 'idProducto'
    }
  },
  cantidad: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 1
    }
  }
}, {
  tableName: 'DetallePedido',
  timestamps: false, // La tabla no tiene createdAt ni updatedAt
  underscored: false
});

module.exports = DetallePedido;
