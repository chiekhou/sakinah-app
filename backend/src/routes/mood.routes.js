const express = require("express");
const router = express.Router();
const moodController = require("../controllers/mood.controller");

/**
 * @route   POST /api/mood
 * @desc    Enregistrer une entrée d'humeur
 * @access  Public (pas d'auth requise)
 * @body    { mood_level: 1-7, note?: string, user_id?: uuid }
 */
router.post("/", moodController.saveMood);

/**
 * @route   GET /api/mood/history
 * @desc    Obtenir l'historique d'humeur d'un utilisateur
 * @access  Public
 * @query   user_id, limit (default: 30)
 */
router.get("/history", moodController.getHistory);

/**
 * @route   GET /api/mood/stats
 * @desc    Obtenir les statistiques d'humeur
 * @access  Public
 * @query   user_id, days (default: 7)
 */
router.get("/stats", moodController.getStats);

/**
 * @route   GET /api/mood/today
 * @desc    Vérifier si l'utilisateur a déjà enregistré son humeur aujourd'hui
 * @access  Public
 * @query   user_id
 */
router.get("/today", moodController.getTodayMood);

module.exports = router;
