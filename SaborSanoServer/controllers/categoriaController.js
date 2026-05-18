const { Categoria } = require('../models');

// Obtener todas las categorías
const getAllCategorias = async (req, res, next) => {
  try {
    const categorias = await Categoria.findAll({
      order: [['nombre', 'ASC']]
    });

    res.json({
      success: true,
      count: categorias.length,
      data: categorias
    });
  } catch (error) {
    next(error);
  }
};

// Obtener una categoría por ID
const getCategoriaById = async (req, res, next) => {
  try {
    const { id } = req.params;
    
    const categoria = await Categoria.findByPk(id);

    if (!categoria) {
      return res.status(404).json({
        success: false,
        message: 'Categoría no encontrada'
      });
    }

    res.json({
      success: true,
      data: categoria
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllCategorias,
  getCategoriaById
};
