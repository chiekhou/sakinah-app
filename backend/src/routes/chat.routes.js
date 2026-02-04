const express = require("express");
const router = express.Router();
const chatController = require("../controllers/chat.controller");

/**
 * @route   POST /api/chat/message
 * @desc    Envoyer un message au chat IA
 * @access  Public
 * @body    { message: string, mood_context?: 1-7, user_id?: uuid }
 */
router.post("/message", chatController.sendMessage);

/**
 * @route   GET /api/chat/history
 * @desc    Obtenir l'historique de conversation
 * @access  Public
 * @query   user_id, limit (default: 50)
 */
router.get("/history", chatController.getHistory);

/**
 * @route   DELETE /api/chat/history
 * @desc    Supprimer l'historique de conversation
 * @access  Public
 * @body    { user_id: uuid }
 */
router.delete("/history", chatController.clearHistory);

/**
 * @route   GET /api/chat/suggestions
 * @desc    Obtenir des suggestions de conversation selon l'humeur
 * @access  Public
 * @query   mood (1-7)
 */
router.get("/suggestions", chatController.getSuggestions);

module.exports = router;
