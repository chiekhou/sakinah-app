const express = require("express");
const router = express.Router();
const notificationController = require("../controllers/notification.controller");
const { authenticateToken } = require("../middleware/auth.middleware");

/**
 * Toutes les routes nécessitent une authentification
 */
router.use(authenticateToken);

/**
 * @route   GET /api/notifications
 * @desc    Récupérer les notifications de l'utilisateur
 * @access  Private
 * @query   limit, offset, unread_only
 */
router.get("/", notificationController.getMyNotifications);

/**
 * @route   GET /api/notifications/unread-count
 * @desc    Compter les notifications non lues
 * @access  Private
 */
router.get("/unread-count", notificationController.getUnreadCount);

/**
 * @route   PUT /api/notifications/read-all
 * @desc    Marquer toutes les notifications comme lues
 * @access  Private
 */
router.put("/read-all", notificationController.markAllAsRead);

/**
 * @route   PUT /api/notifications/:id/read
 * @desc    Marquer une notification comme lue
 * @access  Private
 */
router.put("/:id/read", notificationController.markAsRead);

/**
 * @route   DELETE /api/notifications/:id
 * @desc    Supprimer une notification
 * @access  Private
 */
router.delete("/:id", notificationController.deleteNotification);

module.exports = router;
