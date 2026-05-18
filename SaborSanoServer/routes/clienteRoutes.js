const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/authMiddleware');
const {
  createCliente,
  getMiPerfil,
  updateMiPerfil
} = require('../controllers/clienteController');

// POST /api/clientes - Registrar un nuevo cliente (público)
router.post('/', createCliente);

// GET /api/clientes/mi-perfil - Obtener perfil del cliente autenticado (protegido)
router.get('/mi-perfil', authenticate, getMiPerfil);

// PUT /api/clientes/mi-perfil - Actualizar perfil del cliente autenticado (protegido)
router.put('/mi-perfil', authenticate, updateMiPerfil);

// PATCH (alias del PUT para compatibilidad con clientes)
router.patch('/mi-perfil', authenticate, updateMiPerfil);

module.exports = router;
