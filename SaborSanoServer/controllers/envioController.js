const { Envio, Pedido, MetodoPago, Cliente } = require('../models');

// Obtener todos los envíos
const getAllEnvios = async (req, res, next) => {
  try {
    const envios = await Envio.findAll({
      include: [
        {
          model: Pedido,
          as: 'pedido',
          include: [
            {
              model: Cliente,
              as: 'cliente',
              attributes: ['idCliente', 'nombre', 'email']
            }
          ]
        },
        {
          model: MetodoPago,
          as: 'metodoPago',
          attributes: ['idMetodoPago', 'tipo_pago']
        }
      ],
      order: [['idEnvio', 'DESC']]
    });

    res.json({
      success: true,
      count: envios.length,
      data: envios
    });
  } catch (error) {
    next(error);
  }
};

// Obtener un envío por ID
const getEnvioById = async (req, res, next) => {
  try {
    const { id } = req.params;
    
    const envio = await Envio.findByPk(id, {
      include: [
        {
          model: Pedido,
          as: 'pedido',
          include: [
            {
              model: Cliente,
              as: 'cliente',
              attributes: ['idCliente', 'nombre', 'email']
            }
          ]
        },
        {
          model: MetodoPago,
          as: 'metodoPago',
          attributes: ['idMetodoPago', 'tipo_pago']
        }
      ]
    });

    if (!envio) {
      return res.status(404).json({
        success: false,
        message: 'Envío no encontrado'
      });
    }

    res.json({
      success: true,
      data: envio
    });
  } catch (error) {
    next(error);
  }
};

// Obtener envíos por pedido
const getEnviosByPedido = async (req, res, next) => {
  try {
    const { id } = req.params;

    const pedido = await Pedido.findByPk(id);
    if (!pedido) {
      return res.status(404).json({
        success: false,
        message: 'Pedido no encontrado'
      });
    }

    const envio = await Envio.findOne({
      where: { idPedido: id },
      include: [
        {
          model: MetodoPago,
          as: 'metodoPago',
          attributes: ['idMetodoPago', 'tipo_pago']
        }
      ]
    });

    if (!envio) {
      return res.status(404).json({
        success: false,
        message: 'No se encontró envío para este pedido'
      });
    }

    res.json({
      success: true,
      data: envio
    });
  } catch (error) {
    next(error);
  }
};

// Obtener mis envíos (solo envíos de los pedidos del cliente autenticado)
const getMisEnvios = async (req, res, next) => {
  try {
    const clientId = req.clientId;

    // Obtener todos los pedidos del cliente
    const pedidos = await Pedido.findAll({
      where: { idCliente: clientId },
      attributes: ['idPedido']
    });

    const pedidosIds = pedidos.map(p => p.idPedido);

    if (pedidosIds.length === 0) {
      return res.json({
        success: true,
        count: 0,
        data: [],
        message: 'No tienes pedidos con envíos'
      });
    }

    // Obtener envíos de esos pedidos
    const envios = await Envio.findAll({
      where: {
        idPedido: pedidosIds
      },
      include: [
        {
          model: Pedido,
          as: 'pedido',
          attributes: ['idPedido', 'estado', 'fecha_pedido'],
          include: [
            {
              model: Cliente,
              as: 'cliente',
              attributes: ['idCliente', 'nombre', 'email']
            }
          ]
        },
        {
          model: MetodoPago,
          as: 'metodoPago',
          attributes: ['idMetodoPago', 'tipo_pago']
        }
      ],
      order: [['idEnvio', 'DESC']]
    });

    res.json({
      success: true,
      count: envios.length,
      data: envios
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllEnvios,
  getEnvioById,
  getEnviosByPedido,
  getMisEnvios
};
