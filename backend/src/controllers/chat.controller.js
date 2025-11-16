const Conversation = require("../models/Conversation");
const chatAIService = require("../services/chatAI.service");

class ChatController {
  /**
   * Envoyer un message au chat IA
   * POST /api/chat/message
   */
  async sendMessage(req, res) {
    try {
      const { message, mood_context } = req.body;
      const userId = req.user.id; // Ajouté par le middleware d'auth

      if (!message || message.trim().length === 0) {
        return res
          .status(400)
          .json({ error: "Le message ne peut pas être vide" });
      }

      // Récupérer ou créer la conversation
      let conversation = await Conversation.findOne({ user_id: userId });

      if (!conversation) {
        conversation = new Conversation({
          user_id: userId,
          messages: [],
        });
      }

      // Limiter l'historique à 20 derniers messages pour le contexte
      const recentHistory = conversation.messages.slice(-20);

      // Générer la réponse de l'IA
      const aiResult = await chatAIService.generateResponse(
        message,
        recentHistory,
        mood_context
      );

      // Ajouter le message utilisateur
      conversation.messages.push({
        role: "user",
        content: message,
        mood_context: mood_context || null,
        timestamp: new Date(),
      });

      // Ajouter la réponse de l'IA
      conversation.messages.push({
        role: "assistant",
        content: aiResult.response,
        timestamp: new Date(),
      });

      // Sauvegarder
      await conversation.save();

      res.json({
        response: aiResult.response,
        isEmergency: aiResult.isEmergency,
        suggestions: chatAIService.getSuggestions(mood_context),
      });
    } catch (error) {
      console.error("Erreur sendMessage:", error);
      res.status(500).json({ error: "Erreur lors de l'envoi du message" });
    }
  }

  /**
   * Récupérer l'historique de conversation
   * GET /api/chat/history
   */
  async getHistory(req, res) {
    try {
      const userId = req.user.id;
      const { limit = 50 } = req.query;

      const conversation = await Conversation.findOne({ user_id: userId });

      if (!conversation) {
        return res.json({ messages: [] });
      }

      // Retourner les N derniers messages
      const messages = conversation.messages.slice(-parseInt(limit));

      res.json({ messages });
    } catch (error) {
      console.error("Erreur getHistory:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération de l'historique" });
    }
  }

  /**
   * Supprimer l'historique de conversation
   * DELETE /api/chat/history
   */
  async clearHistory(req, res) {
    try {
      const userId = req.user.id;

      await Conversation.deleteOne({ user_id: userId });

      res.json({ message: "Historique supprimé avec succès" });
    } catch (error) {
      console.error("Erreur clearHistory:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la suppression de l'historique" });
    }
  }

  /**
   * Obtenir des suggestions de conversation
   * GET /api/chat/suggestions
   */
  async getSuggestions(req, res) {
    try {
      const { mood } = req.query;
      const moodLevel = mood ? parseInt(mood) : 4;

      const suggestions = chatAIService.getSuggestions(moodLevel);

      res.json({ suggestions });
    } catch (error) {
      console.error("Erreur getSuggestions:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération des suggestions" });
    }
  }
}

module.exports = new ChatController();
