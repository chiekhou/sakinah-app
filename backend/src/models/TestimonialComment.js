const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

/**
 * Modèle TestimonialComment
 * Commentaires sur les témoignages (modérés)
 */
const TestimonialComment = sequelize.define(
  "TestimonialComment",
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    testimonial_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: "testimonials",
        key: "id",
      },
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
          msg: "Le commentaire ne peut pas être vide",
        },
        len: {
          args: [1, 1000],
          msg: "Le commentaire doit contenir entre 1 et 1000 caractères",
        },
      },
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
  },
  {
    tableName: "testimonial_comments",
    underscored: true,
    timestamps: true,
    updatedAt: false,
    indexes: [
      {
        fields: ["testimonial_id"],
      },
      {
        fields: ["user_id"],
      },
      {
        fields: ["status"],
      },
    ],
  }
);

/**
 * Méthodes d'instance
 */

/**
 * Vérifier si le commentaire est approuvé
 */
TestimonialComment.prototype.isApproved = function () {
  return this.status === "APPROVED";
};

/**
 * Méthodes statiques
 */

/**
 * Récupérer les commentaires approuvés d'un témoignage
 */
TestimonialComment.getApprovedForTestimonial = async function (testimonialId) {
  return await this.findAll({
    where: {
      testimonial_id: testimonialId,
      status: "APPROVED",
    },
    order: [["created_at", "DESC"]],
  });
};

/**
 * Récupérer les commentaires en attente de modération
 */
TestimonialComment.getPending = async function (options = {}) {
  const { limit = 50, offset = 0 } = options;

  return await this.findAll({
    where: { status: "PENDING" },
    order: [["created_at", "ASC"]],
    limit,
    offset,
  });
};

/**
 * Modérer un commentaire
 */
TestimonialComment.moderate = async function (
  commentId,
  moderatorId,
  status,
  note = null
) {
  const comment = await this.findByPk(commentId);

  if (!comment) {
    throw new Error("Commentaire non trouvé");
  }

  if (!["APPROVED", "REJECTED"].includes(status)) {
    throw new Error("Statut de modération invalide");
  }

  const oldStatus = comment.status;

  comment.status = status;
  comment.moderated_by = moderatorId;
  comment.moderated_at = new Date();
  comment.moderation_note = note;

  await comment.save();

  // Mettre à jour le compteur de commentaires du témoignage
  const Testimonial = sequelize.models.Testimonial;

  if (oldStatus !== "APPROVED" && status === "APPROVED") {
    // Nouveau commentaire approuvé
    await Testimonial.increment("comments_count", {
      where: { id: comment.testimonial_id },
    });
  } else if (oldStatus === "APPROVED" && status !== "APPROVED") {
    // Commentaire retiré
    await Testimonial.decrement("comments_count", {
      where: { id: comment.testimonial_id },
    });
  }

  return comment;
};

module.exports = TestimonialComment;
