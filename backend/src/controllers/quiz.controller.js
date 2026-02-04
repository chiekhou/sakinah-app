const { Quiz, QuizResult } = require("../models/Quiz");
const { Op } = require("sequelize");

class QuizController {
  /**
   * Obtenir tous les quiz (avec filtres optionnels)
   * GET /api/quizzes?theme=stress&mood=3&age=15
   */
  async getAllQuizzes(req, res) {
    try {
      const { theme, mood, age } = req.query;

      // Construire les filtres
      const where = {};

      if (theme) {
        where.theme = theme;
      }

      if (age) {
        const ageNum = parseInt(age);
        where.age_target_min = { [Op.lte]: ageNum };
        where.age_target_max = { [Op.gte]: ageNum };
      }

      let quizzes = await Quiz.findAll({
        where,
        order: [["created_at", "DESC"]],
      });

      // Filtrer par mood si spécifié
      if (mood) {
        const moodNum = parseInt(mood);
        quizzes = quizzes.filter((quiz) => {
          if (!quiz.mood_tags || quiz.mood_tags.length === 0) return true;
          return quiz.mood_tags.includes(moodNum);
        });
      }

      res.json({
        count: quizzes.length,
        quizzes: quizzes.map((q) => ({
          id: q.id,
          title: q.title,
          description: q.description,
          theme: q.theme,
          difficulty: q.difficulty,
          duration_minutes: q.duration_minutes,
          question_count: q.questions ? q.questions.length : 0,
        })),
      });
    } catch (error) {
      console.error("Erreur getAllQuizzes:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération des quiz" });
    }
  }

  /**
   * Obtenir un quiz spécifique avec ses questions
   * GET /api/quizzes/:id
   */
  async getQuizById(req, res) {
    try {
      const { id } = req.params;

      const quiz = await Quiz.findByPk(id);

      if (!quiz) {
        return res.status(404).json({ error: "Quiz non trouvé" });
      }

      res.json({
        id: quiz.id,
        title: quiz.title,
        description: quiz.description,
        theme: quiz.theme,
        difficulty: quiz.difficulty,
        duration_minutes: quiz.duration_minutes,
        questions: quiz.questions,
      });
    } catch (error) {
      console.error("Erreur getQuizById:", error);
      res.status(500).json({ error: "Erreur lors de la récupération du quiz" });
    }
  }

  /**
   * Soumettre un quiz et obtenir le résultat
   * POST /api/quizzes/:id/submit
   * Body: { answers: {question_id: answer_index}, user_id?: uuid }
   */
  async submitQuiz(req, res) {
    try {
      const { id } = req.params;
      const { answers, user_id } = req.body;

      if (!answers || typeof answers !== "object") {
        return res.status(400).json({ error: "Les réponses sont requises" });
      }

      // Valider user_id : null si anonyme ou invalide
      const isValidUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
      const validUserId = user_id && isValidUUID.test(user_id) ? user_id : null;

      const quiz = await Quiz.findByPk(id);

      if (!quiz) {
        return res.status(404).json({ error: "Quiz non trouvé" });
      }

      // Calculer le score
      const questions = quiz.questions;
      let correctAnswers = 0;
      const detailedResults = [];

      questions.forEach((question, index) => {
        const userAnswer = answers[index];
        const correctAnswer = question.correct_answer;
        const isCorrect = userAnswer === correctAnswer;

        if (isCorrect) correctAnswers++;

        detailedResults.push({
          question_index: index,
          question: question.question,
          user_answer: userAnswer,
          correct_answer: correctAnswer,
          is_correct: isCorrect,
          explanation: question.explanation || null,
        });
      });

      const score = Math.round((correctAnswers / questions.length) * 100);

      // Sauvegarder le résultat
      const quizResult = await QuizResult.create({
        user_id: validUserId,
        quiz_id: id,
        score,
        answers,
        completed_at: new Date(),
      });

      // Message personnalisé selon le score
      let message = "";
      if (score >= 80) {
        message = "Excellent ! Tu maîtrises bien ce sujet ! 🎉";
      } else if (score >= 60) {
        message = "Bien joué ! Tu peux encore progresser. 👍";
      } else if (score >= 40) {
        message = "Pas mal ! Continue à apprendre. 💪";
      } else {
        message = "C'est un début ! N'hésite pas à relire les contenus. 📚";
      }

      res.json({
        result_id: quizResult.id,
        score,
        correct_answers: correctAnswers,
        total_questions: questions.length,
        message,
        details: detailedResults,
      });
    } catch (error) {
      console.error("Erreur submitQuiz:", error);
      res.status(500).json({ error: "Erreur lors de la soumission du quiz" });
    }
  }

  /**
   * Obtenir les résultats d'un utilisateur
   * GET /api/quizzes/results?user_id=xxx
   */
  async getUserResults(req, res) {
    try {
      const { user_id } = req.query;

      if (!user_id) {
        return res.status(400).json({ error: "user_id requis" });
      }

      const results = await QuizResult.findAll({
        where: { user_id },
        include: [
          {
            model: Quiz,
            attributes: ["id", "title", "theme"],
          },
        ],
        order: [["completed_at", "DESC"]],
        limit: 50,
      });

      res.json({
        count: results.length,
        results: results.map((r) => ({
          id: r.id,
          quiz_id: r.quiz_id,
          quiz_title: r.Quiz ? r.Quiz.title : "Quiz supprimé",
          score: r.score,
          completed_at: r.completed_at,
        })),
      });
    } catch (error) {
      console.error("Erreur getUserResults:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération des résultats" });
    }
  }

  /**
   * Obtenir les thèmes disponibles
   * GET /api/quizzes/themes
   */
  async getThemes(req, res) {
    try {
      const quizzes = await Quiz.findAll({
        attributes: ["theme"],
        group: ["theme"],
      });

      const themes = [...new Set(quizzes.map((q) => q.theme))];

      res.json({ themes });
    } catch (error) {
      console.error("Erreur getThemes:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération des thèmes" });
    }
  }
}

// Associer les modèles pour les includes
Quiz.hasMany(QuizResult, { foreignKey: "quiz_id" });
QuizResult.belongsTo(Quiz, { foreignKey: "quiz_id" });

module.exports = new QuizController();
