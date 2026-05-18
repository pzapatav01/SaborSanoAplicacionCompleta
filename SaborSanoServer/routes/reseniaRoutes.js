const express = require('express');
const router = express.Router();
const {
  getAllResenias,
  getReseniaById,
  createResenia,
  updateResenia,
  deleteResenia,
  getReseniasByProducto,
  getReseniasByCliente
} = require('../controllers/reseniaController');

router.get('/producto/:id', getReseniasByProducto);
router.get('/cliente/:id', getReseniasByCliente);
router.get('/', getAllResenias);
router.post('/', createResenia);
router.get('/:id', getReseniaById);
router.put('/:id', updateResenia);
router.delete('/:id', deleteResenia);

module.exports = router;
