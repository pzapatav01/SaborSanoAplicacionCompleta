const { Cliente } = require('../models');

const DNI_LETTERS = 'TRWAGMYFPDXBNJZSQVHLCKE';
const DNI_TOTAL_LENGTH = 9;
const DNI_NUMERIC_LENGTH = 8;

const normalizeDni = (dni) => String(dni).trim().toUpperCase().replace(/[\s-]/g, '');

/**
 * DNI/NIF España: 9 caracteres → 8 dígitos + 1 letra de control (ej: 12345678Z).
 */
const isValidSpanishDni = (dni) => {
  const normalized = normalizeDni(dni);

  if (normalized.length !== DNI_TOTAL_LENGTH) return false;

  const numericPart = normalized.slice(0, DNI_NUMERIC_LENGTH);
  const letterPart = normalized.charAt(DNI_NUMERIC_LENGTH);

  if (!/^\d{8}$/.test(numericPart)) return false;
  if (!/^[A-Z]$/.test(letterPart)) return false;

  const number = parseInt(numericPart, 10);
  return DNI_LETTERS[number % 23] === letterPart;
};

const DNI_VALIDATION_MESSAGE =
  'El DNI debe tener 9 caracteres: 8 números y 1 letra al final (ej: 12345678Z)';

const isValidEmail = (email) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(email).trim());

// Función para generar un ID único de cliente
const generarIdCliente = async () => {
  let idCliente;
  let existe = true;
  let intentos = 0;
  const maxIntentos = 10;

  // Generar ID hasta encontrar uno que no exista
  while (existe && intentos < maxIntentos) {
    // Formato: CLI + timestamp (últimos 8 dígitos) + número aleatorio (3 dígitos)
    const timestamp = Date.now().toString().slice(-8);
    const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
    idCliente = `CLI${timestamp}${random}`;

    // Verificar si el ID ya existe
    const clienteExistente = await Cliente.findByPk(idCliente);
    existe = !!clienteExistente;
    intentos++;
  }

  if (intentos >= maxIntentos) {
    throw new Error('No se pudo generar un ID único después de varios intentos');
  }

  return idCliente;
};

// Crear un nuevo cliente
const createCliente = async (req, res, next) => {
  try {
    const { nombre, dni, telefono, email, direccion } = req.body;

    // Validar campos requeridos
    if (!nombre || !dni || !telefono || !email || !direccion) {
      return res.status(400).json({
        success: false,
        message: 'Todos los campos son requeridos',
        required: ['nombre', 'dni', 'telefono', 'email', 'direccion']
      });
    }

    if (!isValidEmail(email)) {
      return res.status(400).json({
        success: false,
        message: 'El formato del email no es válido'
      });
    }

    if (!isValidSpanishDni(dni)) {
      return res.status(400).json({
        success: false,
        message: DNI_VALIDATION_MESSAGE
      });
    }

    // Generar ID único para el cliente
    const idCliente = await generarIdCliente();

    // Crear el cliente
    const cliente = await Cliente.create({
      idCliente,
      nombre,
      dni: normalizeDni(dni),
      telefono,
      email,
      direccion
    });

    res.status(201).json({
      success: true,
      message: 'Cliente registrado correctamente',
      data: cliente
    });
  } catch (error) {
    // Manejar errores de duplicados (dni o email únicos)
    if (error.name === 'SequelizeUniqueConstraintError') {
      const field = error.errors[0].path;
      return res.status(409).json({
        success: false,
        message: `El ${field === 'dni' ? 'DNI' : 'email'} ya está registrado`,
        field: field
      });
    }
    
    // Manejar errores de validación
    if (error.name === 'SequelizeValidationError') {
      return res.status(400).json({
        success: false,
        message: 'Error de validación',
        errors: error.errors.map(e => ({
          field: e.path,
          message: e.message
        }))
      });
    }

    next(error);
  }
};

// Obtener perfil del cliente autenticado
const getMiPerfil = async (req, res, next) => {
  try {
    // El cliente ya está en req.cliente gracias al middleware authenticate
    const cliente = req.cliente;

    // Excluir información sensible si es necesario (aunque en este caso no hay contraseñas)
    const clienteData = {
      idCliente: cliente.idCliente,
      nombre: cliente.nombre,
      dni: cliente.dni,
      telefono: cliente.telefono,
      email: cliente.email,
      direccion: cliente.direccion
    };

    res.json({
      success: true,
      data: clienteData
    });
  } catch (error) {
    next(error);
  }
};

// Actualizar perfil del cliente autenticado
const updateMiPerfil = async (req, res, next) => {
  try {
    const { nombre, dni, telefono, email, direccion } = req.body;

    if (!nombre || !dni || !telefono || !email || !direccion) {
      return res.status(400).json({
        success: false,
        message: 'Todos los campos son requeridos',
        required: ['nombre', 'dni', 'telefono', 'email', 'direccion']
      });
    }

    if (!isValidEmail(email)) {
      return res.status(400).json({
        success: false,
        message: 'El formato del email no es válido'
      });
    }

    if (!isValidSpanishDni(dni)) {
      return res.status(400).json({
        success: false,
        message: DNI_VALIDATION_MESSAGE
      });
    }

    const cliente = req.cliente;
    await cliente.update({
      nombre,
      dni: normalizeDni(dni),
      telefono,
      email,
      direccion
    });

    res.json({
      success: true,
      message: 'Perfil actualizado correctamente',
      data: {
        idCliente: cliente.idCliente,
        nombre: cliente.nombre,
        dni: cliente.dni,
        telefono: cliente.telefono,
        email: cliente.email,
        direccion: cliente.direccion
      }
    });
  } catch (error) {
    if (error.name === 'SequelizeUniqueConstraintError') {
      const field = error.errors[0].path;
      return res.status(409).json({
        success: false,
        message: `El ${field === 'dni' ? 'DNI' : 'email'} ya está registrado`,
        field: field
      });
    }
    if (error.name === 'SequelizeValidationError') {
      return res.status(400).json({
        success: false,
        message: 'Error de validación',
        errors: error.errors.map(e => ({
          field: e.path,
          message: e.message
        }))
      });
    }
    next(error);
  }
};

module.exports = {
  createCliente,
  getMiPerfil,
  updateMiPerfil
};
