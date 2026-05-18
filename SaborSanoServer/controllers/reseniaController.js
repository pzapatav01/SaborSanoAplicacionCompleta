const { Resenia, Cliente, Producto } = require('../models');

const generarIdResenia = async () => {
  let idResenia;
  let existe = true;
  let intentos = 0;
  const maxIntentos = 10;

  while (existe && intentos < maxIntentos) {
    const timestamp = Date.now().toString().slice(-8);
    const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
    idResenia = `RES${timestamp}${random}`;

    const reseniaExistente = await Resenia.findByPk(idResenia);
    existe = !!reseniaExistente;
    intentos++;
  }

  if (intentos >= maxIntentos) {
    throw new Error('No se pudo generar un ID único después de varios intentos');
  }

  return idResenia;
};

const getAllResenias = async (req, res, next) => {
  try {
    const resenias = await Resenia.findAll({
      include: [
        {
          model: Cliente,
          as: 'cliente',
          attributes: ['idCliente', 'nombre', 'email']
        },
        {
          model: Producto,
          as: 'producto',
          attributes: ['idProducto', 'nombre', 'precio']
        }
      ],
      order: [['calificacion', 'DESC'], ['idResenia', 'DESC']]
    });

    res.json({
      success: true,
      count: resenias.length,
      data: resenias
    });
  } catch (error) {
    next(error);
  }
};

const getReseniaById = async (req, res, next) => {
  try {
    const { id } = req.params;
    
    const resenia = await Resenia.findByPk(id, {
      include: [
        {
          model: Cliente,
          as: 'cliente',
          attributes: ['idCliente', 'nombre', 'email']
        },
        {
          model: Producto,
          as: 'producto',
          attributes: ['idProducto', 'nombre', 'precio', 'imageUrl']
        }
      ]
    });

    if (!resenia) {
      return res.status(404).json({
        success: false,
        message: 'Reseña no encontrada'
      });
    }

    res.json({
      success: true,
      data: resenia
    });
  } catch (error) {
    next(error);
  }
};

const createResenia = async (req, res, next) => {
  try {
    const { idCliente, idProducto, comentario, calificacion } = req.body;

    if (!idCliente || !idProducto || !comentario || !calificacion) {
      return res.status(400).json({
        success: false,
        message: 'Todos los campos son requeridos',
        required: ['idCliente', 'idProducto', 'comentario', 'calificacion']
      });
    }

    if (calificacion < 1 || calificacion > 5) {
      return res.status(400).json({
        success: false,
        message: 'La calificación debe estar entre 1 y 5'
      });
    }

    if (comentario.length > 150) {
      return res.status(400).json({
        success: false,
        message: 'El comentario no puede exceder 150 caracteres'
      });
    }

    const cliente = await Cliente.findByPk(idCliente);
    if (!cliente) {
      return res.status(404).json({
        success: false,
        message: 'Cliente no encontrado'
      });
    }

    const producto = await Producto.findByPk(idProducto);
    if (!producto) {
      return res.status(404).json({
        success: false,
        message: 'Producto no encontrado'
      });
    }

    const idResenia = await generarIdResenia();

    const resenia = await Resenia.create({
      idResenia,
      idCliente,
      idProducto,
      comentario,
      calificacion
    });

    const reseniaCompleta = await Resenia.findByPk(idResenia, {
      include: [
        {
          model: Cliente,
          as: 'cliente',
          attributes: ['idCliente', 'nombre', 'email']
        },
        {
          model: Producto,
          as: 'producto',
          attributes: ['idProducto', 'nombre', 'precio']
        }
      ]
    });

    res.status(201).json({
      success: true,
      message: 'Reseña creada correctamente',
      data: reseniaCompleta
    });
  } catch (error) {
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

const updateResenia = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { comentario, calificacion } = req.body;

    const resenia = await Resenia.findByPk(id);
    
    if (!resenia) {
      return res.status(404).json({
        success: false,
        message: 'Reseña no encontrada'
      });
    }

    if (calificacion !== undefined) {
      if (calificacion < 1 || calificacion > 5) {
        return res.status(400).json({
          success: false,
          message: 'La calificación debe estar entre 1 y 5'
        });
      }
    }

    if (comentario !== undefined && comentario.length > 150) {
      return res.status(400).json({
        success: false,
        message: 'El comentario no puede exceder 150 caracteres'
      });
    }

    const camposActualizar = {};
    if (comentario !== undefined) camposActualizar.comentario = comentario;
    if (calificacion !== undefined) camposActualizar.calificacion = calificacion;

    await resenia.update(camposActualizar);

    const reseniaActualizada = await Resenia.findByPk(id, {
      include: [
        {
          model: Cliente,
          as: 'cliente',
          attributes: ['idCliente', 'nombre', 'email']
        },
        {
          model: Producto,
          as: 'producto',
          attributes: ['idProducto', 'nombre', 'precio']
        }
      ]
    });

    res.json({
      success: true,
      message: 'Reseña actualizada correctamente',
      data: reseniaActualizada
    });
  } catch (error) {
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

const deleteResenia = async (req, res, next) => {
  try {
    const { id } = req.params;

    const resenia = await Resenia.findByPk(id);

    if (!resenia) {
      return res.status(404).json({
        success: false,
        message: 'Reseña no encontrada'
      });
    }

    await resenia.destroy();

    res.json({
      success: true,
      message: 'Reseña eliminada correctamente'
    });
  } catch (error) {
    next(error);
  }
};

const getReseniasByProducto = async (req, res, next) => {
  try {
    const { id } = req.params;

    const producto = await Producto.findByPk(id);
    if (!producto) {
      return res.status(404).json({
        success: false,
        message: 'Producto no encontrado'
      });
    }

    const resenias = await Resenia.findAll({
      where: { idProducto: id },
      include: [
        {
          model: Cliente,
          as: 'cliente',
          attributes: ['idCliente', 'nombre', 'email']
        }
      ],
      order: [['calificacion', 'DESC'], ['idResenia', 'DESC']]
    });

    res.json({
      success: true,
      count: resenias.length,
      data: resenias
    });
  } catch (error) {
    next(error);
  }
};

const getReseniasByCliente = async (req, res, next) => {
  try {
    const { id } = req.params;

    const cliente = await Cliente.findByPk(id);
    if (!cliente) {
      return res.status(404).json({
        success: false,
        message: 'Cliente no encontrado'
      });
    }

    const resenias = await Resenia.findAll({
      where: { idCliente: id },
      include: [
        {
          model: Producto,
          as: 'producto',
          attributes: ['idProducto', 'nombre', 'precio', 'imageUrl']
        }
      ],
      order: [['calificacion', 'DESC'], ['idResenia', 'DESC']]
    });

    res.json({
      success: true,
      count: resenias.length,
      data: resenias
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllResenias,
  getReseniaById,
  createResenia,
  updateResenia,
  deleteResenia,
  getReseniasByProducto,
  getReseniasByCliente
};
