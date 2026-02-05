// Service d'envoi d'emails avec Brevo (ex-Sendinblue)
const nodemailer = require("nodemailer");

// Configuration centralisée
const SMTP_CONFIG = {
  host: process.env.SMTP_HOST,
  port: parseInt(process.env.SMTP_PORT) || 587,
  secure: process.env.SMTP_SECURE === "true",
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
};

const FROM_EMAIL = process.env.SMTP_FROM_EMAIL || "noreply@sakinah.app";
const FROM_NAME = process.env.SMTP_FROM_NAME || "Sakinah";
const FRONTEND_URL =
  process.env.FRONTEND_URL || "https://sakinah-app.onrender.com";

// Validation des variables d'environnement
const requiredEnvVars = ["SMTP_HOST", "SMTP_PORT", "SMTP_USER", "SMTP_PASS"];
const missingVars = requiredEnvVars.filter((v) => !process.env[v]);

if (missingVars.length > 0) {
  if (process.env.NODE_ENV === "production") {
    console.error(
      `❌ Variables SMTP manquantes en production: ${missingVars.join(", ")}`,
    );
  } else {
    console.warn(
      `⚠️ Variables SMTP manquantes: ${missingVars.join(", ")} - Les emails ne seront pas envoyés`,
    );
  }
}

// Transporter réutilisable (singleton)
let transporter = null;

function getTransporter() {
  if (!transporter && !missingVars.length) {
    transporter = nodemailer.createTransport(SMTP_CONFIG);
  }
  return transporter;
}

/**
 * Méthode générique pour envoyer un email
 * @param {string} to - Email destinataire
 * @param {string} subject - Sujet de l'email
 * @param {string} html - Contenu HTML de l'email
 */
async function sendEmail(to, subject, html) {
  console.log("==============================================");
  console.log("📧 ENVOI D'EMAIL");
  console.log("==============================================");
  console.log(`À: ${to}`);
  console.log(`Sujet: ${subject}`);
  console.log("==============================================");

  const transport = getTransporter();

  if (!transport) {
    console.warn("⚠️ SMTP non configuré - Email non envoyé");
    console.log("Contenu HTML:", html.substring(0, 200) + "...");
    console.log("==============================================\n");
    return false;
  }

  try {
    await transport.sendMail({
      from: `"${FROM_NAME}" <${FROM_EMAIL}>`,
      to: to,
      subject: subject,
      html: html,
    });
    console.log("✅ Email envoyé avec succès");
    console.log("==============================================\n");
    return true;
  } catch (error) {
    console.error("❌ Erreur envoi email:", error.message);
    console.log("==============================================\n");
    throw error;
  }
}

/**
 * Envoyer un email de vérification
 */
async function sendVerificationEmail(email, token) {
  const verificationUrl = `${FRONTEND_URL}/verify-email/${token}`;

  console.log("==============================================");
  console.log("📧 EMAIL DE VÉRIFICATION");
  console.log("==============================================");
  console.log(`À: ${email}`);
  console.log(`Lien: ${verificationUrl}`);
  console.log("==============================================");

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
  const resetUrl = `${FRONTEND_URL}/reset-password/${token}`;

  console.log("==============================================");
  console.log("🔑 EMAIL DE RÉINITIALISATION DE MOT DE PASSE");
  console.log("==============================================");
  console.log(`À: ${email}`);
  console.log(`Lien: ${resetUrl}`);
  console.log("==============================================");

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
  const consentUrl = `${FRONTEND_URL}/parental-consent/${consentToken}`;

  console.log("==============================================");
  console.log("👨‍👩‍👧 EMAIL DE CONSENTEMENT PARENTAL");
  console.log("==============================================");
  console.log(`À: ${parentEmail}`);
  console.log(`Lien: ${consentUrl}`);
  console.log("==============================================");

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
