const { Op } = require('sequelize');
const { Producto, Categoria } = require('../models');

// Obtener todos los productos (opcionalmente filtrados por idCategoria y búsqueda por texto)
const getAllProductos = async (req, res, next) => {
  try {
    const { idCategoria, q } = req.query;

    const where = {};
    if (idCategoria) {
      where.idCategoria = idCategoria;
    }

    if (q && q.trim()) {
      const term = `%${q.trim()}%`;
      where[Op.or] = [
        { nombre: { [Op.like]: term } },
        { descripcion: { [Op.like]: term } },
      ];
    }

    const productos = await Producto.findAll({
      where,
      include: [{
        model: Categoria,
        as: 'categoria',
        attributes: ['idCategoria', 'nombre']
      }],
      order: [['nombre', 'ASC']]
    });

    res.json({
      success: true,
      count: productos.length,
      data: productos
    });
  } catch (error) {
    next(error);
  }
};

// Obtener un producto por ID
const getProductoById = async (req, res, next) => {
  try {
    const { id } = req.params;
    
    const producto = await Producto.findByPk(id, {
      include: [{
        model: Categoria,
        as: 'categoria',
        attributes: ['idCategoria', 'nombre']
      }]
    });

    if (!producto) {
      return res.status(404).json({
        success: false,
        message: 'Producto no encontrado'
      });
    }

    res.json({
      success: true,
      data: producto
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllProductos,
  getProductoById
};
