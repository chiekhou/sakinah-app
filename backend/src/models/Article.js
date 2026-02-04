const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const Article = sequelize.define(
  "Article",
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    title: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    content: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    summary: {
      type: DataTypes.STRING(500),
      allowNull: true,
      comment: "Résumé court pour l'aperçu",
    },
    theme: {
      type: DataTypes.STRING(100),
      allowNull: false,
      comment: "stress, estime, harcelement, emotions, sommeil, etc.",
    },
    mood_tags: {
      type: DataTypes.ARRAY(DataTypes.INTEGER),
      defaultValue: [],
      comment:
        "Niveaux d'humeur pour lesquels cet article est recommandé (1-7)",
    },
    age_target_min: {
      type: DataTypes.INTEGER,
      allowNull: true,
      defaultValue: 6,
    },
    age_target_max: {
      type: DataTypes.INTEGER,
      allowNull: true,
      defaultValue: 25,
    },
    media_url: {
      type: DataTypes.STRING(500),
      allowNull: true,
      comment: "URL de l'image ou vidéo associée",
    },
    reading_time_minutes: {
      type: DataTypes.INTEGER,
      defaultValue: 3,
      comment: "Temps de lecture estimé en minutes",
    },
    is_featured: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      comment: "Article mis en avant",
    },
  },
  {
    tableName: "articles",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
  }
);

module.exports = Article;
