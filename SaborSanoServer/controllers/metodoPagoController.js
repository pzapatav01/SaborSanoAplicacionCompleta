const { MetodoPago } = require('../models');

// Obtener todos los métodos de pago
const getAllMetodosPago = async (req, res, next) => {
  try {
    const metodosPago = await MetodoPago.findAll({
      order: [['tipo_pago', 'ASC']]
    });

    res.json({
      success: true,
      count: metodosPago.length,
      data: metodosPago
    });
  } catch (error) {
    next(error);
  }
};

// Obtener un método de pago por ID
const getMetodoPagoById = async (req, res, next) => {
  try {
    const { id } = req.params;
    
    const metodoPago = await MetodoPago.findByPk(id);

    if (!metodoPago) {
      return res.status(404).json({
        success: false,
        message: 'Método de pago no encontrado'
      });
    }

    res.json({
      success: true,
      data: metodoPago
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllMetodosPago,
  getMetodoPagoById
};
