const jwt = require("jsonwebtoken");
const User = require("../models/User");

/**
 * Middleware pour vérifier le token JWT
 */
async function authenticateToken(req, res, next) {
  try {
    // Récupérer le token depuis le header Authorization
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1]; // Format: "Bearer TOKEN"

    if (!token) {
      return res
        .status(401)
        .json({ error: "Token d'authentification manquant" });
    }

    // Vérifier le token
    jwt.verify(token, process.env.JWT_SECRET, async (err, decoded) => {
      if (err) {
        return res.status(403).json({ error: "Token invalide ou expiré" });
      }

      // Vérifier que l'utilisateur existe toujours
      const user = await User.findByPk(decoded.userId);

      if (!user) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }

      // Ajouter l'utilisateur à la requête
      req.user = {
        id: user.id,
        username: user.username,
        email: user.email,
        age_range: user.age_range,
      };

      next();
    });
  } catch (error) {
    console.error("Erreur authenticateToken:", error);
    res.status(500).json({ error: "Erreur d'authentification" });
  }
}

/**
 * Middleware optionnel pour les routes publiques qui peuvent bénéficier de l'auth
 */
async function optionalAuth(req, res, next) {
  try {
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1];

    if (token) {
      jwt.verify(token, process.env.JWT_SECRET, async (err, decoded) => {
        if (!err) {
          const user = await User.findByPk(decoded.userId);
          if (user) {
            req.user = {
              id: user.id,
              username: user.username,
              email: user.email,
              age_range: user.age_range,
            };
          }
        }
      });
    }

    next();
  } catch (error) {
    next();
  }
}

module.exports = {
  authenticateToken,
  optionalAuth,
};
