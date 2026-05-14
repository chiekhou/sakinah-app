const express = require("express");
const router = express.Router();
const safetyController = require("../controllers/safety.controller");
const { authenticate } = require("../middleware/auth.middleware");

/**
 * @route   GET /api/safety/status
 * @desc    Statut de sécurité de l'utilisateur (rappel accepté, permissions, supervision)
 * @access  Private
 */
router.get("/status", authenticate, safetyController.getStatus);

/**
 * @route   POST /api/safety/acknowledge
 * @desc    Enregistre que le mineur a lu et accepté le rappel de sécurité
 * @access  Private
 */
router.post("/acknowledge", authenticate, safetyController.acknowledgeReminder);

/**
 * @route   POST /api/safety/request-profile-update
 * @desc    Notifie le parent qu'un mineur veut modifier ses infos personnelles
 * @access  Private (mineurs uniquement)
 */
router.post(
  "/request-profile-update",
  authenticate,
  safetyController.requestProfileUpdate
);

module.exports = router;
