const Article = require("../models/Article");
const { Quiz } = require("../models/Quiz");
const Scenario = require("../models/Scenario");
const { Op } = require("sequelize");

class ContentController {
  /**
   * Obtenir tous les articles (avec filtres)
   * GET /api/content/articles?theme=stress&mood=3&featured=true
   */
  async getAllArticles(req, res) {
    try {
      const { theme, mood, featured, age } = req.query;

      const where = {};

      if (theme) {
        where.theme = theme;
      }

      if (featured === "true") {
        where.is_featured = true;
      }

      if (age) {
        const ageNum = parseInt(age);
        where.age_target_min = { [Op.lte]: ageNum };
        where.age_target_max = { [Op.gte]: ageNum };
      }

      let articles = await Article.findAll({
        where,
        order: [["created_at", "DESC"]],
      });

      // Filtrer par mood si spécifié
      if (mood) {
        const moodNum = parseInt(mood);
        articles = articles.filter((article) => {
          if (!article.mood_tags || article.mood_tags.length === 0) return true;
          return article.mood_tags.includes(moodNum);
        });
      }

      res.json({
        count: articles.length,
        articles: articles.map((a) => ({
          id: a.id,
          title: a.title,
          summary: a.summary,
          theme: a.theme,
          reading_time_minutes: a.reading_time_minutes,
          media_url: a.media_url,
          is_featured: a.is_featured,
        })),
      });
    } catch (error) {
      console.error("Erreur getAllArticles:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération des articles" });
    }
  }

  /**
   * Obtenir un article spécifique
   * GET /api/content/articles/:id
   */
  async getArticleById(req, res) {
    try {
      const { id } = req.params;

      const article = await Article.findByPk(id);

      if (!article) {
        return res.status(404).json({ error: "Article non trouvé" });
      }

      res.json({
        id: article.id,
        title: article.title,
        content: article.content,
        summary: article.summary,
        theme: article.theme,
        reading_time_minutes: article.reading_time_minutes,
        media_url: article.media_url,
      });
    } catch (error) {
      console.error("Erreur getArticleById:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération de l'article" });
    }
  }

  /**
   * Obtenir tous les scénarios (mises en situation)
   * GET /api/content/scenarios?theme=harcelement&mood=2
   */
  async getAllScenarios(req, res) {
    try {
      const { theme, mood, age } = req.query;

      const where = {};

      if (theme) {
        where.theme = theme;
      }

      if (age) {
        const ageNum = parseInt(age);
        where.age_target_min = { [Op.lte]: ageNum };
        where.age_target_max = { [Op.gte]: ageNum };
      }

      let scenarios = await Scenario.findAll({
        where,
        order: [["created_at", "DESC"]],
        attributes: { exclude: ["steps"] }, // Ne pas renvoyer les steps complets dans la liste
      });

      // Filtrer par mood si spécifié
      if (mood) {
        const moodNum = parseInt(mood);
        scenarios = scenarios.filter((scenario) => {
          if (!scenario.mood_tags || scenario.mood_tags.length === 0)
            return true;
          return scenario.mood_tags.includes(moodNum);
        });
      }

      res.json({
        count: scenarios.length,
        scenarios: scenarios.map((s) => ({
          id: s.id,
          title: s.title,
          description: s.description,
          theme: s.theme,
          duration_minutes: s.duration_minutes,
        })),
      });
    } catch (error) {
      console.error("Erreur getAllScenarios:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération des scénarios" });
    }
  }

  /**
   * Obtenir un scénario spécifique avec ses étapes
   * GET /api/content/scenarios/:id
   */
  async getScenarioById(req, res) {
    try {
      const { id } = req.params;

      const scenario = await Scenario.findByPk(id);

      if (!scenario) {
        return res.status(404).json({ error: "Scénario non trouvé" });
      }

      res.json({
        id: scenario.id,
        title: scenario.title,
        description: scenario.description,
        theme: scenario.theme,
        duration_minutes: scenario.duration_minutes,
        steps: scenario.steps,
      });
    } catch (error) {
      console.error("Erreur getScenarioById:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération du scénario" });
    }
  }

  /**
   * Obtenir les contenus recommandés selon l'humeur
   * GET /api/content/recommended?mood=3&age=15&limit=10
   */
  async getRecommendedContent(req, res) {
    try {
      const { mood, age = 15, limit = 10 } = req.query;

      if (!mood) {
        return res.status(400).json({ error: "Le paramètre mood est requis" });
      }

      const moodNum = parseInt(mood);
      const ageNum = parseInt(age);
      const limitNum = parseInt(limit);

      // Filtres communs
      const ageFilter = {
        age_target_min: { [Op.lte]: ageNum },
        age_target_max: { [Op.gte]: ageNum },
      };

      // Récupérer des articles
      let articles = await Article.findAll({
        where: ageFilter,
        limit: Math.ceil(limitNum / 3),
        order: [["created_at", "DESC"]],
      });

      // Fonction pour déterminer les moods compatibles
      const getCompatibleMoods = (mood) => {
        if (mood <= 2) return [1, 2, 3]; // Très mal / Mal
        if (mood === 3) return [2, 3, 4]; // Pas terrible
        if (mood === 4) return [3, 4, 5]; // Correct
        if (mood === 5) return [4, 5, 6]; // Bien
        if (mood === 6) return [5, 6, 7]; // Très bien
        if (mood === 7) return [5, 6, 7]; // Excellent
        return [mood];
      };

      const compatibleMoods = getCompatibleMoods(moodNum);

      // Filtrer par mood avec compatibilité
      articles = articles.filter((a) => {
        if (!a.mood_tags || a.mood_tags.length === 0) return true;
        return a.mood_tags.some((tag) => compatibleMoods.includes(tag));
      });

      // Récupérer des quiz
      let quizzes = await Quiz.findAll({
        where: ageFilter,
        limit: Math.ceil(limitNum / 3),
        order: [["created_at", "DESC"]],
        attributes: { exclude: ["questions"] },
      });

      quizzes = quizzes.filter((q) => {
        if (!q.mood_tags || q.mood_tags.length === 0) return true;
        return q.mood_tags.some((tag) => compatibleMoods.includes(tag));
      });

      // Récupérer des scénarios
      let scenarios = await Scenario.findAll({
        where: ageFilter,
        limit: Math.ceil(limitNum / 3),
        order: [["created_at", "DESC"]],
        attributes: { exclude: ["steps"] },
      });

      scenarios = scenarios.filter((s) => {
        if (!s.mood_tags || s.mood_tags.length === 0) return true;
        return s.mood_tags.some((tag) => compatibleMoods.includes(tag));
      });

      // Construire la réponse avec des recommandations personnalisées
      let message = "";
      if (moodNum <= 2) {
        message =
          "Prends soin de toi. Voici des contenus qui peuvent t'aider à te sentir mieux. 💙";
      } else if (moodNum === 3) {
        message =
          "Chaque jour est une nouvelle chance. Voici des contenus pour t'aider à aller mieux. 🌸";
      } else if (moodNum === 4) {
        message =
          "Continue comme ça ! Voici des contenus pour aller encore mieux. 🌟";
      } else if (moodNum === 5) {
        message =
          "Tu te sens bien ! Voici des contenus pour renforcer ton bien-être. 😊";
      } else if (moodNum === 6) {
        message =
          "C'est génial ! Voici des contenus pour maintenir cette belle énergie. ✨";
      } else {
        // mood === 7
        message =
          "Tu es au top ! Voici des contenus pour cultiver cette excellente humeur. 🌟💚";
      }

      res.json({
        message,
        mood_level: moodNum,
        recommendations: {
          articles: articles.slice(0, 3).map((a) => ({
            id: a.id,
            title: a.title,
            summary: a.summary,
            theme: a.theme,
            type: "article",
            reading_time_minutes: a.reading_time_minutes,
          })),
          quizzes: quizzes.slice(0, 3).map((q) => ({
            id: q.id,
            title: q.title,
            description: q.description,
            theme: q.theme,
            type: "quiz",
            duration_minutes: q.duration_minutes,
          })),
          scenarios: scenarios.slice(0, 2).map((s) => ({
            id: s.id,
            title: s.title,
            description: s.description,
            theme: s.theme,
            type: "scenario",
            duration_minutes: s.duration_minutes,
          })),
        },
      });
    } catch (error) {
      console.error("Erreur getRecommendedContent:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération des recommandations" });
    }
  }

  /**
   * Obtenir tous les thèmes disponibles
   * GET /api/content/themes
   */
  async getAllThemes(req, res) {
    try {
      const [articles, quizzes, scenarios] = await Promise.all([
        Article.findAll({ attributes: ["theme"], group: ["theme"] }),
        Quiz.findAll({ attributes: ["theme"], group: ["theme"] }),
        Scenario.findAll({ attributes: ["theme"], group: ["theme"] }),
      ]);

      const allThemes = new Set([
        ...articles.map((a) => a.theme),
        ...quizzes.map((q) => q.theme),
        ...scenarios.map((s) => s.theme),
      ]);

      res.json({
        themes: Array.from(allThemes).sort(),
      });
    } catch (error) {
      console.error("Erreur getAllThemes:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération des thèmes" });
    }
  }
}

module.exports = new ContentController();
