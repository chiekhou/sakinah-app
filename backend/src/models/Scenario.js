const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const Scenario = sequelize.define(
  "Scenario",
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
      comment: "Description courte du scénario",
    },
    theme: {
      type: DataTypes.STRING(100),
      allowNull: false,
      comment: "harcelement, stress, conflit, etc.",
    },
    steps: {
      type: DataTypes.JSONB,
      allowNull: false,
      comment: "Structure arborescente des étapes et choix",
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
    duration_minutes: {
      type: DataTypes.INTEGER,
      defaultValue: 10,
      comment: "Durée estimée en minutes",
    },
    mood_tags: {
      type: DataTypes.ARRAY(DataTypes.INTEGER),
      defaultValue: [],
      comment:
        "Niveaux d'humeur pour lesquels ce scénario est recommandé (1-7)",
    },
  },
  {
    tableName: "scenarios",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
  }
);

module.exports = Scenario;
