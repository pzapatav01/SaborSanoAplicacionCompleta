const path = require('path');
const fs = require('fs');

const PUBLIC_DIR = path.join(__dirname, '..', 'public');

/**
 * Ruta relativa guardada en BD (ej: avatars/avatar-123.jpg).
 * URL pública: {host}/public/{avatar}
 */
function toAvatarDbPath(filename) {
  if (!filename || typeof filename !== 'string') return null;
  const base = path.basename(filename.trim());
  if (!base) return null;
  return `avatars/${base}`;
}

function deleteAvatarFile(relativePath) {
  if (!relativePath || typeof relativePath !== 'string') return;
  const normalized = relativePath.replace(/\\/g, '/').replace(/^\/+/, '');
  if (normalized.includes('..')) return;

  const fullPath = path.join(PUBLIC_DIR, normalized);
  if (!fullPath.startsWith(PUBLIC_DIR)) return;

  try {
    if (fs.existsSync(fullPath)) {
      fs.unlinkSync(fullPath);
    }
  } catch (err) {
    console.warn('⚠️  No se pudo eliminar avatar:', err.message);
  }
}

function cleanupUploadedFile(file) {
  if (file?.path) {
    deleteAvatarFile(`avatars/${path.basename(file.path)}`);
  }
}

module.exports = {
  toAvatarDbPath,
  deleteAvatarFile,
  cleanupUploadedFile,
};
