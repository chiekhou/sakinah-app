/**
 * Middlewares de sécurité enfant — requis par la politique Google Play Familles
 */

/**
 * Bloque un mineur qui n'a pas encore accepté le rappel de sécurité.
 * L'app mobile doit afficher le rappel et appeler POST /api/safety/acknowledge.
 */
async function requireSafetyAcknowledgment(req, res, next) {
  const user = req.user;
  if (!user || !user.is_minor) return next();

  if (!user.safety_reminder_acknowledged_at) {
    return res.status(403).json({
      error: "SAFETY_REMINDER_REQUIRED",
      message:
        "Tu dois lire et accepter le rappel de sécurité avant de continuer.",
    });
  }
  next();
}

/**
 * Bloque un mineur dont le parent n'a pas activé can_post_content.
 * Le parent active cette permission depuis son espace parent.
 */
function requireParentalContentPermission(req, res, next) {
  const user = req.user;
  if (!user || !user.is_minor) return next();

  const canPost = user.accessibility_settings?.can_post_content;
  if (!canPost) {
    return res.status(403).json({
      error: "PARENTAL_PERMISSION_REQUIRED",
      message:
        "Ton parent doit autoriser les publications depuis son espace parent.",
    });
  }
  next();
}

module.exports = {
  requireSafetyAcknowledgment,
  requireParentalContentPermission,
};
