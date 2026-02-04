// Service d'envoi d'emails
// TODO: Configurer un vrai service d'email (SendGrid, Mailgun, etc.)

const FRONTEND_URL = process.env.FRONTEND_URL || "http://localhost:3000";

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
  console.log("Contenu HTML:", html.substring(0, 200) + "...");
  console.log("==============================================\n");

  // TODO: Implémenter l'envoi réel d'email avec nodemailer

  const nodemailer = require("nodemailer");

  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: process.env.SMTP_PORT,
    secure: true,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });

  await transporter.sendMail({
    from: '"Sakinah" <noreply@sakinah.app>',
    to: to,
    subject: subject,
    html: html,
  });

  return true;
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
  console.log(`Sujet: Vérifie ton email - Sakinah`);
  console.log(`Lien: ${verificationUrl}`);
  console.log("==============================================");
  console.log("");
  console.log("Contenu:");
  console.log(`
    Bonjour,

    Bienvenue sur Sakinah ! 🌟

    Pour activer ton compte, clique sur le lien ci-dessous :
    ${verificationUrl}

    Ce lien est valable pendant 24 heures.

    Si tu n'as pas créé de compte, ignore cet email.

    À bientôt,
    L'équipe Sakinah 💚
  `);
  console.log("==============================================\n");

  // TODO: Implémenter l'envoi réel d'email
  // Exemple avec nodemailer:

  const nodemailer = require("nodemailer");

  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: process.env.SMTP_PORT,
    secure: true,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });

  await transporter.sendMail({
    from: '"Sakinah" <noreply@sakinah.app>',
    to: email,
    subject: "Vérifie ton email - Sakinah",
    html: `
      <h2>Bienvenue sur Sakinah ! 🌟</h2>
      <p>Pour activer ton compte, clique sur le bouton ci-dessous :</p>
      <a href="${verificationUrl}" style="...">Vérifier mon email</a>
      <p>Ce lien est valable pendant 24 heures.</p>
    `,
  });

  return true;
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
  console.log(`Sujet: Réinitialise ton mot de passe - Sakinah`);
  console.log(`Lien: ${resetUrl}`);
  console.log("==============================================");
  console.log("");
  console.log("Contenu:");
  console.log(`
    Bonjour,

    Tu as demandé à réinitialiser ton mot de passe sur Sakinah.

    Clique sur le lien ci-dessous pour créer un nouveau mot de passe :
    ${resetUrl}

    Ce lien est valable pendant 1 heure.

    Si tu n'as pas fait cette demande, ignore cet email.

    L'équipe Sakinah 💚
  `);
  console.log("==============================================\n");

  // TODO: Implémenter l'envoi réel d'email

  return true;
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
  console.log(`Sujet: Consentement parental requis - Sakinah`);
  console.log(`Lien: ${consentUrl}`);
  console.log("==============================================");
  console.log("");
  console.log("Contenu:");
  console.log(`
    Bonjour,

    Votre enfant ${childName} souhaite créer un compte sur Sakinah, 
    une application de bien-être mental pour les jeunes.

    En tant que parent/tuteur légal, votre consentement est requis pour 
    que votre enfant puisse utiliser l'application.

    Pour donner votre consentement, cliquez sur le lien ci-dessous :
    ${consentUrl}

    Vous pourrez consulter notre politique de confidentialité et les 
    mesures de sécurité mises en place pour protéger votre enfant.

    Cordialement,
    L'équipe Sakinah 💚
  `);
  console.log("==============================================\n");

  // TODO: Implémenter l'envoi réel d'email

  return true;
}

module.exports = {
  sendEmail,
  sendVerificationEmail,
  sendPasswordResetEmail,
  sendParentalConsentEmail,
};
