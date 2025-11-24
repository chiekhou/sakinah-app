const express = require("express");
const router = express.Router();
const emergencyController = require("../controllers/emergency.controller");

/**
 * @route   GET /api/emergency/resources
 * @desc    Obtenir toutes les ressources d'urgence (numéros, sites web)
 * @access  Public
 */
router.get("/resources", emergencyController.getResources);

/**
 * @route   GET /api/emergency/advice
 * @desc    Obtenir des conseils en cas de crise
 * @access  Public
 */
router.get("/advice", emergencyController.getAdvice);

module.exports = router;
