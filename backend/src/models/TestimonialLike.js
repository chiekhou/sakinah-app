const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

/**
 * Modèle TestimonialLike
 * Likes sur les témoignages
 */
const TestimonialLike = sequelize.define(
  "TestimonialLike",
  {
    user_id: {
      type: DataTypes.UUID,
      allowNull: false,
      primaryKey: true,
      references: {
        model: "users",
        key: "id",
      },
    },
    testimonial_id: {
      type: DataTypes.UUID,
      allowNull: false,
      primaryKey: true,
      references: {
        model: "testimonials",
        key: "id",
      },
    },
  },
  {
    tableName: "testimonial_likes",
    underscored: true,
    timestamps: true,
    updatedAt: false,
    indexes: [
      {
        fields: ["testimonial_id"],
      },
    ],
  }
);

/**
 * Méthodes statiques
 */

/**
 * Toggle like (ajouter ou retirer)
 */
TestimonialLike.toggle = async function (userId, testimonialId) {
  const Testimonial = require("./Testimonial");

  const existing = await this.findOne({
    where: {
      user_id: userId,
      testimonial_id: testimonialId,
    },
  });

  if (existing) {
    // Unlike
    await existing.destroy();

    // Décrémenter le compteur
    await Testimonial.decrement("likes_count", {
      where: { id: testimonialId },
    });

    return { liked: false };
  } else {
    // Like
    await this.create({
      user_id: userId,
      testimonial_id: testimonialId,
    });

    // Incrémenter le compteur
    await Testimonial.increment("likes_count", {
      where: { id: testimonialId },
    });

    return { liked: true };
  }
};

/**
 * Vérifier si un utilisateur a liké un témoignage
 */
TestimonialLike.hasLiked = async function (userId, testimonialId) {
  const like = await this.findOne({
    where: {
      user_id: userId,
      testimonial_id: testimonialId,
    },
  });

  return like !== null;
};

module.exports = TestimonialLike;
