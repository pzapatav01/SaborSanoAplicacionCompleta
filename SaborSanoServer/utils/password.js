const bcrypt = require('bcryptjs');

const SALT_ROUNDS = 12;
const MIN_PASSWORD_LENGTH = 8;
const MAX_PASSWORD_LENGTH = 128;

const validatePasswordStrength = (password) => {
  if (typeof password !== 'string') {
    return 'La contraseña es requerida';
  }
  const trimmed = password.trim();
  if (trimmed.length < MIN_PASSWORD_LENGTH) {
    return `La contraseña debe tener al menos ${MIN_PASSWORD_LENGTH} caracteres`;
  }
  if (password.length > MAX_PASSWORD_LENGTH) {
    return `La contraseña no puede exceder ${MAX_PASSWORD_LENGTH} caracteres`;
  }
  return null;
};

const hashPassword = async (plainPassword) => {
  return bcrypt.hash(plainPassword, SALT_ROUNDS);
};

const verifyPassword = async (plainPassword, passwordHash) => {
  if (!passwordHash || typeof passwordHash !== 'string') {
    return false;
  }
  return bcrypt.compare(plainPassword, passwordHash);
};

module.exports = {
  hashPassword,
  verifyPassword,
  validatePasswordStrength,
  MIN_PASSWORD_LENGTH,
};
