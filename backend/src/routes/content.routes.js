const express = require("express");
const router = express.Router();
const contentController = require("../controllers/content.controller");

/**
 * ARTICLES
 */

/**
 * @route   GET /api/content/articles
 * @desc    Obtenir tous les articles (avec filtres)
 * @access  Public
 * @query   theme, mood, featured, age
 */
router.get("/articles", contentController.getAllArticles);

/**
 * @route   GET /api/content/articles/:id
 * @desc    Obtenir un article spécifique
 * @access  Public
 */
router.get("/articles/:id", contentController.getArticleById);

/**
 * SCENARIOS
 */

/**
 * @route   GET /api/content/scenarios
 * @desc    Obtenir tous les scénarios (mises en situation)
 * @access  Public
 * @query   theme, mood, age
 */
router.get("/scenarios", contentController.getAllScenarios);

/**
 * @route   GET /api/content/scenarios/:id
 * @desc    Obtenir un scénario spécifique avec ses étapes
 * @access  Public
 */
router.get("/scenarios/:id", contentController.getScenarioById);

/**
 * RECOMMANDATIONS
 */

/**
 * @route   GET /api/content/recommended
 * @desc    Obtenir les contenus recommandés selon l'humeur
 * @access  Public
 * @query   mood (required), age, limit
 */
router.get("/recommended", contentController.getRecommendedContent);

/**
 * THEMES
 */

/**
 * @route   GET /api/content/themes
 * @desc    Obtenir tous les thèmes disponibles
 * @access  Public
 */
router.get("/themes", contentController.getAllThemes);

module.exports = router;
