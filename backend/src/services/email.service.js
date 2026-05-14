// Service d'envoi d'emails avec Brevo API (ex-Sendinblue)
// Utilise l'API HTTP au lieu de SMTP pour contourner les blocages des hébergeurs cloud

const BREVO_API_KEY = process.env.BREVO_API_KEY;
const FROM_EMAIL = process.env.SMTP_FROM_EMAIL || "noreply@sakinah.app";
const FROM_NAME = process.env.SMTP_FROM_NAME || "Sakinah";

// Deep link scheme pour l'app mobile
const DEEP_LINK_SCHEME = "sakinah://";

// Validation de la clé API
if (!BREVO_API_KEY) {
  if (process.env.NODE_ENV === "production") {
    console.error("❌ BREVO_API_KEY manquante en production!");
  } else {
    console.warn("⚠️ BREVO_API_KEY manquante - Les emails ne seront pas envoyés");
  }
}

/**
 * Envoyer un email via l'API Brevo
 * @param {string} to - Email destinataire
 * @param {string} subject - Sujet de l'email
 * @param {string} html - Contenu HTML de l'email
 */
async function sendEmail(to, subject, html) {
  // PRODUCTION: Logs sensibles désactivés (exposent emails destinataires)
  // console.log("==============================================");
  // console.log("📧 ENVOI D'EMAIL (API Brevo)");
  // console.log("==============================================");
  // console.log(`À: ${to}`);
  // console.log(`Sujet: ${subject}`);
  // console.log("==============================================");

  if (!BREVO_API_KEY) {
    console.warn("⚠️ BREVO_API_KEY non configurée - Email non envoyé");
    // PRODUCTION: Log sensible désactivé (expose contenu email)
    // console.log("Contenu HTML:", html.substring(0, 200) + "...");
    // console.log("==============================================\n");
    return false;
  }

  try {
    const response = await fetch("https://api.brevo.com/v3/smtp/email", {
      method: "POST",
      headers: {
        "accept": "application/json",
        "api-key": BREVO_API_KEY,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        sender: {
          name: FROM_NAME,
          email: FROM_EMAIL,
        },
        to: [{ email: to }],
        subject: subject,
        htmlContent: html,
      }),
    });

    if (!response.ok) {
      const errorData = await response.json();
      console.error("❌ Erreur API Brevo:", errorData);
      throw new Error(errorData.message || `HTTP ${response.status}`);
    }

    const result = await response.json();
    console.log("✅ [DEBUG] Email envoyé avec succès - ID:", result.messageId);
    return true;
  } catch (error) {
    console.error("❌ [DEBUG] Erreur envoi email:", error.message);
    throw error;
  }
}

/**
 * Envoyer un email de vérification
 */
async function sendVerificationEmail(email, token) {
  const verificationUrl = `${DEEP_LINK_SCHEME}verify-email/${token}`;

  // PRODUCTION: Logs sensibles désactivés (exposent email et token de vérification)
  // console.log("==============================================");
  // console.log("📧 EMAIL DE VÉRIFICATION");
  // console.log("==============================================");
  // console.log(`À: ${email}`);
  // console.log(`Lien: ${verificationUrl}`);
  // console.log("==============================================");

  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
      <h2 style="color: #2ECC71;">Bienvenue sur Sakinah ! 🌟</h2>
      <p>Pour activer ton compte, clique sur le bouton ci-dessous :</p>
      <a href="${verificationUrl}"
         style="display: inline-block; padding: 12px 24px; background-color: #2ECC71;
                color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">
        Vérifier mon email
      </a>
      <p style="color: #666; font-size: 14px;">Ce lien est valable pendant 24 heures.</p>
      <p style="color: #666; font-size: 14px;">Si tu n'as pas créé de compte, ignore cet email.</p>
      <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
      <p style="color: #999; font-size: 12px;">L'équipe Sakinah 💚</p>
    </div>
  `;

  return sendEmail(email, "Vérifie ton email - Sakinah", html);
}

/**
 * Envoyer un email de réinitialisation de mot de passe
 */
async function sendPasswordResetEmail(email, token) {
  const resetUrl = `${DEEP_LINK_SCHEME}reset-password/${token}`;

  // PRODUCTION: Logs sensibles désactivés (exposent email et token de reset)
  // console.log("==============================================");
  // console.log("🔑 EMAIL DE RÉINITIALISATION DE MOT DE PASSE");
  // console.log("==============================================");
  // console.log(`À: ${email}`);
  // console.log(`Lien: ${resetUrl}`);
  // console.log("==============================================");

  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
      <h2 style="color: #2ECC71;">Réinitialisation de mot de passe</h2>
      <p>Tu as demandé à réinitialiser ton mot de passe sur Sakinah.</p>
      <p>Clique sur le bouton ci-dessous pour créer un nouveau mot de passe :</p>
      <a href="${resetUrl}"
         style="display: inline-block; padding: 12px 24px; background-color: #2ECC71;
                color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">
        Réinitialiser mon mot de passe
      </a>
      <p style="color: #666; font-size: 14px;">Ce lien est valable pendant 1 heure.</p>
      <p style="color: #666; font-size: 14px;">Si tu n'as pas fait cette demande, ignore cet email.</p>
      <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
      <p style="color: #999; font-size: 12px;">L'équipe Sakinah 💚</p>
    </div>
  `;

  return sendEmail(email, "Réinitialise ton mot de passe - Sakinah", html);
}

/**
 * Envoyer un email de consentement parental
 */
async function sendParentalConsentEmail(parentEmail, childName, consentToken) {
  const consentUrl = `${DEEP_LINK_SCHEME}parental-consent/${consentToken}`;

  // PRODUCTION: Logs sensibles désactivés (exposent email parent et token)
  // console.log("==============================================");
  // console.log("👨‍👩‍👧 EMAIL DE CONSENTEMENT PARENTAL");
  // console.log("==============================================");
  // console.log(`À: ${parentEmail}`);
  // console.log(`Lien: ${consentUrl}`);
  // console.log("==============================================");

  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
      <h2 style="color: #2ECC71;">Consentement parental requis</h2>
      <p>Votre enfant <strong>${childName}</strong> souhaite créer un compte sur Sakinah,
         une application de bien-être mental pour les jeunes.</p>
      <p>En tant que parent/tuteur légal, votre consentement est requis pour
         que votre enfant puisse utiliser l'application.</p>
      <p>Pour donner votre consentement, cliquez sur le bouton ci-dessous :</p>
      <a href="${consentUrl}"
         style="display: inline-block; padding: 12px 24px; background-color: #2ECC71;
                color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">
        Donner mon consentement
      </a>
      <p style="color: #666; font-size: 14px;">
        Vous pourrez consulter notre politique de confidentialité et les
        mesures de sécurité mises en place pour protéger votre enfant.
      </p>
      <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
      <p style="color: #999; font-size: 12px;">L'équipe Sakinah 💚</p>
    </div>
  `;

  return sendEmail(parentEmail, "Consentement parental requis - Sakinah", html);
}

module.exports = {
  sendEmail,
  sendVerificationEmail,
  sendPasswordResetEmail,
  sendParentalConsentEmail,
};
