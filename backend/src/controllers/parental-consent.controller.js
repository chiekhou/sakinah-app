const ParentalConsent = require("../models/ParentalConsent");
const User = require("../models/User");
const { sendEmail } = require("../services/email.service");
const {
  getParentalConsentEmail,
  getChildAccountActivatedEmail,
} = require("../utils/email-templates/parental-consent-email");

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

      // Générer le lien de confirmation
      const confirmationLink = `${
        process.env.FRONTEND_URL || "http://localhost:3001"
      }/confirm-parental-consent/${consent.consent_token}`;

      // Préparer l'email
      const emailData = {
        parentEmail: parent_email,
        childUsername: user.username,
        childEmail: user.email,
        ageRange: user.age_range,
        confirmationLink: confirmationLink,
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
   * Confirmer le consentement parental (via le lien dans l'email)
   * GET /api/auth/confirm-parental-consent/:token
   */
  async confirmConsent(req, res) {
    try {
      const { token } = req.params;

      if (!token) {
        return res.status(400).json({ error: "Token manquant" });
      }

      // Récupérer l'IP du parent (pour RGPD)
      const ip = req.ip || req.connection.remoteAddress;

      // Confirmer le consentement
      const consent = await ParentalConsent.confirmConsent(token, ip);

      // Activer le compte de l'enfant
      const user = await User.findByPk(consent.user_id);
      if (user) {
        // Changer le statut de PENDING_PARENTAL_CONSENT à ACTIVE
        if (user.status === "PENDING_PARENTAL_CONSENT") {
          user.status = "ACTIVE";
          await user.save();
        }

        // Envoyer un email de confirmation à l'enfant
        try {
          const { subject, html } = getChildAccountActivatedEmail({
            childUsername: user.username,
            childEmail: user.email,
          });
          await sendEmail(user.email, subject, html);
        } catch (emailError) {
          console.error("Erreur envoi email enfant:", emailError);
          // On continue même si l'email échoue
        }
      }

      res.status(200).json({
        message: "Consentement parental confirmé avec succès",
        user_activated: user ? true : false,
        consent_date: consent.consent_date,
      });
    } catch (error) {
      console.error("Erreur confirmConsent:", error);

      if (error.message === "Token invalide") {
        return res.status(404).json({ error: "Lien de confirmation invalide" });
      }

      if (error.message === "Le lien de confirmation a expiré") {
        return res.status(410).json({
          error: "Le lien de confirmation a expiré",
          message: "Veuillez demander un nouveau lien de confirmation",
        });
      }

      if (error.message === "Le consentement a déjà été confirmé") {
        return res.status(400).json({
          error: "Le consentement a déjà été confirmé",
        });
      }

      res.status(500).json({
        error: "Erreur lors de la confirmation du consentement",
      });
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
