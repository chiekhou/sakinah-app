/**
 * Template d'email pour demander le consentement parental
 * @param {Object} data - Données pour l'email
 * @param {string} data.parentEmail - Email du parent
 * @param {string} data.childUsername - Nom d'utilisateur de l'enfant
 * @param {string} data.childEmail - Email de l'enfant
 * @param {string} data.ageRange - Tranche d'âge
 * @param {string} data.confirmationLink - Lien de confirmation
 * @returns {Object} - Subject et HTML de l'email
 */
function getParentalConsentEmail(data) {
  const {
    parentEmail,
    childUsername,
    childEmail,
    ageRange,
    confirmationLink,
    revocationLink,
  } = data;

  const subject = "🔒 Confirmation du consentement parental - Sakinah";

  const html = `
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      line-height: 1.6;
      color: #2C3E50;
      background-color: #F8F9FA;
      margin: 0;
      padding: 0;
    }
    .container {
      max-width: 600px;
      margin: 0 auto;
      background-color: #ffffff;
      border-radius: 16px;
      overflow: hidden;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }
    .header {
      background: linear-gradient(135deg, #2ECC71 0%, #27AE60 100%);
      padding: 40px 20px;
      text-align: center;
    }
    .header h1 {
      margin: 0;
      color: #ffffff;
      font-size: 28px;
      font-weight: 700;
    }
    .header p {
      margin: 10px 0 0;
      color: #ffffff;
      font-size: 16px;
      opacity: 0.9;
    }
    .content {
      padding: 40px 30px;
    }
    .greeting {
      font-size: 18px;
      font-weight: 600;
      margin-bottom: 20px;
      color: #2C3E50;
    }
    .message {
      font-size: 15px;
      margin-bottom: 20px;
      color: #7F8C8D;
    }
    .info-box {
      background-color: #FEF5E7;
      border-left: 4px solid #F39C12;
      padding: 20px;
      margin: 25px 0;
      border-radius: 8px;
    }
    .info-box h3 {
      margin: 0 0 15px 0;
      color: #F39C12;
      font-size: 16px;
      font-weight: 600;
    }
    .info-item {
      margin: 8px 0;
      font-size: 14px;
      color: #2C3E50;
    }
    .info-item strong {
      font-weight: 600;
      color: #2C3E50;
    }
    .cta-button {
      display: inline-block;
      background: linear-gradient(135deg, #2ECC71 0%, #27AE60 100%);
      color: #ffffff;
      text-decoration: none;
      padding: 16px 40px;
      border-radius: 12px;
      font-weight: 600;
      font-size: 16px;
      margin: 10px 8px;
      box-shadow: 0 4px 12px rgba(46, 204, 113, 0.3);
      transition: transform 0.2s;
    }
    .cta-button:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 16px rgba(46, 204, 113, 0.4);
    }
    .revoke-button {
      display: inline-block;
      background: #ffffff;
      color: #E74C3C;
      text-decoration: none;
      padding: 14px 32px;
      border-radius: 12px;
      font-weight: 600;
      font-size: 15px;
      margin: 10px 8px;
      border: 2px solid #E74C3C;
      transition: transform 0.2s;
    }
    .revoke-button:hover {
      background: #FDEDEC;
    }
    .about-sakinah {
      background-color: #EBF5FB;
      border-left: 4px solid #3498DB;
      padding: 20px;
      margin: 25px 0;
      border-radius: 8px;
    }
    .about-sakinah h3 {
      margin: 0 0 15px 0;
      color: #3498DB;
      font-size: 16px;
      font-weight: 600;
    }
    .about-sakinah ul {
      margin: 10px 0;
      padding-left: 20px;
    }
    .about-sakinah li {
      margin: 8px 0;
      font-size: 14px;
      color: #2C3E50;
    }
    .security-info {
      background-color: #D5F4E6;
      border-left: 4px solid #2ECC71;
      padding: 20px;
      margin: 25px 0;
      border-radius: 8px;
    }
    .security-info h3 {
      margin: 0 0 15px 0;
      color: #2ECC71;
      font-size: 16px;
      font-weight: 600;
    }
    .security-info ul {
      margin: 10px 0;
      padding-left: 20px;
    }
    .security-info li {
      margin: 8px 0;
      font-size: 14px;
      color: #2C3E50;
    }
    .footer {
      background-color: #F8F9FA;
      padding: 30px;
      text-align: center;
      border-top: 1px solid #E0E0E0;
    }
    .footer p {
      margin: 5px 0;
      font-size: 13px;
      color: #7F8C8D;
    }
    .footer a {
      color: #2ECC71;
      text-decoration: none;
      font-weight: 600;
    }
    .warning {
      background-color: #FDEDEC;
      border-left: 4px solid #E74C3C;
      padding: 15px;
      margin: 25px 0;
      border-radius: 8px;
      font-size: 13px;
      color: #E74C3C;
    }
    @media (max-width: 600px) {
      .content {
        padding: 30px 20px;
      }
      .header h1 {
        font-size: 24px;
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <!-- Header -->
    <div class="header">
      <h1>💚 Sakinah</h1>
      <p>Consentement parental requis</p>
    </div>

    <!-- Content -->
    <div class="content">
      <p class="greeting">Bonjour,</p>

      <p class="message">
        Votre enfant <strong>${childUsername}</strong> vient de créer un compte sur <strong>Sakinah</strong>, 
        une application de bien-être mental dédiée aux jeunes.
      </p>

      <!-- Informations du compte -->
      <div class="info-box">
        <h3>📋 Informations du compte</h3>
        <div class="info-item"><strong>Nom d'utilisateur :</strong> ${childUsername}</div>
        <div class="info-item"><strong>Email :</strong> ${childEmail}</div>
        <div class="info-item"><strong>Tranche d'âge :</strong> ${ageRange} ans</div>
        <div class="info-item"><strong>Date d'inscription :</strong> ${new Date().toLocaleDateString(
          "fr-FR",
          {
            year: "numeric",
            month: "long",
            day: "numeric",
          },
        )}</div>
      </div>

      <p class="message">
        <strong>Pour que votre enfant puisse utiliser l'application, nous avons besoin de votre consentement.</strong>
        Conformément au RGPD et à la protection des mineurs, un parent ou tuteur légal doit autoriser 
        l'inscription des utilisateurs de moins de 18 ans.
      </p>

      <!-- Boutons de confirmation et révocation -->
      <center>
        <a href="${confirmationLink}" class="cta-button">
          ✅ Confirmer le consentement
        </a>
        <a href="${revocationLink}" class="revoke-button">
          ❌ Refuser le consentement
        </a>
      </center>

      <p class="message" style="font-size: 13px; color: #95A5A6;">
        <em>Ces liens sont valides pendant 7 jours. Après cette période, votre enfant devra se réinscrire.</em>
      </p>

      <!-- À propos de Sakinah -->
      <div class="about-sakinah">
        <h3>🌱 Qu'est-ce que Sakinah ?</h3>
        <p style="margin: 10px 0; font-size: 14px; color: #2C3E50;">
          Sakinah est une application bienveillante qui accompagne les jeunes dans leur bien-être mental. 
          Elle leur permet de :
        </p>
        <ul>
          <li>Suivre leur humeur au quotidien</li>
          <li>Accéder à des ressources éducatives sur le bien-être</li>
          <li>Partager leurs témoignages de manière anonyme</li>
          <li>Échanger avec des professionnels vérifiés (psychologues, éducateurs)</li>
          <li>Participer à des quiz interactifs sur la santé mentale</li>
        </ul>
      </div>

      <!-- Sécurité et confidentialité -->
      <div class="security-info">
        <h3>🔒 Sécurité et confidentialité</h3>
        <ul>
          <li><strong>Chiffrement des données :</strong> Toutes les informations sont sécurisées</li>
          <li><strong>Pseudonymes :</strong> Chaque utilisateur a un pseudo anonyme pour protéger son identité</li>
          <li><strong>Modération active :</strong> Tous les contenus partagés sont modérés</li>
          <li><strong>Signalement facile :</strong> Votre enfant peut signaler tout contenu inapproprié</li>
          <li><strong>Professionnels vérifiés :</strong> Tous les psychologues et éducateurs sont contrôlés</li>
        </ul>
      </div>

      <!-- Vos droits -->
      <div class="info-box">
        <h3>⚖️ Vos droits en tant que parent</h3>
        <p style="margin: 10px 0; font-size: 14px; color: #2C3E50;">
          En tant que parent ou tuteur légal, vous pouvez à tout moment :
        </p>
        <ul style="margin-top: 10px;">
          <li>Consulter les données de votre enfant</li>
          <li>Modifier ou supprimer ces données</li>
          <li>Révoquer votre consentement et supprimer le compte</li>
          <li>Exporter les données (droit à la portabilité)</li>
          <li>Nous contacter pour toute question</li>
        </ul>
      </div>

      <p class="message">
        <strong>Des questions ?</strong> Notre équipe est là pour vous aider. 
        Contactez-nous à <a href="mailto:st-services@chiekhoutraore.fr" style="color: #2ECC71; text-decoration: none; font-weight: 600;">st-services@chiekhoutraore.fr</a>
      </p>

      <!-- Warning -->
      <div class="warning">
        ⚠️ <strong>Important :</strong> Si vous n'avez pas autorisé votre enfant à s'inscrire sur Sakinah, 
        veuillez ignorer cet email et nous contacter immédiatement.
      </div>
    </div>

    <!-- Footer -->
    <div class="footer">
      <p><strong>💚 Sakinah</strong></p>
      <p>Ta sérénité, notre priorité</p>
      <p style="margin-top: 15px;">
        <a href="mailto:st-services@chiekhoutraore.fr">Support</a> • 
        <a href="#">Politique de confidentialité</a> • 
        <a href="#">CGU</a>
      </p>
      <p style="margin-top: 15px; font-size: 12px;">
        © ${new Date().getFullYear()} Sakinah. Tous droits réservés.
      </p>
    </div>
  </div>
</body>
</html>
  `.trim();

  return { subject, html };
}

