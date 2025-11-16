const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");
const bcrypt = require("bcrypt");

const User = sequelize.define(
  "User",
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    username: {
      type: DataTypes.STRING(50),
      allowNull: false,
      unique: true,
      validate: {
        len: [3, 50],
      },
    },
    email: {
      type: DataTypes.STRING(100),
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true,
      },
    },
    password_hash: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    date_of_birth: {
      type: DataTypes.DATEONLY,
      allowNull: true,
    },
    age_range: {
      type: DataTypes.ENUM("6-12", "13-17", "18-25", "25+"),
      allowNull: false,
      defaultValue: "13-17",
    },
    accessibility_settings: {
      type: DataTypes.JSONB,
      defaultValue: {
        font_size: "medium",
        high_contrast: false,
        screen_reader: false,
        simplified_language: false,
      },
    },
    last_login: {
      type: DataTypes.DATE,
      allowNull: true,
    },
  },
  {
    tableName: "users",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
  }
);

// Hook pour hasher le mot de passe avant la création
User.beforeCreate(async (user) => {
  if (user.password_hash) {
    const salt = await bcrypt.genSalt(10);
    user.password_hash = await bcrypt.hash(user.password_hash, salt);
  }
});

// Méthode pour vérifier le mot de passe
User.prototype.validatePassword = async function (password) {
  return await bcrypt.compare(password, this.password_hash);
};

// Méthode pour obtenir le JSON sécurisé (sans le mot de passe)
User.prototype.toSafeJSON = function () {
  const values = { ...this.get() };
  delete values.password_hash;
  return values;
};

module.exports = User;
