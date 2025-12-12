const multer = require("multer");
const path = require("path");
const fs = require("fs");

// Créer les dossiers s'ils n'existent pas
const avatarsDir = path.join(__dirname, "../../uploads/avatars");
const diplomasDir = path.join(__dirname, "../../uploads/diplomas");

if (!fs.existsSync(avatarsDir)) {
  fs.mkdirSync(avatarsDir, { recursive: true });
}

if (!fs.existsSync(diplomasDir)) {
  fs.mkdirSync(diplomasDir, { recursive: true });
}

// Configuration du stockage pour les avatars
const avatarStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, avatarsDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname);
    cb(null, `avatar-${req.user.id}-${uniqueSuffix}${ext}`);
  },
});

// Configuration du stockage pour les diplômes
const diplomaStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, diplomasDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname);
    cb(null, `diploma-${req.user.id}-${uniqueSuffix}${ext}`);
  },
});

// Filtre pour les images uniquement (avatars)
const imageFilter = (req, file, cb) => {
  const allowedTypes = ["image/jpeg", "image/png", "image/gif", "image/webp"];

  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(
      new Error(
        "Type de fichier non autorisé. Seules les images (JPEG, PNG, GIF, WEBP) sont acceptées."
      ),
      false
    );
  }
};

// Filtre pour les documents (diplômes)
const documentFilter = (req, file, cb) => {
  const allowedTypes = ["image/jpeg", "image/png", "application/pdf"];

  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(
      new Error(
        "Type de fichier non autorisé. Seuls les PDF et images sont acceptés."
      ),
      false
    );
  }
};

// Middleware pour l'upload d'avatar
const uploadAvatar = multer({
  storage: avatarStorage,
  fileFilter: imageFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB max
  },
}).single("avatar");

// Middleware pour l'upload de diplôme
const uploadDiploma = multer({
  storage: diplomaStorage,
  fileFilter: documentFilter,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB max
  },
}).single("diploma");

// Middleware avec gestion d'erreurs
const handleUploadError = (uploadMiddleware) => {
  return (req, res, next) => {
    uploadMiddleware(req, res, (err) => {
      if (err instanceof multer.MulterError) {
        if (err.code === "LIMIT_FILE_SIZE") {
          return res.status(400).json({
            error:
              "Fichier trop volumineux. Taille maximale : " +
              (uploadMiddleware === uploadAvatar ? "5MB" : "10MB"),
          });
        }
        return res.status(400).json({ error: err.message });
      } else if (err) {
        return res.status(400).json({ error: err.message });
      }
      next();
    });
  };
};

module.exports = {
  uploadAvatar: handleUploadError(uploadAvatar),
  uploadDiploma: handleUploadError(uploadDiploma),
};
