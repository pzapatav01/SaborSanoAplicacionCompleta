const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Cliente = sequelize.define('Cliente', {
  idCliente: {
    type: DataTypes.STRING(50),
    primaryKey: true,
    allowNull: false,
    field: 'idCliente'
  },
  nombre: {
    type: DataTypes.STRING(50),
    allowNull: false
  },
  dni: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true
  },
  telefono: {
    type: DataTypes.STRING(13),
    allowNull: false
  },
  email: {
    type: DataTypes.STRING(150),
    allowNull: false,
    unique: true,
    validate: {
      isEmail: true
    }
  },
  direccion: {
    type: DataTypes.STRING(200),
    allowNull: false
  }
}, {
  tableName: 'clientes',
  timestamps: false, // La tabla no tiene createdAt ni updatedAt
  underscored: false
});

module.exports = Cliente;
