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
      const apiUrl = process.env.API_URL || "http://localhost:3000";
      const confirmationLink = `${apiUrl}/api/auth/confirm-parental-consent/${consent.consent_token}`;
      const revocationLink = `${apiUrl}/api/auth/revoke-parental-consent/${consent.consent_token}`;

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

      const renderError = (message) => {
        res.status(400).send(`<!DOCTYPE html><html lang="fr"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Sakinah</title><style>body{font-family:'Segoe UI',sans-serif;background:#F8F9FA;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0}.card{background:#fff;border-radius:16px;padding:40px;max-width:460px;width:90%;text-align:center;box-shadow:0 4px 20px rgba(0,0,0,.08)}.icon{font-size:56px;margin-bottom:16px}.title{color:#E74C3C;font-size:22px;font-weight:700;margin-bottom:12px}.msg{color:#7F8C8D;font-size:15px}</style></head><body><div class="card"><div class="icon">❌</div><h1 class="title">Lien invalide</h1><p class="msg">${message}</p></div></body></html>`);
      };

      if (!consent) return renderError("Ce lien de confirmation est invalide ou a déjà été utilisé.");
      if (consent.consent_given) return renderError("Le consentement parental a déjà été confirmé.");
      if (consent.revoked) return renderError("Ce lien a été révoqué.");
      if (new Date() > new Date(consent.consent_token_expires)) return renderError("Ce lien a expiré. Demandez à votre enfant de renvoyer une invitation.");

      const child = await User.findByPk(consent.user_id);
      if (!child) return renderError("Le compte de l'enfant est introuvable.");

      const apiUrl = process.env.API_URL || "http://localhost:3000";

      res.send(`<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Consentement parental - Sakinah</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #F8F9FA; display: flex; align-items: center; justify-content: center; min-height: 100vh; padding: 20px; }
    .card { background: #fff; border-radius: 16px; padding: 40px 36px; max-width: 480px; width: 100%; box-shadow: 0 4px 20px rgba(0,0,0,.08); }
    .header { text-align: center; margin-bottom: 28px; }
    .logo { font-size: 48px; margin-bottom: 8px; }
    h1 { color: #2ECC71; font-size: 24px; font-weight: 700; margin-bottom: 6px; }
    .subtitle { color: #7F8C8D; font-size: 14px; }
    .info-box { background: #FEF5E7; border-left: 4px solid #F39C12; border-radius: 8px; padding: 16px 20px; margin-bottom: 24px; }
    .info-box p { font-size: 14px; color: #2C3E50; margin: 4px 0; }
    .info-box strong { color: #E67E22; }
    label { display: block; font-size: 14px; font-weight: 600; color: #2C3E50; margin-bottom: 8px; }
    input[type=password] { width: 100%; padding: 14px 16px; border: 2px solid #E0E0E0; border-radius: 10px; font-size: 15px; outline: none; transition: border-color .2s; }
    input[type=password]:focus { border-color: #2ECC71; }
    .hint { font-size: 12px; color: #95A5A6; margin-top: 6px; margin-bottom: 20px; }
    button { width: 100%; padding: 15px; background: linear-gradient(135deg, #2ECC71, #27AE60); color: #fff; border: none; border-radius: 12px; font-size: 16px; font-weight: 600; cursor: pointer; transition: opacity .2s; }
    button:hover { opacity: .9; }
    button:disabled { opacity: .6; cursor: not-allowed; }
    .msg { margin-top: 16px; padding: 12px 16px; border-radius: 10px; font-size: 14px; display: none; text-align: center; }
    .msg.error { background: #FDEDEC; color: #E74C3C; }
    .msg.success { background: #D5F4E6; color: #27AE60; }
    .footer { text-align: center; margin-top: 24px; font-size: 12px; color: #BDC3C7; }
  </style>
</head>
<body>
  <div class="card">
    <div class="header">
      <div class="logo">💚</div>
      <h1>Sakinah</h1>
      <p class="subtitle">Consentement parental</p>
    </div>
    <div class="info-box">
      <p>Votre enfant <strong>${child.username}</strong> souhaite rejoindre Sakinah.</p>
      <p style="margin-top:8px">Tranche d'âge : <strong>${child.age_range} ans</strong></p>
      <p style="margin-top:4px">Votre email : <strong>${consent.parent_email}</strong></p>
    </div>
    <p style="font-size:14px;color:#2C3E50;margin-bottom:20px">
      Pour confirmer votre consentement, créez votre mot de passe parent ci-dessous. Vous pourrez ensuite suivre l'activité de votre enfant depuis l'application.
    </p>
    <label for="password">Choisissez votre mot de passe</label>
    <input type="password" id="password" placeholder="Minimum 8 caractères" autocomplete="new-password">
    <p class="hint">8 caractères minimum</p>
    <button id="btn" onclick="submitConsent()">✅ Confirmer le consentement</button>
    <div class="msg" id="msg"></div>
    <div class="footer">💚 Sakinah — Ta sérénité, notre priorité</div>
  </div>
  <script>
    async function submitConsent() {
      const password = document.getElementById('password').value;
      const btn = document.getElementById('btn');
      const msg = document.getElementById('msg');
      msg.style.display = 'none';
      if (!password || password.length < 8) {
        msg.className = 'msg error';
        msg.textContent = 'Le mot de passe doit faire au moins 8 caractères.';
        msg.style.display = 'block';
        return;
      }
      btn.disabled = true;
      btn.textContent = 'Confirmation en cours…';
      try {
        const res = await fetch('${apiUrl}/api/auth/confirm-parental-consent/${token}', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ password })
        });
        const data = await res.json();
        if (res.ok) {
          document.querySelector('.card').innerHTML = '<div style="text-align:center;padding:20px"><div style="font-size:64px;margin-bottom:16px">🎉</div><h2 style="color:#2ECC71;font-size:22px;margin-bottom:12px">Consentement confirmé !</h2><p style="color:#7F8C8D;font-size:15px">Le compte de <strong>${child.username}</strong> est maintenant actif. Vous recevrez un email de confirmation.<br><br>Téléchargez Sakinah pour suivre l\'activité de votre enfant.</p></div>';
        } else {
          msg.className = 'msg error';
          msg.textContent = data.error || 'Une erreur est survenue.';
          msg.style.display = 'block';
          btn.disabled = false;
          btn.textContent = '✅ Confirmer le consentement';
        }
      } catch (e) {
        msg.className = 'msg error';
        msg.textContent = 'Erreur de connexion. Veuillez réessayer.';
        msg.style.display = 'block';
        btn.disabled = false;
        btn.textContent = '✅ Confirmer le consentement';
      }
    }
  </script>
</body>
</html>`);
    } catch (error) {
      console.error("Erreur getConsentInfo:", error);
      res.status(500).send(`<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Erreur</title></head><body style="font-family:sans-serif;text-align:center;padding:60px"><h2 style="color:#E74C3C">Erreur serveur</h2><p style="color:#7F8C8D">Veuillez réessayer plus tard.</p></body></html>`);
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
