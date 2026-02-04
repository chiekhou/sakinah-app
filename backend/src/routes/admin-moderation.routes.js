const express = require("express");
const router = express.Router();
const adminModerationController = require("../controllers/admin-moderation.controller");
const {
  authenticateToken,
  requireAdmin,
} = require("../middleware/auth.middleware");

/**
 * Toutes les routes nécessitent authentification + rôle ADMIN
 */
router.use(authenticateToken);
router.use(requireAdmin);

/**
 * @route   GET /api/admin/moderation/stats
 * @desc    Statistiques de modération
 * @access  Admin
 */
router.get("/moderation/stats", adminModerationController.getModerationStats);

/**
 * @route   GET /api/admin/testimonials/pending
 * @desc    Récupérer les témoignages en attente
 * @access  Admin
 */
router.get(
  "/testimonials/pending",
  adminModerationController.getPendingTestimonials
);

/**
 * @route   PUT /api/admin/testimonials/:id/moderate
 * @desc    Modérer un témoignage (approuver/rejeter)
 * @access  Admin
 * @body    { status: 'APPROVED' | 'REJECTED', moderation_note?: string }
 */
router.put(
  "/testimonials/:id/moderate",
  adminModerationController.moderateTestimonial
);

/**
 * @route   GET /api/admin/comments/pending
 * @desc    Récupérer les commentaires en attente
 * @access  Admin
 */
router.get("/comments/pending", adminModerationController.getPendingComments);

/**
 * @route   PUT /api/admin/comments/:id/moderate
 * @desc    Modérer un commentaire (approuver/rejeter)
 * @access  Admin
 * @body    { status: 'APPROVED' | 'REJECTED', moderation_note?: string }
 */
router.put("/comments/:id/moderate", adminModerationController.moderateComment);

module.exports = router;
