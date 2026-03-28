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

    // ========== SYSTÈME DE RÔLES ==========
    role: {
      type: DataTypes.ENUM(
        "USER",
        "EDUCATEUR",
        "PSYCHOLOGUE",
        "INTERVENANT",
        "ADMIN",
        "PARENT"
      ),
      allowNull: false,
      defaultValue: "USER",
    },
    status: {
      type: DataTypes.ENUM(
        "PENDING",
        "ACTIVE",
        "SUSPENDED",
        "REJECTED",
        "PENDING_PARENTAL_CONSENT"
      ),
      allowNull: false,
      defaultValue: "PENDING",
    },

    // ========== VÉRIFICATION EMAIL ==========
    is_email_verified: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    email_verification_token: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    email_verification_expires: {
      type: DataTypes.DATE,
      allowNull: true,
    },

    // ========== RESET PASSWORD ==========
    reset_password_token: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    reset_password_expires: {
      type: DataTypes.DATE,
      allowNull: true,
    },

    // ========== PROFIL UTILISATEUR ==========
    pseudo: {
      type: DataTypes.STRING(50),
      unique: true,
      allowNull: true,
    },
    avatar_url: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    bio: {
      type: DataTypes.TEXT,
      allowNull: true,
    },

    // ========== MINEUR + CONSENTEMENT PARENTAL ==========
    is_minor: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    parent_id: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: "users",
        key: "id",
      },
    },

    // ========== PROFESSIONNELS ==========
    professional_title: {
      type: DataTypes.STRING(100),
      allowNull: true,
    },
    diploma_url: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    verification_status: {
      type: DataTypes.ENUM("PENDING", "VERIFIED", "REJECTED"),
      allowNull: true,
    },
    verified_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    verified_by: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: "users",
        key: "id",
      },
    },

    // ========== STATISTIQUES ==========
    last_login: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    last_active: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    login_count: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },

    // ========== PRÉFÉRENCES ==========
    accessibility_settings: {
      type: DataTypes.JSONB,
      defaultValue: {
        font_size: "medium",
        high_contrast: false,
        screen_reader: false,
        simplified_language: false,
      },
    },
    notification_preferences: {
      type: DataTypes.JSONB,
      defaultValue: {
        email_notifications: true,
        push_notifications: true,
        new_message: true,
        new_testimonial: true,
      },
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

// Hook pour hasher le mot de passe avant la mise à jour
User.beforeUpdate(async (user) => {
  if (user.changed("password_hash")) {
    const salt = await bcrypt.genSalt(10);
    user.password_hash = await bcrypt.hash(user.password_hash, salt);
  }
});

// Méthode pour vérifier le mot de passe
User.prototype.validatePassword = async function (password) {
  return await bcrypt.compare(password, this.password_hash);
};

// Méthode pour obtenir le JSON sécurisé (sans données sensibles)
User.prototype.toSafeJSON = function () {
  const values = { ...this.get() };
  delete values.password_hash;
  delete values.email_verification_token;
  delete values.reset_password_token;
  return values;
};

// Méthode pour obtenir un JSON public (pour affichage aux autres utilisateurs)
User.prototype.toPublicJSON = function () {
  return {
    id: this.id,
    pseudo: this.pseudo,
    avatar_url: this.avatar_url,
    bio: this.bio,
    role: this.role,
    professional_title: this.professional_title,
    verification_status: this.verification_status,
  };
};

// Méthode pour vérifier si l'utilisateur est un professionnel
User.prototype.isProfessional = function () {
  return ["EDUCATEUR", "PSYCHOLOGUE", "INTERVENANT", "ADMIN"].includes(
    this.role
  );
};

// Méthode pour vérifier si l'utilisateur est admin
User.prototype.isAdmin = function () {
  return this.role === "ADMIN";
};

// Méthode pour vérifier si le compte est actif
User.prototype.isActive = function () {
  return this.status === "ACTIVE" && this.is_email_verified;
};

module.exports = User;
