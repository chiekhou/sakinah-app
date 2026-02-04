const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

/**
 * Modèle ParentalConsent
 * Gestion du consentement parental pour les utilisateurs mineurs
 */
const ParentalConsent = sequelize.define(
  "ParentalConsent",
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
      comment: "ID de l'utilisateur mineur",
    },

    parent_email: {
      type: DataTypes.STRING(255),
      allowNull: false,
      validate: {
        isEmail: true,
      },
    },

    consent_given: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },

    consent_date: DataTypes.DATE,
    consent_ip: DataTypes.STRING(45),

    consent_token: {
      type: DataTypes.STRING(255),
      unique: true,
    },

    consent_token_expires: DataTypes.DATE,

    revoked: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },

    revoked_date: DataTypes.DATE,
    revoked_reason: DataTypes.TEXT,

    notification_sent: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },

    notification_sent_date: DataTypes.DATE,
  },
  {
    tableName: "parental_consents",
    underscored: true,
    timestamps: true,
  }
);

/**
 * Méthodes d'instance
 */

/**
 * Vérifier si le consentement est valide
 */
ParentalConsent.prototype.isValid = function () {
  return this.consent_given && !this.revoked;
};

/**
 * Vérifier si le token est expiré
 */
ParentalConsent.prototype.isTokenExpired = function () {
  if (!this.consent_token_expires) return true;
  return new Date() > this.consent_token_expires;
};

/**
 * Méthodes statiques
 */

/**
 * Créer un nouveau consentement parental
 * @param {string} userId - ID de l'utilisateur mineur
 * @param {string} parentEmail - Email du parent
 * @returns {Promise<ParentalConsent>}
 */
ParentalConsent.createConsent = async function (userId, parentEmail) {
  const crypto = require("crypto");

  // Générer un token unique
  const token = crypto.randomBytes(32).toString("hex");

  // Token valide 7 jours
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 7);

  return await this.create({
    user_id: userId,
    parent_email: parentEmail,
    consent_token: token,
    consent_token_expires: expiresAt,
    consent_given: false,
    revoked: false,
  });
};

/**
 * Confirmer le consentement
 * @param {string} token - Token de confirmation
 * @param {string} ip - Adresse IP
 * @returns {Promise<ParentalConsent|null>}
 */
ParentalConsent.confirmConsent = async function (token, ip = null) {
  const consent = await this.findOne({
    where: { consent_token: token },
  });

  if (!consent) {
    throw new Error("Token invalide");
  }

  if (consent.isTokenExpired()) {
    throw new Error("Le lien de confirmation a expiré");
  }

  if (consent.consent_given) {
    throw new Error("Le consentement a déjà été confirmé");
  }

  // Confirmer le consentement
  consent.consent_given = true;
  consent.consent_date = new Date();
  consent.consent_ip = ip;
  consent.consent_token = null; // Invalider le token après utilisation
  consent.consent_token_expires = null;

  await consent.save();

  return consent;
};

/**
 * Révoquer le consentement
 * @param {string} userId - ID de l'utilisateur
 * @param {string} reason - Raison de la révocation
 * @returns {Promise<ParentalConsent|null>}
 */
ParentalConsent.revokeConsent = async function (userId, reason = null) {
  const consent = await this.findOne({
    where: {
      user_id: userId,
      consent_given: true,
      revoked: false,
    },
  });

  if (!consent) {
    throw new Error("Aucun consentement actif trouvé");
  }

  consent.revoked = true;
  consent.revoked_date = new Date();
  consent.revoked_reason = reason;

  await consent.save();

  return consent;
};

/**
 * Vérifier si un utilisateur a un consentement valide
 * @param {string} userId - ID de l'utilisateur
 * @returns {Promise<boolean>}
 */
ParentalConsent.hasValidConsent = async function (userId) {
  const consent = await this.findOne({
    where: {
      user_id: userId,
      consent_given: true,
      revoked: false,
    },
  });

  return consent !== null;
};

module.exports = ParentalConsent;
