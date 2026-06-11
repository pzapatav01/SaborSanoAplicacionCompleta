const path = require('path');
const fs = require('fs');
const multer = require('multer');

const AVATARS_DIR = path.join(__dirname, '..', 'public', 'avatars');

const ALLOWED_MIME = new Set([
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/gif',
]);

const ALLOWED_EXT = new Set(['.jpg', '.jpeg', '.png', '.webp', '.gif']);

if (!fs.existsSync(AVATARS_DIR)) {
  fs.mkdirSync(AVATARS_DIR, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, AVATARS_DIR);
  },
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    const safeExt = ALLOWED_EXT.has(ext) ? ext : '.jpg';
    const unique = `avatar-${Date.now()}-${Math.random().toString(36).slice(2, 10)}${safeExt}`;
    cb(null, unique);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 2 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    if (ALLOWED_MIME.has(file.mimetype)) {
      cb(null, true);
      return;
    }
    cb(new Error('Tipo de archivo no permitido. Use JPG, PNG, WEBP o GIF.'));
  },
});

/** Campo multipart opcional: avatar */
const uploadAvatarOptional = upload.single('avatar');

module.exports = {
  uploadAvatarOptional,
  AVATARS_DIR,
};
