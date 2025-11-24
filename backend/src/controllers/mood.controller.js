const MoodEntry = require("../models/MoodEntry");
const User = require("../models/User");

class MoodController {
  /**
   * Enregistrer une entrée d'humeur
   * POST /api/mood
   * Body: { mood_level: 1-7, note?: string, user_id?: uuid }
   */
  async saveMood(req, res) {
    try {
      const { mood_level, note, user_id } = req.body;

      // Validation
      if (!mood_level || mood_level < 1 || mood_level > 7) {
        return res.status(400).json({
          error: "Le niveau d'humeur doit être entre 1 et 7",
        });
      }

      // Pour un utilisateur non connecté, on utilise un user_id temporaire stocké localement
      // ou on crée un utilisateur anonyme
      let finalUserId = user_id;

      // Si pas d'user_id fourni, on utilise un ID anonyme ou on skip (pour les sessions non authentifiées)
      // Pour l'instant, on accepte sans user_id pour permettre l'utilisation anonyme
      if (!finalUserId) {
        // On pourrait créer un user anonyme ici ou simplement logger sans user
        finalUserId = null; // On permet les entrées anonymes
      }

      // Créer l'entrée d'humeur
      const moodEntry = await MoodEntry.create({
        user_id: finalUserId,
        mood_level: parseInt(mood_level),
        note: note || null,
        timestamp: new Date(),
      });

      res.status(201).json({
        message: "Humeur enregistrée avec succès",
        mood: {
          id: moodEntry.id,
          mood_level: moodEntry.mood_level,
          note: moodEntry.note,
          timestamp: moodEntry.timestamp,
        },
      });
    } catch (error) {
      console.error("Erreur saveMood:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de l'enregistrement de l'humeur" });
    }
  }

  /**
   * Obtenir l'historique d'humeur
   * GET /api/mood/history?user_id=xxx&limit=30
   */
  async getHistory(req, res) {
    try {
      const { user_id, limit = 30 } = req.query;

      if (!user_id) {
        return res.status(400).json({
          error: "user_id requis pour récupérer l'historique",
        });
      }

      const moods = await MoodEntry.findAll({
        where: { user_id },
        order: [["timestamp", "DESC"]],
        limit: parseInt(limit),
      });

      res.json({
        moods: moods.map((m) => ({
          id: m.id,
          mood_level: m.mood_level,
          note: m.note,
          timestamp: m.timestamp,
        })),
      });
    } catch (error) {
      console.error("Erreur getHistory:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération de l'historique" });
    }
  }

  /**
   * Obtenir les statistiques d'humeur
   * GET /api/mood/stats?user_id=xxx&days=7
   */
  async getStats(req, res) {
    try {
      const { user_id, days = 7 } = req.query;

      if (!user_id) {
        return res.status(400).json({
          error: "user_id requis pour les statistiques",
        });
      }

      const daysAgo = new Date();
      daysAgo.setDate(daysAgo.getDate() - parseInt(days));

      const moods = await MoodEntry.findAll({
        where: {
          user_id,
          timestamp: {
            [require("sequelize").Op.gte]: daysAgo,
          },
        },
        order: [["timestamp", "ASC"]],
      });

      if (moods.length === 0) {
        return res.json({
          average: 0,
          count: 0,
          trend: "none",
          moods: [],
        });
      }

      // Calculer la moyenne
      const sum = moods.reduce((acc, m) => acc + m.mood_level, 0);
      const average = sum / moods.length;

      // Calculer la tendance (amélioration/stable/détérioration)
      let trend = "stable";
      if (moods.length >= 2) {
        const firstHalf = moods.slice(0, Math.floor(moods.length / 2));
        const secondHalf = moods.slice(Math.floor(moods.length / 2));

        const firstAvg =
          firstHalf.reduce((acc, m) => acc + m.mood_level, 0) /
          firstHalf.length;
        const secondAvg =
          secondHalf.reduce((acc, m) => acc + m.mood_level, 0) /
          secondHalf.length;

        if (secondAvg > firstAvg + 0.5) trend = "amélioration";
        else if (secondAvg < firstAvg - 0.5) trend = "détérioration";
      }

      res.json({
        average: parseFloat(average.toFixed(2)),
        count: moods.length,
        trend,
        moods: moods.map((m) => ({
          mood_level: m.mood_level,
          timestamp: m.timestamp,
        })),
      });
    } catch (error) {
      console.error("Erreur getStats:", error);
      res.status(500).json({ error: "Erreur lors du calcul des statistiques" });
    }
  }

  /**
   * Obtenir l'humeur du jour
   * GET /api/mood/today?user_id=xxx
   */
  async getTodayMood(req, res) {
    try {
      const { user_id } = req.query;

      if (!user_id) {
        return res.json({ hasMoodToday: false });
      }

      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const todayMood = await MoodEntry.findOne({
        where: {
          user_id,
          timestamp: {
            [require("sequelize").Op.gte]: today,
          },
        },
        order: [["timestamp", "DESC"]],
      });

      if (!todayMood) {
        return res.json({ hasMoodToday: false });
      }

      res.json({
        hasMoodToday: true,
        mood: {
          id: todayMood.id,
          mood_level: todayMood.mood_level,
          note: todayMood.note,
          timestamp: todayMood.timestamp,
        },
      });
    } catch (error) {
      console.error("Erreur getTodayMood:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération de l'humeur du jour" });
    }
  }
}

module.exports = new MoodController();
