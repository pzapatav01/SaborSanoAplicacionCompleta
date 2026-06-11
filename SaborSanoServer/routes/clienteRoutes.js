const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/authMiddleware');
const { uploadAvatarOptional } = require('../middleware/uploadAvatar');
const {
  createCliente,
  loginCliente,
  getMiPerfil,
  updateMiPerfil
} = require('../controllers/clienteController');

const handleAvatarUpload = (req, res, next) => {
  uploadAvatarOptional(req, res, (err) => {
    if (!err) return next();
    return res.status(400).json({
      success: false,
      message: err.message || 'Error al subir la imagen de perfil',
    });
  });
};

// POST /api/clientes/login - Iniciar sesión (público)
router.post('/login', loginCliente);

// POST /api/clientes - Registrar (multipart: campos + avatar opcional)
router.post('/', handleAvatarUpload, createCliente);

// GET /api/clientes/mi-perfil - Obtener perfil del cliente autenticado (protegido)
router.get('/mi-perfil', authenticate, getMiPerfil);

// PUT /api/clientes/mi-perfil - Actualizar perfil del cliente autenticado (protegido)
router.put('/mi-perfil', authenticate, updateMiPerfil);

// PATCH (alias del PUT para compatibilidad con clientes)
router.patch('/mi-perfil', authenticate, updateMiPerfil);

module.exports = router;
