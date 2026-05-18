const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Producto = sequelize.define('Producto', {
  idProducto: {
    type: DataTypes.STRING(50),
    primaryKey: true,
    allowNull: false,
    field: 'idProducto'
  },
  nombre: {
    type: DataTypes.STRING(60),
    allowNull: false
  },
  precio: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
    validate: {
      min: 0
    }
  },
  idCategoria: {
    type: DataTypes.STRING(50),
    allowNull: false,
    field: 'idCategoria',
    references: {
      model: 'categoria',
      key: 'idCategoria'
    }
  },
  descripcion: {
    type: DataTypes.STRING(200),
    allowNull: false
  },
  imageUrl: {
    type: DataTypes.STRING(255),
    allowNull: true,
    field: 'imageUrl'
  },
  stock: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 0
    }
  }
}, {
  tableName: 'productos',
  timestamps: false, // La tabla no tiene createdAt ni updatedAt
  underscored: false
});

module.exports = Producto;
