const jwt = require("jsonwebtoken");
const ParentalConsent = require("../models/ParentalConsent");
const User = require("../models/User");
const { sendEmail } = require("../services/email.service");
const {
  getParentalConsentEmail,
  getChildAccountActivatedEmail,
} = require("../utils/email-templates/parental-consent-email");

const JWT_SECRET = process.env.JWT_SECRET || "votre_secret_jwt_super_securise_a_changer";
const JWT_EXPIRES_IN = "7d";

/**
 * Controller pour gérer le consentement parental
 */
class ParentalConsentController {
  /**
   * Envoyer une demande de consentement parental
   * POST /api/auth/send-parental-consent
   */
  async sendConsentRequest(req, res) {
    try {
      const { user_id, parent_email } = req.body;

      // Validation
      if (!user_id || !parent_email) {
        return res.status(400).json({
          error: "user_id et parent_email sont requis",
        });
      }

      // Vérifier que l'utilisateur existe et est mineur
      const user = await User.findByPk(user_id);
      if (!user) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }

      if (!user.is_minor) {
        return res.status(400).json({
          error:
            "Cet utilisateur n'est pas mineur, pas besoin de consentement parental",
        });
      }

      // Vérifier si un consentement existe déjà
      const existingConsent = await ParentalConsent.findOne({
        where: { user_id: user_id },
      });

      if (
        existingConsent &&
        existingConsent.consent_given &&
        !existingConsent.revoked
      ) {
        return res.status(400).json({
          error:
            "Le consentement parental a déjà été donné pour cet utilisateur",
        });
      }

      // Créer ou mettre à jour le consentement
      let consent;
      if (existingConsent) {
        // Régénérer un token si le précédent a expiré
        const crypto = require("crypto");
        const newToken = crypto.randomBytes(32).toString("hex");
        const expiresAt = new Date();
        expiresAt.setDate(expiresAt.getDate() + 7);

        existingConsent.consent_token = newToken;
        existingConsent.consent_token_expires = expiresAt;
        existingConsent.parent_email = parent_email;
        existingConsent.notification_sent = false;
        await existingConsent.save();
        consent = existingConsent;
      } else {
        consent = await ParentalConsent.createConsent(user_id, parent_email);
      }

      // Générer les liens de confirmation et révocation
      const baseUrl = process.env.FRONTEND_URL || "http://localhost:3001";
      const confirmationLink = `${baseUrl}/confirm-parental-consent/${consent.consent_token}`;
      const revocationLink = `${process.env.API_URL || "http://localhost:3000"}/api/auth/revoke-parental-consent/${consent.consent_token}`;

      // Préparer l'email
      const emailData = {
        parentEmail: parent_email,
        childUsername: user.username,
        childEmail: user.email,
        ageRange: user.age_range,
        confirmationLink,
        revocationLink,
      };

      const { subject, html } = getParentalConsentEmail(emailData);

      // Envoyer l'email
      try {
        await sendEmail(parent_email, subject, html);

        // Marquer comme envoyé
        consent.notification_sent = true;
        consent.notification_sent_date = new Date();
        await consent.save();

        res.status(200).json({
          message: "Email de consentement parental envoyé avec succès",
          parent_email: parent_email,
          expires_in_days: 7,
        });
      } catch (emailError) {
        console.error("Erreur envoi email parent:", emailError);
        res.status(500).json({
          error: "Erreur lors de l'envoi de l'email au parent",
          details: emailError.message,
        });
      }
    } catch (error) {
      console.error("Erreur sendConsentRequest:", error);
      res.status(500).json({
        error: "Erreur lors de l'envoi de la demande de consentement",
      });
    }
  }

  /**
   * Vérifier le token et retourner les infos de l'enfant (pré-remplissage de la page)
   * GET /api/auth/confirm-parental-consent/:token
   */
  async getConsentInfo(req, res) {
    try {
      const { token } = req.params;

      const consent = await ParentalConsent.findOne({
        where: { consent_token: token },
      });

      if (!consent) {
        return res.status(404).json({ error: "Lien de confirmation invalide" });
      }

      if (consent.consent_given) {
        return res.status(400).json({ error: "Le consentement a déjà été confirmé" });
      }

      if (consent.revoked) {
        return res.status(400).json({ error: "Ce consentement a été révoqué" });
      }

      if (new Date() > new Date(consent.consent_token_expires)) {
        return res.status(410).json({ error: "Le lien de confirmation a expiré" });
      }

      const child = await User.findByPk(consent.user_id);
      if (!child) {
        return res.status(404).json({ error: "Compte enfant introuvable" });
      }

      res.status(200).json({
        valid: true,
        parent_email: consent.parent_email,
        child: {
          username: child.username,
          age_range: child.age_range,
        },
      });
    } catch (error) {
      console.error("Erreur getConsentInfo:", error);
      res.status(500).json({ error: "Erreur lors de la vérification du lien" });
    }
  }

  /**
   * Confirmer le consentement + créer le compte parent
   * POST /api/auth/confirm-parental-consent/:token
   * body: { password }
   */
  async confirmConsent(req, res) {
    try {
      const { token } = req.params;
      const { password } = req.body;

      if (!token || !password) {
        return res.status(400).json({ error: "Token et mot de passe requis" });
      }

      if (password.length < 8) {
        return res.status(400).json({ error: "Le mot de passe doit faire au moins 8 caractères" });
      }

      const ip = req.ip || req.connection.remoteAddress;
      const consent = await ParentalConsent.confirmConsent(token, ip);

      const child = await User.findByPk(consent.user_id);
      if (!child) {
        return res.status(404).json({ error: "Compte enfant introuvable" });
      }

      // Vérifier si un compte parent existe déjà avec cet email
      let parentUser = await User.findOne({ where: { email: consent.parent_email } });

      if (!parentUser) {
        // Créer le compte parent
        const crypto = require("crypto");
        const parentUsername = `parent_${crypto.randomBytes(4).toString("hex")}`;

        parentUser = await User.create({
          username: parentUsername,
          email: consent.parent_email,
          password_hash: password,
          age_range: "25+",
          role: "PARENT",
          status: "ACTIVE",
          is_email_verified: true,
          is_minor: false,
          pseudo: `Parent_${crypto.randomBytes(4).toString("hex")}`,
        });
      }

      // Lier l'enfant au parent
      child.parent_id = parentUser.id;
      child.status = "ACTIVE";
      child.is_email_verified = true;
      await child.save();

      // Envoyer un email de confirmation à l'enfant
      try {
        const { subject, html } = getChildAccountActivatedEmail({
          childUsername: child.username,
          childEmail: child.email,
        });
        await sendEmail(child.email, subject, html);
      } catch (emailError) {
        console.error("Erreur envoi email enfant:", emailError);
      }

      // Générer un JWT pour le parent
      const token_jwt = jwt.sign(
        { id: parentUser.id, email: parentUser.email, role: "PARENT" },
        JWT_SECRET,
        { expiresIn: JWT_EXPIRES_IN }
      );

      res.status(200).json({
        message: "Consentement confirmé et compte parent créé avec succès",
        token: token_jwt,
        parent: {
          id: parentUser.id,
          email: parentUser.email,
          role: parentUser.role,
        },
        child: {
          id: child.id,
          username: child.username,
        },
      });
    } catch (error) {
      console.error("Erreur confirmConsent:", error);

      if (error.message === "Token invalide") {
        return res.status(404).json({ error: "Lien de confirmation invalide" });
      }
      if (error.message === "Le lien de confirmation a expiré") {
        return res.status(410).json({ error: "Le lien de confirmation a expiré" });
      }
      if (error.message === "Le consentement a déjà été confirmé") {
        return res.status(400).json({ error: "Le consentement a déjà été confirmé" });
      }

      res.status(500).json({ error: "Erreur lors de la confirmation du consentement" });
    }
  }

  /**
   * Révoquer le consentement via le lien dans l'email (sans authentification)
   * GET /api/auth/revoke-parental-consent/:token
   */
  async revokeConsentByToken(req, res) {
    try {
      const { token } = req.params;

      const consent = await ParentalConsent.findOne({
        where: { consent_token: token },
      });

      if (!consent) {
        return res.status(404).json({ error: "Lien invalide" });
      }

      if (consent.revoked) {
        return res.status(400).json({ error: "Ce consentement a déjà été révoqué" });
      }

      await ParentalConsent.revokeConsent(consent.user_id, "Refus via email");

      const child = await User.findByPk(consent.user_id);
      if (child) {
        child.status = "SUSPENDED";
        await child.save();
      }

      res.status(200).json({
        message: "Consentement révoqué. Le compte de votre enfant a été désactivé.",
      });
    } catch (error) {
      console.error("Erreur revokeConsentByToken:", error);
      res.status(500).json({ error: "Erreur lors de la révocation" });
    }
  }

  /**
   * Révoquer le consentement parental
   * POST /api/auth/revoke-parental-consent
   */
  async revokeConsent(req, res) {
    try {
      const { user_id, parent_email, reason } = req.body;

      // Validation
      if (!user_id || !parent_email) {
        return res.status(400).json({
          error: "user_id et parent_email sont requis",
        });
      }

      // Vérifier que l'email du parent correspond
      const consent = await ParentalConsent.findOne({
        where: {
          user_id: user_id,
          parent_email: parent_email,
          consent_given: true,
          revoked: false,
        },
      });

      if (!consent) {
        return res.status(404).json({
          error:
            "Aucun consentement actif trouvé pour cet utilisateur et cet email parent",
        });
      }

      // Révoquer le consentement
      await ParentalConsent.revokeConsent(user_id, reason);

      // Désactiver le compte de l'enfant
      const user = await User.findByPk(user_id);
      if (user) {
        user.status = "SUSPENDED";
        await user.save();
      }

      res.status(200).json({
        message: "Consentement parental révoqué avec succès",
        user_suspended: user ? true : false,
      });
    } catch (error) {
      console.error("Erreur revokeConsent:", error);
      res.status(500).json({
        error: "Erreur lors de la révocation du consentement",
      });
    }
  }

  /**
   * Vérifier le statut du consentement parental
   * GET /api/auth/parental-consent-status/:userId
   */
  async getConsentStatus(req, res) {
    try {
      const { userId } = req.params;

      const user = await User.findByPk(userId);
      if (!user) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }

      if (!user.is_minor) {
        return res.status(200).json({
          is_minor: false,
          consent_required: false,
          message: "Utilisateur majeur, pas de consentement parental requis",
        });
      }

      const consent = await ParentalConsent.findOne({
        where: { user_id: userId },
      });

      if (!consent) {
        return res.status(200).json({
          is_minor: true,
          consent_required: true,
          consent_given: false,
          notification_sent: false,
          message: "Consentement parental non demandé",
        });
      }

      res.status(200).json({
        is_minor: true,
        consent_required: true,
        consent_given: consent.consent_given,
        revoked: consent.revoked,
        notification_sent: consent.notification_sent,
        parent_email: consent.parent_email,
        consent_date: consent.consent_date,
        token_expired: consent.isTokenExpired(),
        message: consent.isValid()
          ? "Consentement parental valide"
          : consent.revoked
          ? "Consentement révoqué"
          : consent.isTokenExpired()
          ? "Lien de confirmation expiré"
          : "En attente de confirmation",
      });
    } catch (error) {
      console.error("Erreur getConsentStatus:", error);
      res.status(500).json({
        error: "Erreur lors de la récupération du statut du consentement",
      });
    }
  }
}

module.exports = new ParentalConsentController();
