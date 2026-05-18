const express = require('express');
const router = express.Router();
const {
  getAllCategorias,
  getCategoriaById
} = require('../controllers/categoriaController');

router.get('/', getAllCategorias);
router.get('/:id', getCategoriaById);

module.exports = router;
