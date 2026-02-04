const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const MoodEntry = sequelize.define(
  "MoodEntry",
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    user_id: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: "users",
        key: "id",
      },
      onDelete: "CASCADE",
    },
    mood_level: {
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: {
        min: 1,
        max: 7,
      },
      comment: "1=Très mal, 7=Excellent",
    },
    note: {
      type: DataTypes.TEXT,
      allowNull: true,
      comment: "Note optionnelle de l'utilisateur",
    },
    timestamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    tableName: "mood_entries",
    timestamps: false,
    underscored: true,
    indexes: [
      {
        fields: ["user_id", "timestamp"],
      },
    ],
  }
);

module.exports = MoodEntry;
