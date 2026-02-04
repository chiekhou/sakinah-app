const jwt = require("jsonwebtoken");
const User = require("../models/User");

const JWT_SECRET =
  process.env.JWT_SECRET || "votre_secret_jwt_super_securise_a_changer";

/**
 * Middleware pour vérifier le JWT
 */
const authenticate = async (req, res, next) => {
  try {
    // Récupérer le token depuis le header Authorization
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ error: "Token manquant" });
    }

    const token = authHeader.substring(7); // Enlever "Bearer "

    // Vérifier le token
    const decoded = jwt.verify(token, JWT_SECRET);

    // Récupérer l'utilisateur
    const user = await User.findByPk(decoded.id);

    if (!user) {
      return res.status(401).json({ error: "Utilisateur non trouvé" });
    }

    if (user.status !== "ACTIVE") {
      return res.status(403).json({ error: "Compte inactif ou suspendu" });
    }

    // Ajouter l'utilisateur à la requête
    req.user = {
      id: user.id,
      email: user.email,
      role: user.role,
      pseudo: user.pseudo,
      status: user.status,
    };

    // Mettre à jour last_active
    user
      .update({ last_active: new Date() })
      .catch((err) => console.error("Erreur update last_active:", err));

    next();
  } catch (error) {
    if (error.name === "JsonWebTokenError") {
      return res.status(401).json({ error: "Token invalide" });
    }
    if (error.name === "TokenExpiredError") {
      return res.status(401).json({ error: "Token expiré" });
    }
    console.error("Erreur authenticate:", error);
    res.status(500).json({ error: "Erreur d'authentification" });
  }
};

/**
 * Middleware pour vérifier le rôle
 * Usage: requireRole(['ADMIN', 'MODERATOR'])
 */
const requireRole = (allowedRoles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: "Non authentifié" });
    }

    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({
        error: "Accès refusé",
        required_roles: allowedRoles,
        your_role: req.user.role,
      });
    }

    next();
  };
};

/**
 * Middleware optionnel : ajoute l'utilisateur si token présent
 * Ne bloque pas si pas de token
 */
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return next();
    }

    const token = authHeader.substring(7);
    const decoded = jwt.verify(token, JWT_SECRET);
    const user = await User.findByPk(decoded.id);

    if (user && user.status === "ACTIVE") {
      req.user = {
        id: user.id,
        email: user.email,
        role: user.role,
        pseudo: user.pseudo,
        status: user.status,
      };
    }

    next();
  } catch (error) {
    // En cas d'erreur, on continue sans utilisateur
    next();
  }
};

// Compatibilité avec l'ancien code
const authenticateToken = authenticate;

/**
 * Middleware spécifique pour les admins
 */
const requireAdmin = requireRole(["ADMIN"]);

module.exports = {
  authenticate,
  authenticateToken, // Alias pour compatibilité
  requireRole,
  requireAdmin,
  optionalAuth,
};
