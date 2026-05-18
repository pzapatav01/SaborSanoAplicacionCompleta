const express = require('express');
const router = express.Router();
const {
  getAllMetodosPago,
  getMetodoPagoById
} = require('../controllers/metodoPagoController');

router.get('/', getAllMetodosPago);
router.get('/:id', getMetodoPagoById);

module.exports = router;
