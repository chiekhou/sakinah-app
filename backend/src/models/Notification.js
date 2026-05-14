const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

/**
 * Modèle Notification
 * Notifications utilisateurs
 */
const Notification = sequelize.define(
  "Notification",
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    user_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: "users",
        key: "id",
      },
    },
    type: {
      type: DataTypes.STRING(50),
      allowNull: false,
      validate: {
        isIn: {
          args: [
            [
              "TESTIMONIAL_APPROVED",
              "TESTIMONIAL_REJECTED",
              "COMMENT_APPROVED",
              "COMMENT_REJECTED",
              "TESTIMONIAL_LIKED",
              "TESTIMONIAL_COMMENTED",
              "COMMENT_REPLIED",
              "SYSTEM_MESSAGE",
            ],
          ],
          msg: "Type de notification invalide",
        },
      },
    },
    title: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    message: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    related_type: {
      type: DataTypes.STRING(50),
      allowNull: true,
      validate: {
        isIn: {
          args: [["TESTIMONIAL", "COMMENT", "USER", null]],
          msg: "Type d'entité invalide",
        },
      },
    },
    related_id: {
      type: DataTypes.UUID,
      allowNull: true,
    },
    is_read: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      allowNull: false,
    },
    read_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    metadata: {
      type: DataTypes.JSONB,
      allowNull: true,
    },
  },
  {
    tableName: "notifications",
    underscored: true,
    timestamps: true,
    updatedAt: false,
    indexes: [
      {
        fields: ["user_id"],
      },
      {
        fields: ["user_id", "is_read"],
        where: {
          is_read: false,
        },
      },
      {
        fields: ["type"],
      },
      {
        fields: ["created_at"],
      },
    ],
  }
);

/**
 * Méthodes statiques
 */

/**
 * Créer une notification
 */
Notification.createNotification = async function (data) {
  return await this.create({
    user_id: data.userId,
    type: data.type,
    title: data.title,
    message: data.message,
    related_type: data.relatedType || null,
    related_id: data.relatedId || null,
    metadata: data.metadata || null,
  });
};

/**
 * Notification : Témoignage approuvé
 */
Notification.testimonialApproved = async function (userId, testimonialId) {
  return await this.createNotification({
    userId,
    type: "TESTIMONIAL_APPROVED",
    title: "🎉 Témoignage publié !",
    message:
      "Ton témoignage a été approuvé par notre équipe et est maintenant visible par la communauté. Merci de partager ton expérience ! 💚",
    relatedType: "TESTIMONIAL",
    relatedId: testimonialId,
  });
};

/**
 * Notification : Témoignage rejeté
 */
Notification.testimonialRejected = async function (
  userId,
  testimonialId,
  reason
) {
  return await this.createNotification({
    userId,
    type: "TESTIMONIAL_REJECTED",
    title: "Témoignage non publié",
    message: `Ton témoignage n'a pas pu être publié.\n\nRaison : ${reason}\n\nN'hésite pas à partager à nouveau en respectant nos règles de bienveillance. 💚`,
    relatedType: "TESTIMONIAL",
    relatedId: testimonialId,
    metadata: { reason },
  });
};

/**
 * Notification : Commentaire approuvé
 */
Notification.commentApproved = async function (
  userId,
  commentId,
  testimonialId
) {
  return await this.createNotification({
    userId,
    type: "COMMENT_APPROVED",
    title: "💬 Commentaire publié !",
    message: "Ton commentaire a été approuvé et est maintenant visible.",
    relatedType: "COMMENT",
    relatedId: commentId,
    metadata: { testimonialId },
  });
};

/**
 * Notification : Commentaire rejeté
 */
Notification.commentRejected = async function (
  userId,
  commentId,
  testimonialId,
  reason
) {
  return await this.createNotification({
    userId,
    type: "COMMENT_REJECTED",
    title: "Commentaire non publié",
    message: `Ton commentaire n'a pas pu être publié.\n\nRaison : ${reason}`,
    relatedType: "COMMENT",
    relatedId: commentId,
    metadata: { testimonialId, reason },
  });
};

