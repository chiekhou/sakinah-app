const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const Quiz = sequelize.define(
  "Quiz",
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
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    theme: {
      type: DataTypes.STRING(100),
      allowNull: false,
      comment: "stress, estime, harcelement, emotions, sommeil, etc.",
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
    questions: {
      type: DataTypes.JSONB,
      allowNull: false,
      comment: "Array of questions with answers and correct answer",
    },
    difficulty: {
      type: DataTypes.ENUM("facile", "moyen", "difficile"),
      defaultValue: "moyen",
    },
    duration_minutes: {
      type: DataTypes.INTEGER,
      defaultValue: 5,
      comment: "Durée estimée en minutes",
    },
    mood_tags: {
      type: DataTypes.ARRAY(DataTypes.INTEGER),
      defaultValue: [],
      comment: "Niveaux d'humeur pour lesquels ce quiz est recommandé (1-7)",
    },
  },
  {
    tableName: "quizzes",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
  }
);

const QuizResult = sequelize.define(
  "QuizResult",
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    user_id: {
      type: DataTypes.UUID,
      allowNull: true,
      comment: "Null pour les utilisateurs anonymes",
    },
    quiz_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: "quizzes",
        key: "id",
      },
      onDelete: "CASCADE",
    },
    score: {
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: {
        min: 0,
        max: 100,
      },
    },
    answers: {
      type: DataTypes.JSONB,
      allowNull: true,
      comment: "Réponses de l'utilisateur",
    },
    completed_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    tableName: "quiz_results",
    timestamps: false,
    underscored: true,
  }
);

module.exports = { Quiz, QuizResult };
