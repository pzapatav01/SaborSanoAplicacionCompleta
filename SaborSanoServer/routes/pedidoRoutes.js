const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/authMiddleware');
const {
  createPedido,
  getMisPedidos,
  getMiPedidoById
} = require('../controllers/pedidoController');

// POST /api/pedidos - Registrar un nuevo pedido (público)
router.post('/', createPedido);

// GET /api/pedidos/mis-pedidos - Obtener mis pedidos (protegido)
router.get('/mis-pedidos', authenticate, getMisPedidos);

// GET /api/pedidos/mis-pedidos/:id - Obtener un pedido específico mío (protegido)
router.get('/mis-pedidos/:id', authenticate, getMiPedidoById);

module.exports = router;