/**
 * Notification : Témoignage liké
 */
Notification.testimonialLiked = async function (
  userId,
  testimonialId,
  likerPseudo
) {
  return await this.createNotification({
    userId,
    type: "TESTIMONIAL_LIKED",
    title: "❤️ Nouveau like !",
    message: `${likerPseudo} a aimé ton témoignage.`,
    relatedType: "TESTIMONIAL",
    relatedId: testimonialId,
  });
};

/**
 * Notification : Nouveau commentaire sur témoignage
 */
Notification.testimonialCommented = async function (
  userId,
  testimonialId,
  commenterPseudo
) {
  return await this.createNotification({
    userId,
    type: "TESTIMONIAL_COMMENTED",
    title: "💬 Nouveau commentaire !",
    message: `${commenterPseudo} a commenté ton témoignage.`,
    relatedType: "TESTIMONIAL",
    relatedId: testimonialId,
  });
};

/**
 * Récupérer les notifications d'un utilisateur
 */
Notification.getForUser = async function (userId, options = {}) {
  const { limit = 50, offset = 0, unreadOnly = false } = options;

  const where = { user_id: userId };
  if (unreadOnly) {
    where.is_read = false;
  }

  return await this.findAll({
    where,
    order: [["created_at", "DESC"]],
    limit,
    offset,
  });
};

/**
 * Compter les notifications non lues
 */
Notification.countUnreadForUser = async function (userId) {
  return await this.count({
    where: {
      user_id: userId,
      is_read: false,
    },
  });
};

/**
 * Marquer comme lu
 */
Notification.markAsRead = async function (notificationId, userId) {
  const notification = await this.findOne({
    where: {
      id: notificationId,
      user_id: userId,
    },
  });

  if (!notification) {
    throw new Error("Notification non trouvée");
  }

  if (!notification.is_read) {
    notification.is_read = true;
    notification.read_at = new Date();
    await notification.save();
  }

  return notification;
};

/**
 * Marquer toutes comme lues
 */
Notification.markAllAsReadForUser = async function (userId) {
  await this.update(
    {
      is_read: true,
      read_at: new Date(),
    },
    {
      where: {
        user_id: userId,
        is_read: false,
      },
    }
  );
};

/**
 * Journal de supervision parentale
 * Crée une entrée de supervision pour le parent d'un mineur.
 * @param {string} parentId  - ID du compte parent
 * @param {string} childId   - ID du compte enfant
 * @param {string} childPseudo - Pseudo de l'enfant
 * @param {'PROFILE_UPDATE'|'TESTIMONIAL'|'COMMENT'} action - Type d'action
 */
Notification.supervisionLog = async function (
  parentId,
  childId,
  childPseudo,
  action
) {
  const labels = {
    PROFILE_UPDATE: {
      title: "✏️ Modification de profil",
      message: `${childPseudo} a modifié ses informations personnelles.`,
    },
    TESTIMONIAL: {
      title: "📝 Témoignage publié",
      message: `${childPseudo} a soumis un témoignage (en attente de modération).`,
    },
    COMMENT: {
      title: "💬 Commentaire posté",
      message: `${childPseudo} a posté un commentaire (en attente de modération).`,
    },
  };

  const { title, message } = labels[action] || {
    title: "👁️ Activité détectée",
    message: `${childPseudo} a effectué une action sur l'application.`,
  };

  return await this.createNotification({
    userId: parentId,
    type: "SYSTEM_MESSAGE",
    title,
    message,
    related_type: "USER",
    related_id: childId,
    metadata: { supervision: true, action, childId, childPseudo },
  });
};

/**
 * Récupérer les logs de supervision pour un parent et un enfant donné
 */
Notification.getSupervisionLogs = async function (parentId, childId, limit = 30) {
  const { Op } = require("sequelize");
  return await this.findAll({
    where: {
      user_id: parentId,
      type: "SYSTEM_MESSAGE",
      related_id: childId,
    },
    order: [["created_at", "DESC"]],
    limit,
  });
};

module.exports = Notification;
