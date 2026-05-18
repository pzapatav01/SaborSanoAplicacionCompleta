require('dotenv').config();
const { Categoria, Producto, sequelize } = require('../models');

// Datos de ejemplo para categorías
const categoriasData = [
  { idCategoria: 'CAT001', nombre: 'Bebidas' },
  { idCategoria: 'CAT002', nombre: 'Snacks' },
  { idCategoria: 'CAT003', nombre: 'Postres' },
  { idCategoria: 'CAT004', nombre: 'Platos Principales' },
  { idCategoria: 'CAT005', nombre: 'Ensaladas' }
];

// Datos de ejemplo para productos
const productosData = [
  // Bebidas
  {
    idProducto: 'PROD001',
    nombre: 'Jugo de Naranja Natural',
    precio: 5000,
    idCategoria: 'CAT001',
    descripcion: 'Jugo de naranja 100% natural, recién exprimido',
    stock: 50
  },
  {
    idProducto: 'PROD002',
    nombre: 'Agua Mineral',
    precio: 2000,
    idCategoria: 'CAT001',
    descripcion: 'Agua mineral natural de 500ml',
    stock: 100
  },
  {
    idProducto: 'PROD003',
    nombre: 'Limonada Natural',
    precio: 4500,
    idCategoria: 'CAT001',
    descripcion: 'Limonada fresca con limones naturales',
    stock: 30
  },
  // Snacks
  {
    idProducto: 'PROD004',
    nombre: 'Papas Fritas Caseras',
    precio: 8000,
    idCategoria: 'CAT002',
    descripcion: 'Papas fritas caseras con sal marina',
    stock: 40
  },
  {
    idProducto: 'PROD005',
    nombre: 'Nachos con Queso',
    precio: 12000,
    idCategoria: 'CAT002',
    descripcion: 'Nachos crujientes con queso derretido',
    stock: 25
  },
  {
    idProducto: 'PROD006',
    nombre: 'Palomitas de Maíz',
    precio: 6000,
    idCategoria: 'CAT002',
    descripcion: 'Palomitas de maíz naturales',
    stock: 60
  },
  // Postres
  {
    idProducto: 'PROD007',
    nombre: 'Torta de Chocolate',
    precio: 15000,
    idCategoria: 'CAT003',
    descripcion: 'Deliciosa torta de chocolate casera',
    stock: 15
  },
  {
    idProducto: 'PROD008',
    nombre: 'Helado de Vainilla',
    precio: 7000,
    idCategoria: 'CAT003',
    descripcion: 'Helado artesanal de vainilla',
    stock: 35
  },
  {
    idProducto: 'PROD009',
    nombre: 'Flan de Caramelo',
    precio: 6500,
    idCategoria: 'CAT003',
    descripcion: 'Flan casero con caramelo',
    stock: 20
  },
  // Platos Principales
  {
    idProducto: 'PROD010',
    nombre: 'Hamburguesa Clásica',
    precio: 18000,
    idCategoria: 'CAT004',
    descripcion: 'Hamburguesa con carne, lechuga, tomate y salsas',
    stock: 30
  },
  {
    idProducto: 'PROD011',
    nombre: 'Pizza Margarita',
    precio: 22000,
    idCategoria: 'CAT004',
    descripcion: 'Pizza con tomate, mozzarella y albahaca',
    stock: 20
  },
  {
    idProducto: 'PROD012',
    nombre: 'Pasta Carbonara',
    precio: 25000,
    idCategoria: 'CAT004',
    descripcion: 'Pasta con salsa carbonara casera',
    stock: 18
  },
  // Ensaladas
  {
    idProducto: 'PROD013',
    nombre: 'Ensalada César',
    precio: 14000,
    idCategoria: 'CAT005',
    descripcion: 'Ensalada con pollo, crutones y aderezo césar',
    stock: 25
  },
  {
    idProducto: 'PROD014',
    nombre: 'Ensalada Mediterránea',
    precio: 16000,
    idCategoria: 'CAT005',
    descripcion: 'Ensalada con tomate, queso feta y aceitunas',
    stock: 22
  }
];

// Función para insertar datos
const seedData = async () => {
  try {
    console.log('🔄 Conectando a la base de datos...');
    await sequelize.authenticate();
    console.log('✅ Conexión establecida correctamente.\n');

    // Insertar categorías
    console.log('📦 Insertando categorías...');
    for (const categoria of categoriasData) {
      const [categoriaCreada, created] = await Categoria.findOrCreate({
        where: { idCategoria: categoria.idCategoria },
        defaults: categoria
      });
      
      if (created) {
        console.log(`  ✅ Categoría creada: ${categoria.nombre} (${categoria.idCategoria})`);
      } else {
        console.log(`  ⚠️  Categoría ya existe: ${categoria.nombre} (${categoria.idCategoria})`);
      }
    }

    console.log('\n📦 Insertando productos...');
    // Insertar productos
    for (const producto of productosData) {
      // Verificar que la categoría existe
      const categoria = await Categoria.findByPk(producto.idCategoria);
      if (!categoria) {
        console.log(`  ❌ Error: La categoría ${producto.idCategoria} no existe. Saltando producto ${producto.nombre}`);
        continue;
      }

      const [productoCreado, created] = await Producto.findOrCreate({
        where: { idProducto: producto.idProducto },
        defaults: producto
      });

      if (created) {
        console.log(`  ✅ Producto creado: ${producto.nombre} (${producto.idProducto})`);
      } else {
        console.log(`  ⚠️  Producto ya existe: ${producto.nombre} (${producto.idProducto})`);
      }
    }

    console.log('\n✅ Datos insertados correctamente!');
    console.log(`📊 Resumen:`);
    console.log(`   - Categorías: ${categoriasData.length}`);
    console.log(`   - Productos: ${productosData.length}`);

  } catch (error) {
    console.error('❌ Error al insertar datos:', error.message);
    console.error(error);
  } finally {
    await sequelize.close();
    console.log('\n🔌 Conexión cerrada.');
    process.exit(0);
  }
};

// Ejecutar el script
seedData();
