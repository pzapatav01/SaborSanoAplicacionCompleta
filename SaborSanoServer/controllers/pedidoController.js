const { Pedido, DetallePedido, Cliente, Producto, Envio, MetodoPago, sequelize } = require('../models');

const generarIdPedido = async () => {
  let idPedido;
  let existe = true;
  let intentos = 0;
  const maxIntentos = 10;

  while (existe && intentos < maxIntentos) {
    const timestamp = Date.now().toString().slice(-8);
    const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
    idPedido = `PED${timestamp}${random}`;

    const pedidoExistente = await Pedido.findByPk(idPedido);
    existe = !!pedidoExistente;
    intentos++;
  }

  if (intentos >= maxIntentos) {
    throw new Error('No se pudo generar un ID único después de varios intentos');
  }

  return idPedido;
};

const generarIdDetallePedido = async () => {
  let idDetallePedido;
  let existe = true;
  let intentos = 0;
  const maxIntentos = 10;

  while (existe && intentos < maxIntentos) {
    const timestamp = Date.now().toString().slice(-8);
    const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
    idDetallePedido = `DET${timestamp}${random}`;

    const detalleExistente = await DetallePedido.findByPk(idDetallePedido);
    existe = !!detalleExistente;
    intentos++;
  }

  if (intentos >= maxIntentos) {
    throw new Error('No se pudo generar un ID único después de varios intentos');
  }

  return idDetallePedido;
};

const generarIdEnvio = async () => {
  let idEnvio;
  let existe = true;
  let intentos = 0;
  const maxIntentos = 10;

  while (existe && intentos < maxIntentos) {
    const timestamp = Date.now().toString().slice(-8);
    const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
    idEnvio = `ENV${timestamp}${random}`;

    const envioExistente = await Envio.findByPk(idEnvio);
    existe = !!envioExistente;
    intentos++;
  }

  if (intentos >= maxIntentos) {
    throw new Error('No se pudo generar un ID único después de varios intentos');
  }

  return idEnvio;
};

const crearEnvioAutomatico = async (idPedido) => {
  try {
    setTimeout(async () => {
      const transaction = await sequelize.transaction();
      
      try {
        const pedido = await Pedido.findByPk(idPedido, { transaction });
        if (!pedido) {
          console.log(`⚠️  Pedido ${idPedido} no encontrado para crear envío`);
          await transaction.rollback();
          return;
        }

        const envioExistente = await Envio.findOne({
          where: { idPedido },
          transaction
        });

        if (envioExistente) {
          console.log(`⚠️  Ya existe un envío para el pedido ${idPedido}`);
          await transaction.rollback();
          return;
        }

        let metodoPago = await MetodoPago.findOne({
          where: { idMetodoPago: 'MP001' },
          transaction
        });

        if (!metodoPago) {
          metodoPago = await MetodoPago.findOne({ transaction });
          if (!metodoPago) {
            console.log(`❌ No hay métodos de pago disponibles para el pedido ${idPedido}`);
            await transaction.rollback();
            return;
          }
        }

        const idEnvio = await generarIdEnvio();
        await pedido.update({ estado: 'EN PREPARACIÓN' }, { transaction });
        await Envio.create({
          idEnvio,
          idPedido,
          idMetodo: metodoPago.idMetodoPago,
          estado: 'EN TRÁNSITO'
        }, { transaction });

        await transaction.commit();
        console.log(`✅ Envío ${idEnvio} creado automáticamente para el pedido ${idPedido}`);
      } catch (error) {
        await transaction.rollback();
        console.error(`❌ Error al crear envío automático para pedido ${idPedido}:`, error.message);
      }
    }, 60000);
  } catch (error) {
    console.error(`❌ Error al programar creación de envío para pedido ${idPedido}:`, error.message);
  }
};