/**
 * Template d'email pour notification à l'enfant (après consentement parental)
 */
function getChildAccountActivatedEmail(data) {
  const { childUsername, childEmail } = data;

  const subject = "✅ Ton compte Sakinah est activé !";

  const html = `
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      line-height: 1.6;
      color: #2C3E50;
      background-color: #F8F9FA;
      margin: 0;
      padding: 0;
    }
    .container {
      max-width: 600px;
      margin: 0 auto;
      background-color: #ffffff;
      border-radius: 16px;
      overflow: hidden;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }
    .header {
      background: linear-gradient(135deg, #2ECC71 0%, #27AE60 100%);
      padding: 40px 20px;
      text-align: center;
    }
    .header h1 {
      margin: 0;
      color: #ffffff;
      font-size: 28px;
      font-weight: 700;
    }
    .content {
      padding: 40px 30px;
    }
    .celebration {
      text-align: center;
      font-size: 60px;
      margin: 20px 0;
    }
    .message {
      font-size: 15px;
      margin-bottom: 20px;
      color: #7F8C8D;
      text-align: center;
    }
    .cta-button {
      display: inline-block;
      background: linear-gradient(135deg, #2ECC71 0%, #27AE60 100%);
      color: #ffffff;
      text-decoration: none;
      padding: 16px 40px;
      border-radius: 12px;
      font-weight: 600;
      font-size: 16px;
      margin: 30px 0;
      box-shadow: 0 4px 12px rgba(46, 204, 113, 0.3);
    }
    .footer {
      background-color: #F8F9FA;
      padding: 30px;
      text-align: center;
      border-top: 1px solid #E0E0E0;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>💚 Sakinah</h1>
    </div>
    <div class="content">
      <div class="celebration">🎉</div>
      <h2 style="text-align: center; color: #2ECC71; margin-bottom: 20px;">
        Félicitations ${childUsername} !
      </h2>
      <p class="message">
        Ton parent a donné son consentement. Ton compte Sakinah est maintenant <strong>activé</strong> ! 
        Tu peux te connecter et commencer à utiliser l'application.
      </p>
      <center>
        <a href="#" class="cta-button">
          🚀 Commencer mon parcours
        </a>
      </center>
      <p class="message" style="margin-top: 30px; font-size: 14px;">
        Bienvenue dans la communauté Sakinah ! 💚
      </p>
    </div>
    <div class="footer">
      <p><strong>💚 Sakinah</strong></p>
      <p>Ta sérénité, notre priorité</p>
    </div>
  </div>
</body>
</html>
  `.trim();

  return { subject, html };
}

module.exports = {
  getParentalConsentEmail,
  getChildAccountActivatedEmail,
};
