const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Categoria = sequelize.define('Categoria', {
  idCategoria: {
    type: DataTypes.STRING(50),
    primaryKey: true,
    allowNull: false,
    field: 'idCategoria'
  },
  nombre: {
    type: DataTypes.STRING(50),
    allowNull: false
  }
}, {
  tableName: 'categoria',
  timestamps: false, // La tabla no tiene createdAt ni updatedAt
  underscored: false
});

module.exports = Categoria;
