const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

/**
 * Modèle Testimonial
 * Témoignages des utilisateurs avec modération
 */
const Testimonial = sequelize.define(
  "Testimonial",
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
    content: {
      type: DataTypes.TEXT,
      allowNull: false,
      validate: {
        notEmpty: {
          msg: "Le contenu ne peut pas être vide",
        },
        len: {
          args: [10, 5000],
          msg: "Le témoignage doit contenir entre 10 et 5000 caractères",
        },
      },
    },
    mood_level: {
      type: DataTypes.INTEGER,
      allowNull: true,
      validate: {
        min: 1,
        max: 7,
      },
    },
    is_anonymous: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
      allowNull: false,
    },

    // Modération
    status: {
      type: DataTypes.STRING(20),
      defaultValue: "PENDING",
      allowNull: false,
      validate: {
        isIn: {
          args: [["PENDING", "APPROVED", "REJECTED"]],
          msg: "Statut invalide",
        },
      },
    },
    moderated_by: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: "users",
        key: "id",
      },
    },
    moderated_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    moderation_note: {
      type: DataTypes.TEXT,
      allowNull: true,
    },

    // Signalement de crise
    is_critical: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      allowNull: false,
    },
    critical_notified_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },

    // Engagement
    likes_count: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      allowNull: false,
    },
    comments_count: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      allowNull: false,
    },
    reports_count: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      allowNull: false,
    },
  },
  {
    tableName: "testimonials",
    underscored: true,
    timestamps: true,
    indexes: [
      {
        fields: ["user_id"],
      },
      {
        fields: ["status"],
      },
      {
        fields: ["created_at"],
      },
    ],
  }
);

/**
 * Méthodes d'instance
 */

/**
 * Vérifier si le témoignage est approuvé
 */
Testimonial.prototype.isApproved = function () {
  return this.status === "APPROVED";
};

/**
 * Vérifier si le témoignage est en attente
 */
Testimonial.prototype.isPending = function () {
  return this.status === "PENDING";
};

/**
 * Vérifier si l'utilisateur peut voir ce témoignage
 */
Testimonial.prototype.canBeViewedBy = function (userId) {
  // Admin peut tout voir
  // Auteur peut voir son propre témoignage
  // Autres : seulement si APPROVED
  return this.status === "APPROVED" || this.user_id === userId;
};

/**
 * Méthodes statiques
 */

/**
 * Récupérer les témoignages approuvés
 */
Testimonial.getApproved = async function (options = {}) {
  const { limit = 50, offset = 0 } = options;

  return await this.findAll({
    where: { status: "APPROVED" },
    order: [["created_at", "DESC"]],
    limit,
    offset,
  });
};

/**
 * Récupérer les témoignages en attente de modération
 */
Testimonial.getPending = async function (options = {}) {
  const { limit = 50, offset = 0 } = options;

  return await this.findAll({
    where: { status: "PENDING" },
    order: [["created_at", "ASC"]],
    limit,
    offset,
  });
};

/**
 * Modérer un témoignage
 */
Testimonial.moderate = async function (
  testimonialId,
  moderatorId,
  status,
  note = null
) {
  const testimonial = await this.findByPk(testimonialId);

  if (!testimonial) {
    throw new Error("Témoignage non trouvé");
  }

  if (!["APPROVED", "REJECTED"].includes(status)) {
    throw new Error("Statut de modération invalide");
  }

  testimonial.status = status;
  testimonial.moderated_by = moderatorId;
  testimonial.moderated_at = new Date();
  testimonial.moderation_note = note;

  await testimonial.save();

  return testimonial;
};

module.exports = Testimonial;
