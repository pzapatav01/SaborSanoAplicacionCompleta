# Server Paloma - API REST

Servidor API REST construido con Express, Node.js y MySQL usando Sequelize como ORM.

## 🚀 Características

- Express.js para el servidor
- MySQL con Sequelize ORM
- Estructura de carpetas organizada
- Manejo de errores centralizado
- Variables de entorno para configuración
- Middleware para CORS y logging
- Buenas prácticas de programación

## 📁 Estructura del Proyecto

```
server-paloma/
├── config/
│   └── database.js          # Configuración de Sequelize
├── controllers/             # Controladores de la API
│   └── index.js
├── models/                  # Modelos de Sequelize
│   └── index.js
├── routes/                  # Definición de rutas
│   └── index.js
├── middleware/              # Middleware personalizado
│   └── errorHandler.js
├── .env.example            # Ejemplo de variables de entorno
├── .gitignore
├── package.json
├── server.js               # Archivo principal del servidor
└── README.md
```

## 📦 Instalación

1. Clona o descarga el proyecto
2. Instala las dependencias:
```bash
npm install
```

3. Crea un archivo `.env` basado en `.env.example`:
```bash
cp .env.example .env
```

4. Configura las variables de entorno en `.env`:
```env
PORT=3000
NODE_ENV=development
DB_HOST=localhost
DB_PORT=3306
DB_NAME=paloma_db
DB_USER=root
DB_PASSWORD=tu_contraseña
```

5. Asegúrate de tener MySQL corriendo y crear la base de datos:
```sql
CREATE DATABASE paloma_db;
```

## 🏃 Ejecución

### Modo desarrollo (con nodemon):
```bash
npm run dev
```

### Modo producción:
```bash
npm start
```

El servidor estará disponible en `http://localhost:3000`

## 📡 Endpoints

- `GET /api` - Información de la API
- `GET /api/health` - Estado de salud del servidor

## 🔧 Crear un Nuevo Recurso

### 1. Crear el Modelo

En `models/index.js` o crea un nuevo archivo:

```javascript
const User = sequelize.define('User', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  }
}, {
  tableName: 'users'
});
```

### 2. Crear el Controlador

Crea `controllers/userController.js`:

```javascript
const { User } = require('../models');

const getAllUsers = async (req, res, next) => {
  try {
    const users = await User.findAll();
    res.json({ success: true, data: users });
  } catch (error) {
    next(error);
  }
};

module.exports = { getAllUsers };
```

### 3. Crear las Rutas

Crea `routes/userRoutes.js`:

```javascript
const express = require('express');
const router = express.Router();
const { getAllUsers } = require('../controllers/userController');

router.get('/', getAllUsers);

module.exports = router;
```

### 4. Registrar las Rutas

En `routes/index.js`:

```javascript
const userRoutes = require('./userRoutes');
router.use('/users', userRoutes);
```

## 🛠️ Tecnologías Utilizadas

- **Node.js** - Entorno de ejecución
- **Express** - Framework web
- **MySQL** - Base de datos
- **Sequelize** - ORM para MySQL
- **dotenv** - Variables de entorno
- **cors** - Middleware CORS
- **morgan** - Logger HTTP

## 📝 Notas

- Los modelos se sincronizan automáticamente en modo desarrollo
- El manejo de errores está centralizado en `middleware/errorHandler.js`
- Usa variables de entorno para configuración sensible
- La estructura sigue principios SOLID y separación de responsabilidades
