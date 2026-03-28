const express = require("express");
const router = express.Router();
const parentController = require("../controllers/parent.controller");
const { authenticate, requireRole } = require("../middleware/auth.middleware");

// Toutes les routes nécessitent d'être authentifié en tant que PARENT
const requireParent = [authenticate, requireRole(["PARENT"])];

/**
 * @route   GET /api/parent/child
 * @desc    Profil de l'enfant lié au parent connecté
 */
router.get("/child", requireParent, parentController.getChildProfile);

/**
 * @route   GET /api/parent/child/activities
 * @desc    Activités de l'enfant (humeurs, quiz, articles)
 */
router.get("/child/activities", requireParent, parentController.getChildActivities);

/**
 * @route   DELETE /api/parent/child
 * @desc    Supprimer le compte de l'enfant
 */
router.delete("/child", requireParent, parentController.deleteChildAccount);

/**
 * @route   POST /api/parent/revoke
 * @desc    Révoquer le consentement parental depuis le dashboard
 */
router.post("/revoke", requireParent, parentController.revokeConsent);

/**
 * @route   POST /api/parent/delete-request
 * @desc    Envoyer une demande de suppression de compte à l'équipe
 */
router.post("/add-child", requireParent, parentController.addChild);
router.post("/delete-request", requireParent, parentController.sendDeleteRequest);

module.exports = router;
