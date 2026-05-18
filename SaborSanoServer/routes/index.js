const express = require('express');
const router = express.Router();

const productoRoutes = require('./productoRoutes');
const clienteRoutes = require('./clienteRoutes');
const pedidoRoutes = require('./pedidoRoutes');
const reseniaRoutes = require('./reseniaRoutes');
const metodoPagoRoutes = require('./metodoPagoRoutes');
const categoriaRoutes = require('./categoriaRoutes');
const envioRoutes = require('./envioRoutes');
const paymentRoutes = require('./paymentRoutes');

router.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'API REST funcionando correctamente',
    version: '1.0.0'
  });
});

router.use('/productos', productoRoutes);
router.use('/clientes', clienteRoutes);
router.use('/pedidos', pedidoRoutes);
router.use('/resenias', reseniaRoutes);
router.use('/metodos-pago', metodoPagoRoutes);
router.use('/categorias', categoriaRoutes);
router.use('/envios', envioRoutes);
router.use('/payments', paymentRoutes);

module.exports = router;