const createPedido = async (req, res, next) => {
  const transaction = await sequelize.transaction();

  try {
    const { idCliente, detalles } = req.body;

    if (!idCliente || !detalles || !Array.isArray(detalles) || detalles.length === 0) {
      await transaction.rollback();
      return res.status(400).json({
        success: false,
        message: 'Todos los campos son requeridos',
        required: ['idCliente', 'detalles'],
        note: 'detalles debe ser un array con al menos un elemento'
      });
    }

    const fechaPedido = new Date().toISOString().split('T')[0];
    const estado = 'PENDIENTE';
    const cliente = await Cliente.findByPk(idCliente, { transaction });

    if (!cliente) {
      await transaction.rollback();
      return res.status(404).json({
        success: false,
        message: 'Cliente no encontrado'
      });
    }

    const productosValidados = [];
    for (const detalle of detalles) {
      if (!detalle.idProducto || !detalle.cantidad) {
        await transaction.rollback();
        return res.status(400).json({
          success: false,
          message: 'Cada detalle debe tener idProducto y cantidad'
        });
      }

      if (detalle.cantidad < 1) {
        await transaction.rollback();
        return res.status(400).json({
          success: false,
          message: 'La cantidad debe ser mayor a 0'
        });
      }

      const producto = await Producto.findByPk(detalle.idProducto, { transaction });
      if (!producto) {
        await transaction.rollback();
        return res.status(404).json({
          success: false,
          message: `Producto ${detalle.idProducto} no encontrado`
        });
      }

      if (producto.stock < detalle.cantidad) {
        await transaction.rollback();
        return res.status(400).json({
          success: false,
          message: `Stock insuficiente para el producto ${producto.nombre}. Stock disponible: ${producto.stock}, solicitado: ${detalle.cantidad}`
        });
      }

      productosValidados.push({ producto, cantidad: detalle.cantidad });
    }

    const idPedido = await generarIdPedido();
    const pedido = await Pedido.create({
      idPedido,
      idCliente,
      estado: estado,
      fecha_pedido: fechaPedido
    }, { transaction });

    const detallesCreados = [];
    for (const { producto, cantidad } of productosValidados) {
      const idDetallePedido = await generarIdDetallePedido();

      const detalle = await DetallePedido.create({
        idDetallePedido,
        idPedido,
        idProducto: producto.idProducto,
        cantidad
      }, { transaction });

      await producto.update(
        { stock: producto.stock - cantidad },
        { transaction }
      );

      detallesCreados.push(detalle);
    }

    await transaction.commit();

    crearEnvioAutomatico(idPedido);

    const pedidoCompleto = await Pedido.findByPk(idPedido, {
      include: [
        {
          model: Cliente,
          as: 'cliente',
          attributes: ['idCliente', 'nombre', 'email']
        },
        {
          model: DetallePedido,
          as: 'detalles',
          include: [
            {
              model: Producto,
              as: 'producto',
              attributes: ['idProducto', 'nombre', 'precio', 'imageUrl']
            }
          ]
        }
      ]
    });

    res.status(201).json({
      success: true,
      message: 'Pedido registrado correctamente. El envío se generará automáticamente en 1 minuto.',
      data: pedidoCompleto
    });
  } catch (error) {
    await transaction.rollback();

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

// Obtener mis pedidos (solo del cliente autenticado)
const getMisPedidos = async (req, res, next) => {
  try {
    const clientId = req.clientId;

    const pedidos = await Pedido.findAll({
      where: { idCliente: clientId },
      include: [
        {
          model: DetallePedido,
          as: 'detalles',
          include: [
            {
              model: Producto,
              as: 'producto',
              attributes: ['idProducto', 'nombre', 'precio']
            }
          ]
        },
        {
          model: Envio,
          as: 'envio',
          include: [
            {
              model: MetodoPago,
              as: 'metodoPago',
              attributes: ['idMetodoPago', 'tipo_pago']
            }
          ],
          required: false
        }
      ],
      order: [['fecha_pedido', 'DESC'], ['idPedido', 'DESC']]
    });

    res.json({
      success: true,
      count: pedidos.length,
      data: pedidos
    });
  } catch (error) {
    next(error);
  }
};

// Obtener un pedido específico del cliente autenticado
const getMiPedidoById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const clientId = req.clientId;

    const pedido = await Pedido.findOne({
      where: {
        idPedido: id,
        idCliente: clientId
      },
      include: [
        {
          model: Cliente,
          as: 'cliente',
          attributes: ['idCliente', 'nombre', 'email']
        },
        {
          model: DetallePedido,
          as: 'detalles',
          include: [
            {
              model: Producto,
              as: 'producto',
              attributes: ['idProducto', 'nombre', 'precio']
            }
          ]
        },
        {
          model: Envio,
          as: 'envio',
          include: [
            {
              model: MetodoPago,
              as: 'metodoPago',
              attributes: ['idMetodoPago', 'tipo_pago']
            }
          ],
          required: false
        }
      ]
    });

    if (!pedido) {
      return res.status(404).json({
        success: false,
        message: 'Pedido no encontrado o no tienes permiso para acceder a él'
      });
    }

    res.json({
      success: true,
      data: pedido
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createPedido,
  getMisPedidos,
  getMiPedidoById
};
