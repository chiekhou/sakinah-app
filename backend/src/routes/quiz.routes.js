const express = require("express");
const router = express.Router();
const quizController = require("../controllers/quiz.controller");

/**
 * @route   GET /api/quizzes
 * @desc    Obtenir tous les quiz (avec filtres optionnels)
 * @access  Public
 * @query   theme, mood, age
 */
router.get("/", quizController.getAllQuizzes);

/**
 * @route   GET /api/quizzes/themes
 * @desc    Obtenir tous les thèmes disponibles
 * @access  Public
 */
router.get("/themes", quizController.getThemes);

/**
 * @route   GET /api/quizzes/results
 * @desc    Obtenir les résultats d'un utilisateur
 * @access  Public
 * @query   user_id
 */
router.get("/results", quizController.getUserResults);

/**
 * @route   GET /api/quizzes/:id
 * @desc    Obtenir un quiz spécifique avec ses questions
 * @access  Public
 */
router.get("/:id", quizController.getQuizById);

/**
 * @route   POST /api/quizzes/:id/submit
 * @desc    Soumettre un quiz et obtenir le résultat
 * @access  Public
 * @body    { answers: {question_index: answer_index}, user_id?: uuid }
 */
router.post("/:id/submit", quizController.submitQuiz);

module.exports = router;
