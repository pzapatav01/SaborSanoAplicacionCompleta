const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/authMiddleware');
const {
  getAllEnvios,
  getEnvioById,
  getEnviosByPedido,
  getMisEnvios
} = require('../controllers/envioController');

// Rutas protegidas (requieren autenticación)
router.get('/mis-envios', authenticate, getMisEnvios);

// Rutas públicas (sin autenticación)
router.get('/pedido/:id', getEnviosByPedido);
router.get('/', getAllEnvios);
router.get('/:id', getEnvioById);

module.exports = router;
