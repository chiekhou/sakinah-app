const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const FCMToken = sequelize.define(
  "FCMToken",
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
    token: {
      type: DataTypes.STRING(500),
      allowNull: false,
    },
    device_type: {
      type: DataTypes.ENUM("android", "ios", "web"),
      allowNull: true,
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
  },
  {
    tableName: "fcm_tokens",
    underscored: true,
    timestamps: true,
    indexes: [
      {
        unique: true,
        fields: ["token"],
      },
      {
        fields: ["user_id"],
      },
    ],
  }
);

/**
 * Register or update FCM token for user
 */
FCMToken.registerToken = async function (userId, token, deviceType = null) {
  // Check if token exists
  const existing = await this.findOne({ where: { token } });

  if (existing) {
    // Update existing token
    existing.user_id = userId;
    existing.device_type = deviceType;
    existing.is_active = true;
    await existing.save();
    return existing;
  }

  // Create new token
  return await this.create({
    user_id: userId,
    token: token,
    device_type: deviceType,
    is_active: true,
  });
};

/**
 * Get all active tokens for a user
 */
FCMToken.getTokensForUser = async function (userId) {
  return await this.findAll({
    where: {
      user_id: userId,
      is_active: true,
    },
  });
};

/**
 * Deactivate a token
 */
FCMToken.deactivateToken = async function (token) {
  await this.update({ is_active: false }, { where: { token: token } });
};

/**
 * Remove invalid tokens (called when Firebase returns errors)
 */
FCMToken.removeInvalidTokens = async function (tokens) {
  if (tokens.length === 0) return;
  await this.destroy({
    where: {
      token: tokens,
    },
  });
};

module.exports = FCMToken;
