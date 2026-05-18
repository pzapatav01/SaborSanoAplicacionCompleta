const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Resenia = sequelize.define('Resenia', {
  idResenia: {
    type: DataTypes.STRING(50),
    primaryKey: true,
    allowNull: false,
    field: 'idResenia'
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
  idProducto: {
    type: DataTypes.STRING(50),
    allowNull: false,
    field: 'idProducto',
    references: {
      model: 'productos',
      key: 'idProducto'
    }
  },
  comentario: {
    type: DataTypes.STRING(150),
    allowNull: false
  },
  calificacion: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 1,
      max: 5
    }
  }
}, {
  tableName: 'resenia',
  timestamps: false, // La tabla no tiene createdAt ni updatedAt
  underscored: false
});

module.exports = Resenia;
