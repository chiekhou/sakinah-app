const express = require("express");
const router = express.Router();
const testimonialController = require("../controllers/testimonial.controller");
const { authenticateToken } = require("../middleware/auth.middleware");
const {
  requireSafetyAcknowledgment,
  requireParentalContentPermission,
} = require("../middleware/childSafety.middleware");

/**
 * @route   POST /api/testimonials
 * @desc    Créer un témoignage
 * @access  Private (connecté uniquement)
 */
router.post(
  "/",
  authenticateToken,
  requireSafetyAcknowledgment,
  requireParentalContentPermission,
  testimonialController.create
);

/**
 * @route   GET /api/testimonials
 * @desc    Récupérer les témoignages approuvés (fil public)
 * @access  Public (mais enrichi si connecté)
 */
router.get("/", testimonialController.getAll);

/**
 * @route   GET /api/testimonials/my
 * @desc    Récupérer mes témoignages
 * @access  Private
 */
router.get("/my", authenticateToken, testimonialController.getMyTestimonials);

/**
 * @route   GET /api/testimonials/:id
 * @desc    Récupérer un témoignage par ID
 * @access  Public (mais enrichi si connecté)
 */
router.get("/:id", testimonialController.getById);

/**
 * @route   POST /api/testimonials/:id/like
 * @desc    Liker/Unlike un témoignage
 * @access  Private
 */
router.post("/:id/like", authenticateToken, testimonialController.toggleLike);

/**
 * @route   POST /api/testimonials/:id/comment
 * @desc    Commenter un témoignage
 * @access  Private
 */
router.post(
  "/:id/comment",
  authenticateToken,
  requireSafetyAcknowledgment,
  requireParentalContentPermission,
  testimonialController.addComment
);

module.exports = router;
