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
  },
  password: {
    type: DataTypes.STRING(255),
    allowNull: true,
    field: 'password'
  },
  avatar: {
    type: DataTypes.STRING(255),
    allowNull: true,
    field: 'avatar',
    comment: 'Ruta relativa bajo /public, ej: avatars/avatar-123.jpg',
  }
}, {
  tableName: 'clientes',
  timestamps: false, // La tabla no tiene createdAt ni updatedAt
  underscored: false,
  defaultScope: {
    attributes: { exclude: ['password'] }
  },
  scopes: {
    withPassword: {
      attributes: { include: ['password'] }
    }
  }
});

module.exports = Cliente;
