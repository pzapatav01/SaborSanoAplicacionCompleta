const { sequelize } = require('../config/database');
const { DataTypes } = require('sequelize');

// Importar modelos
const Cliente = require('./Cliente');
const Categoria = require('./Categoria');
const Producto = require('./Producto');
const Resenia = require('./Resenia');
const Pedido = require('./Pedido');
const DetallePedido = require('./DetallePedido');
const Envio = require('./Envio');
const MetodoPago = require('./MetodoPago');

// Definir relaciones entre modelos
// Un Producto pertenece a una Categoria
Producto.belongsTo(Categoria, {
  foreignKey: 'idCategoria',
  targetKey: 'idCategoria',
  as: 'categoria'
});

// Una Categoria tiene muchos Productos
Categoria.hasMany(Producto, {
  foreignKey: 'idCategoria',
  sourceKey: 'idCategoria',
  as: 'productos'
});

// Una Resenia pertenece a un Cliente
Resenia.belongsTo(Cliente, {
  foreignKey: 'idCliente',
  targetKey: 'idCliente',
  as: 'cliente'
});

// Un Cliente tiene muchas Resenias
Cliente.hasMany(Resenia, {
  foreignKey: 'idCliente',
  sourceKey: 'idCliente',
  as: 'resenias'
});

// Una Resenia pertenece a un Producto
Resenia.belongsTo(Producto, {
  foreignKey: 'idProducto',
  targetKey: 'idProducto',
  as: 'producto'
});

// Un Producto tiene muchas Resenias
Producto.hasMany(Resenia, {
  foreignKey: 'idProducto',
  sourceKey: 'idProducto',
  as: 'resenias'
});

// Un Pedido pertenece a un Cliente
Pedido.belongsTo(Cliente, {
  foreignKey: 'idCliente',
  targetKey: 'idCliente',
  as: 'cliente'
});

// Un Cliente tiene muchos Pedidos
Cliente.hasMany(Pedido, {
  foreignKey: 'idCliente',
  sourceKey: 'idCliente',
  as: 'pedidos'
});

// Un DetallePedido pertenece a un Pedido
DetallePedido.belongsTo(Pedido, {
  foreignKey: 'idPedido',
  targetKey: 'idPedido',
  as: 'pedido'
});

// Un Pedido tiene muchos DetallePedidos
Pedido.hasMany(DetallePedido, {
  foreignKey: 'idPedido',
  sourceKey: 'idPedido',
  as: 'detalles'
});

// Un DetallePedido pertenece a un Producto
DetallePedido.belongsTo(Producto, {
  foreignKey: 'idProducto',
  targetKey: 'idProducto',
  as: 'producto'
});

// Un Producto tiene muchos DetallePedidos
Producto.hasMany(DetallePedido, {
  foreignKey: 'idProducto',
  sourceKey: 'idProducto',
  as: 'detallesPedido'
});

// Un Envio pertenece a un Pedido
Envio.belongsTo(Pedido, {
  foreignKey: 'idPedido',
  targetKey: 'idPedido',
  as: 'pedido'
});

// Un Pedido tiene un Envio (relación uno a uno)
Pedido.hasOne(Envio, {
  foreignKey: 'idPedido',
  sourceKey: 'idPedido',
  as: 'envio'
});

// Un Envio pertenece a un MetodoPago
Envio.belongsTo(MetodoPago, {
  foreignKey: 'idMetodo',
  targetKey: 'idMetodoPago',
  as: 'metodoPago'
});

// Un MetodoPago tiene muchos Envios
MetodoPago.hasMany(Envio, {
  foreignKey: 'idMetodo',
  sourceKey: 'idMetodoPago',
  as: 'envios'
});

// Objeto para almacenar todos los modelos
const db = {
  sequelize,
  Sequelize: require('sequelize'),
  Cliente,
  Categoria,
  Producto,
  Resenia,
  Pedido,
  DetallePedido,
  Envio,
  MetodoPago
};

// Sincronizar modelos con la base de datos (solo en desarrollo)
if (process.env.NODE_ENV === 'development') {
  sequelize.sync({ alter: false })
    .then(() => {
      console.log('✅ Modelos sincronizados con la base de datos.');
    })
    .catch((error) => {
      console.error('❌ Error al sincronizar modelos:', error);
    });
}

module.exports = db;
