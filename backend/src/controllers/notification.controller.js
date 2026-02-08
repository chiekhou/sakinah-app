const Notification = require("../models/Notification");
const FCMToken = require("../models/FCMToken");

/**
 * Controller pour gérer les notifications
 */
class NotificationController {
  /**
   * Récupérer les notifications de l'utilisateur
   * GET /api/notifications
   */
  async getMyNotifications(req, res) {
    try {
      const userId = req.user.id;
      const { limit = 50, offset = 0, unread_only = "false" } = req.query;

      const notifications = await Notification.getForUser(userId, {
        limit: parseInt(limit),
        offset: parseInt(offset),
        unreadOnly: unread_only === "true",
      });

      const unreadCount = await Notification.countUnreadForUser(userId);

      res.json({
        notifications: notifications.map((n) => ({
          id: n.id,
          type: n.type,
          title: n.title,
          message: n.message,
          related_type: n.related_type,
          related_id: n.related_id,
          is_read: n.is_read,
          read_at: n.read_at,
          metadata: n.metadata,
          created_at: n.created_at,
        })),
        unread_count: unreadCount,
        total: notifications.length,
      });
    } catch (error) {
      console.error("Erreur getMyNotifications:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération des notifications" });
    }
  }

  /**
   * Compter les notifications non lues
   * GET /api/notifications/unread-count
   */
  async getUnreadCount(req, res) {
    try {
      const userId = req.user.id;
      const count = await Notification.countUnreadForUser(userId);

      res.json({ unread_count: count });
    } catch (error) {
      console.error("Erreur getUnreadCount:", error);
      res
        .status(500)
        .json({ error: "Erreur lors du comptage des notifications" });
    }
  }

  /**
   * Marquer une notification comme lue
   * PUT /api/notifications/:id/read
   */
  async markAsRead(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id;

      const notification = await Notification.markAsRead(id, userId);

      res.json({
        message: "Notification marquée comme lue",
        notification: {
          id: notification.id,
          is_read: notification.is_read,
          read_at: notification.read_at,
        },
      });
    } catch (error) {
      console.error("Erreur markAsRead:", error);

      if (error.message === "Notification non trouvée") {
        return res.status(404).json({ error: error.message });
      }

      res
        .status(500)
        .json({ error: "Erreur lors de la mise à jour de la notification" });
    }
  }

  /**
   * Marquer toutes les notifications comme lues
   * PUT /api/notifications/read-all
   */
  async markAllAsRead(req, res) {
    try {
      const userId = req.user.id;

      await Notification.markAllAsReadForUser(userId);

      res.json({
        message: "Toutes les notifications ont été marquées comme lues",
      });
    } catch (error) {
      console.error("Erreur markAllAsRead:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la mise à jour des notifications" });
    }
  }

  /**
   * Supprimer une notification
   * DELETE /api/notifications/:id
   */
  async deleteNotification(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id;

      const notification = await Notification.findOne({
        where: {
          id: id,
          user_id: userId,
        },
      });

      if (!notification) {
        return res.status(404).json({ error: "Notification non trouvée" });
      }

      await notification.destroy();

      res.json({
        message: "Notification supprimée",
      });
    } catch (error) {
      console.error("Erreur deleteNotification:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la suppression de la notification" });
    }
  }

  /**
   * Enregistrer un token FCM
   * POST /api/notifications/fcm-token
   */
  async registerFCMToken(req, res) {
    try {
      const userId = req.user.id;
      const { fcm_token, device_type } = req.body;

      if (!fcm_token) {
        return res.status(400).json({ error: "Token FCM requis" });
      }

      await FCMToken.registerToken(userId, fcm_token, device_type);

      res.json({
        message: "Token FCM enregistré avec succès",
      });
    } catch (error) {
      console.error("Erreur registerFCMToken:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de l'enregistrement du token" });
    }
  }

  /**
   * Désactiver un token FCM (logout)
   * DELETE /api/notifications/fcm-token
   */
  async unregisterFCMToken(req, res) {
    try {
      const { fcm_token } = req.body;

      if (!fcm_token) {
        return res.status(400).json({ error: "Token FCM requis" });
      }

      await FCMToken.deactivateToken(fcm_token);

      res.json({
        message: "Token FCM désactivé avec succès",
      });
    } catch (error) {
      console.error("Erreur unregisterFCMToken:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la désactivation du token" });
    }
  }
}

module.exports = new NotificationController();
