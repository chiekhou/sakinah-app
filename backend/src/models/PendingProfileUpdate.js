const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

/**
 * Modifications de profil soumises par un mineur, en attente d'approbation parentale.
 * Le parent approuve ou rejette depuis son espace parent.
 */
const PendingProfileUpdate = sequelize.define(
  "PendingProfileUpdate",
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    user_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: "users", key: "id" },
    },
    // Champs proposés par l'enfant (seulement ceux modifiés)
    changes: {
      type: DataTypes.JSONB,
      allowNull: false,
    },
    status: {
      type: DataTypes.STRING(20),
      defaultValue: "PENDING",
      allowNull: false,
      validate: { isIn: { args: [["PENDING", "APPROVED", "REJECTED"]] } },
    },
    rejection_reason: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    reviewed_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
  },
  {
    tableName: "pending_profile_updates",
    underscored: true,
    timestamps: true,
    indexes: [{ fields: ["user_id"] }, { fields: ["status"] }],
  }
);

module.exports = PendingProfileUpdate;
