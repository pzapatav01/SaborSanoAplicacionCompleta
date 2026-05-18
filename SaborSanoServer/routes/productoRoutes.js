const express = require('express');
const router = express.Router();
const {
  getAllProductos,
  getProductoById
} = require('../controllers/productoController');

// GET /api/productos - Obtener todos los productos
router.get('/', getAllProductos);

// GET /api/productos/:id - Obtener un producto por ID
router.get('/:id', getProductoById);

module.exports = router;
