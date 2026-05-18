/**
 * EJEMPLO COMPLETO: Cómo crear un recurso completo (User)
 * 
 * Este archivo muestra cómo implementar un CRUD completo.
 * Copia y adapta este código a tus necesidades.
 */

// ============================================
// 1. MODELO (models/user.js)
// ============================================
/*
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const User = sequelize.define('User', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
    validate: {
      notEmpty: true,
      len: [2, 100]
    }
  },
  email: {
    type: DataTypes.STRING(255),
    allowNull: false,
    unique: true,
    validate: {
      isEmail: true
    }
  },
  password: {
    type: DataTypes.STRING(255),
    allowNull: false,
    validate: {
      len: [6, 255]
    }
  },
  status: {
    type: DataTypes.ENUM('active', 'inactive'),
    defaultValue: 'active'
  }
}, {
  tableName: 'users',
  timestamps: true,
  underscored: false
});

module.exports = User;
*/

// ============================================
// 2. REGISTRAR MODELO (models/index.js)
// ============================================
/*
const User = require('./user')(sequelize, DataTypes);
// O si exportas directamente:
const User = require('./user');

const db = {
  sequelize,
  Sequelize: require('sequelize'),
  User
};

module.exports = db;
*/

// ============================================
// 3. CONTROLADOR (controllers/userController.js)
// ============================================
/*
const { User } = require('../models');

// Obtener todos los usuarios
const getAllUsers = async (req, res, next) => {
  try {
    const users = await User.findAll({
      attributes: { exclude: ['password'] }, // Excluir password
      order: [['createdAt', 'DESC']]
    });
    
    res.json({
      success: true,
      count: users.length,
      data: users
    });
  } catch (error) {
    next(error);
  }
};

// Obtener un usuario por ID
const getUserById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const user = await User.findByPk(id, {
      attributes: { exclude: ['password'] }
    });
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Usuario no encontrado'
      });
    }
    
    res.json({
      success: true,
      data: user
    });
  } catch (error) {
    next(error);
  }
};

// Crear un nuevo usuario
const createUser = async (req, res, next) => {
  try {
    const { name, email, password } = req.body;
    
    const user = await User.create({
      name,
      email,
      password // En producción, hashear la contraseña
    });
    
    // Excluir password de la respuesta
    const userResponse = user.toJSON();
    delete userResponse.password;
    
    res.status(201).json({
      success: true,
      message: 'Usuario creado correctamente',
      data: userResponse
    });
  } catch (error) {
    next(error);
  }
};

// Actualizar un usuario
const updateUser = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { name, email, status } = req.body;
    
    const user = await User.findByPk(id);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Usuario no encontrado'
      });
    }
    
    await user.update({
      name: name || user.name,
      email: email || user.email,
      status: status || user.status
    });
    
    const userResponse = user.toJSON();
    delete userResponse.password;
    
    res.json({
      success: true,
      message: 'Usuario actualizado correctamente',
      data: userResponse
    });
  } catch (error) {
    next(error);
  }
};

// Eliminar un usuario
const deleteUser = async (req, res, next) => {
  try {
    const { id } = req.params;
    
    const user = await User.findByPk(id);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Usuario no encontrado'
      });
    }
    
    await user.destroy();
    
    res.json({
      success: true,
      message: 'Usuario eliminado correctamente'
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllUsers,
  getUserById,
  createUser,
  updateUser,
  deleteUser
};
*/

// ============================================
// 4. RUTAS (routes/userRoutes.js)
// ============================================
/*
const express = require('express');
const router = express.Router();
const {
  getAllUsers,
  getUserById,
  createUser,
  updateUser,
  deleteUser
} = require('../controllers/userController');

// GET /api/users - Obtener todos los usuarios
router.get('/', getAllUsers);

// GET /api/users/:id - Obtener un usuario por ID
router.get('/:id', getUserById);

// POST /api/users - Crear un nuevo usuario
router.post('/', createUser);

// PUT /api/users/:id - Actualizar un usuario
router.put('/:id', updateUser);

// DELETE /api/users/:id - Eliminar un usuario
router.delete('/:id', deleteUser);

module.exports = router;
*/

// ============================================
// 5. REGISTRAR RUTAS (routes/index.js)
// ============================================
/*
const userRoutes = require('./userRoutes');
router.use('/users', userRoutes);
*/

module.exports = {};
