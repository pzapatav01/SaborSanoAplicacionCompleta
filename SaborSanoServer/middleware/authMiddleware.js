const { Cliente } = require('../models');

// Middleware de autenticación - Valida el header X-Client-ID
const authenticate = async (req, res, next) => {
  try {
    // Obtener el ID del cliente del header
    const clientId = req.headers['x-client-id'] || req.headers['X-Client-ID'];

    // Validar que el header esté presente
    if (!clientId) {
      return res.status(401).json({
        success: false,
        message: 'No autorizado. Se requiere el header X-Client-ID',
        code: 'MISSING_CLIENT_ID'
      });
    }

    // Validar formato básico del ID (debe empezar con CLI)
    if (typeof clientId !== 'string' || clientId.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Formato de ID de cliente inválido',
        code: 'INVALID_CLIENT_ID_FORMAT'
      });
    }

    // Buscar el cliente en la base de datos
    const cliente = await Cliente.findByPk(clientId.trim());

    // Validar que el cliente existe
    if (!cliente) {
      return res.status(401).json({
        success: false,
        message: 'Cliente no encontrado o no autorizado',
        code: 'CLIENT_NOT_FOUND'
      });
    }

    // Agregar el cliente al objeto request para usarlo en los controladores
    req.cliente = cliente;
    req.clientId = cliente.idCliente;

    // Continuar con el siguiente middleware o controlador
    next();
  } catch (error) {
    console.error('Error en middleware de autenticación:', error);
    return res.status(500).json({
      success: false,
      message: 'Error al validar la autenticación',
      code: 'AUTH_ERROR'
    });
  }
};

// Middleware opcional - Verifica que el cliente autenticado sea el dueño del recurso
const authorize = (req, res, next) => {
  try {
    const { id } = req.params;
    const clientId = req.clientId;

    // Si el ID del parámetro coincide con el cliente autenticado, permitir acceso
    if (id === clientId) {
      return next();
    }

    // Si no coincide, denegar acceso
    return res.status(403).json({
      success: false,
      message: 'No tienes permiso para acceder a este recurso',
      code: 'FORBIDDEN'
    });
  } catch (error) {
    console.error('Error en middleware de autorización:', error);
    return res.status(500).json({
      success: false,
      message: 'Error al validar la autorización',
      code: 'AUTHORIZATION_ERROR'
    });
  }
};

module.exports = {
  authenticate,
  authorize
};
