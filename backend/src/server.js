require("dotenv").config();
const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const connectMongoDB = require("./config/mongodb");

const app = express();
const PORT = process.env.PORT || 3000;

// Connexion à MongoDB
connectMongoDB();

// Middleware de sécurité
app.use(helmet());

// CORS
const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(",") || [
  "https://sakinah-app.onrender.com",
];
app.use(
  cors({
    origin: function (origin, callback) {
      if (!origin || allowedOrigins.indexOf(origin) !== -1) {
        callback(null, true);
      } else {
        callback(new Error("Not allowed by CORS"));
      }
    },
    credentials: true,
  }),
);

// Parser JSON
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// Servir les fichiers statiques (avatars, diplômes)
app.use("/uploads", express.static("uploads"));

// Deep Links - Fichiers de vérification pour Android et iOS
app.use(
  "/.well-known",
  express.static(".well-known", {
    setHeaders: (res, path) => {
      // apple-app-site-association doit être servi avec content-type application/json
      if (path.endsWith("apple-app-site-association")) {
        res.setHeader("Content-Type", "application/json");
      }
    },
  }),
);

// Routes
app.get("/", (req, res) => {
  res.json({
    message: "API Bien-être Mental - Opérationnelle",
    version: "1.0.0",
    status: "healthy",
    endpoints: {
      users: "/api/users",
      mood: "/api/mood",
      quizzes: "/api/quizzes",
      content: "/api/content",
      chat: "/api/chat",
      emergency: "/api/emergency",
    },
  });
});

// Politique de confidentialité
app.get("/privacy-policy", (_req, res) => {
  res.send(`<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Politique de Confidentialité — Sakinah</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; max-width: 800px; margin: 0 auto; padding: 24px 16px; color: #2c3e50; line-height: 1.7; }
    h1 { color: #27ae60; font-size: 28px; }
    h2 { color: #27ae60; font-size: 20px; margin-top: 36px; border-bottom: 2px solid #eafaf1; padding-bottom: 8px; }
    table { width: 100%; border-collapse: collapse; margin: 16px 0; }
    th, td { border: 1px solid #ddd; padding: 10px 14px; text-align: left; }
    th { background-color: #eafaf1; color: #27ae60; }
    a { color: #27ae60; }
    .updated { color: #888; font-size: 14px; }
  </style>
</head>
<body>
  <h1>Politique de Confidentialité — Sakinah</h1>
  <p class="updated"><strong>Dernière mise à jour : 29 mars 2026</strong></p>

  <h2>1. Présentation</h2>
  <p>Sakinah est une application mobile dédiée au bien-être mental et à la lutte contre le harcèlement. Elle s'adresse à des utilisateurs de tout âge, y compris des mineurs, avec le consentement obligatoire d'un parent ou tuteur légal pour les utilisateurs de moins de 15 ans.</p>
  <p><strong>Responsable du traitement :</strong><br>
  Email de contact : st.services92@gmail.com<br>
  Pays : France</p>

  <h2>2. Données collectées</h2>
  <p><strong>Lors de l'inscription :</strong></p>
  <ul>
    <li>Adresse email</li>
    <li>Pseudo (nom d'affichage)</li>
    <li>Tranche d'âge</li>
    <li>Mot de passe (stocké chiffré, jamais accessible en clair)</li>
  </ul>
  <p><strong>Lors de l'utilisation :</strong></p>
  <ul>
    <li>Entrées d'humeur : niveau d'humeur et notes personnelles</li>
    <li>Témoignages : textes partagés volontairement (anonymes ou non selon le choix de l'utilisateur)</li>
    <li>Commentaires et likes sur les témoignages</li>
    <li>Tokens FCM : identifiants de l'appareil pour l'envoi de notifications push</li>
  </ul>
  <p><strong>Pour les comptes mineurs :</strong></p>
  <ul>
    <li>Email du parent ou tuteur légal</li>
    <li>Consentement parental horodaté</li>
  </ul>

  <h2>3. Finalité du traitement</h2>
  <p>Vos données sont utilisées exclusivement pour :</p>
  <ul>
    <li>Fournir les fonctionnalités de l'application (suivi d'humeur, témoignages, chat)</li>
    <li>Envoyer des notifications push (rappels bien-être, interactions communautaires)</li>
    <li>Modérer les contenus publiés</li>
    <li>Permettre au parent de suivre l'activité de son enfant</li>
    <li>Améliorer l'application</li>
  </ul>
  <p><strong>Vos données ne sont jamais vendues ni partagées avec des tiers à des fins commerciales.</strong></p>

  <h2>4. Mineurs et consentement parental</h2>
  <p>Conformément au RGPD et à la loi française, l'inscription d'un utilisateur de moins de 15 ans requiert le consentement explicite d'un parent ou tuteur légal.</p>
  <ul>
    <li>Le parent reçoit un email de confirmation et doit valider le compte</li>
    <li>Le parent dispose d'un espace dédié pour consulter l'activité de son enfant</li>
    <li>Le parent peut supprimer le compte de son enfant à tout moment depuis l'application</li>
  </ul>

  <h2>5. Notifications push</h2>
  <p>L'application utilise <strong>Firebase Cloud Messaging (FCM)</strong> de Google pour envoyer des notifications push. Les tokens d'appareils sont stockés sur nos serveurs et supprimés automatiquement s'ils deviennent invalides. Vous pouvez désactiver les notifications à tout moment depuis les paramètres de votre appareil.</p>

  <h2>6. Durée de conservation</h2>
  <table>
    <tr><th>Donnée</th><th>Durée</th></tr>
    <tr><td>Compte utilisateur</td><td>Jusqu'à suppression du compte</td></tr>
    <tr><td>Entrées d'humeur</td><td>Jusqu'à suppression du compte</td></tr>
    <tr><td>Témoignages</td><td>Jusqu'à suppression manuelle ou du compte</td></tr>
    <tr><td>Tokens FCM</td><td>Jusqu'à déconnexion ou invalidation</td></tr>
    <tr><td>Logs serveur</td><td>30 jours maximum</td></tr>
  </table>

  <h2>7. Vos droits (RGPD)</h2>
  <p>Conformément au Règlement Général sur la Protection des Données (RGPD), vous disposez des droits suivants :</p>
  <ul>
    <li><strong>Droit d'accès</strong> : obtenir une copie de vos données</li>
    <li><strong>Droit de rectification</strong> : corriger vos données</li>
    <li><strong>Droit à l'effacement</strong> : supprimer votre compte et toutes vos données</li>
    <li><strong>Droit d'opposition</strong> : vous opposer à certains traitements</li>
    <li><strong>Droit à la portabilité</strong> : recevoir vos données dans un format lisible</li>
  </ul>
  <p>Pour exercer ces droits, contactez-nous à : <strong>st.services92@gmail.com</strong><br>
  Vous pouvez également supprimer votre compte directement depuis l'application dans <strong>Profil → Supprimer mon compte</strong>.</p>

  <h2>8. Sécurité</h2>
  <ul>
    <li>Les mots de passe sont chiffrés avec <strong>bcrypt</strong></li>
    <li>Les communications sont chiffrées via <strong>HTTPS/TLS</strong></li>
    <li>L'accès aux données est restreint aux seuls administrateurs autorisés</li>
    <li>Les tokens d'authentification (JWT) expirent automatiquement</li>
  </ul>

  <h2>9. Hébergement</h2>
  <p>L'application et ses données sont hébergées sur :</p>
  <ul>
    <li><strong>Render</strong> (serveur backend) — États-Unis</li>
    <li><strong>Brevo</strong> (envoi d'emails) — Union Européenne</li>
  </ul>
  <p>Ces prestataires respectent le RGPD et disposent des certifications adéquates.</p>

  <h2>10. Modifications</h2>
  <p>Nous nous réservons le droit de modifier cette politique. En cas de changement significatif, vous serez notifié par email ou via l'application.</p>

  <h2>11. Contact</h2>
  <p><strong>Email :</strong> st.services92@gmail.com<br>
  Pour toute réclamation, vous pouvez également contacter la <strong>CNIL</strong> : <a href="https://www.cnil.fr">cnil.fr</a></p>
</body>
</html>`);
});

// Importer les routes
////const userRoutes = require("./routes/user.routes");
const adminRoutes = require("./routes/admin.routes");
const adminModerationRoutes = require("./routes/admin-moderation.routes");
const authRoutes = require("./routes/auth.routes");
const profileRoutes = require("./routes/profile.routes");
const moodRoutes = require("./routes/mood.routes");
const quizRoutes = require("./routes/quiz.routes");
const contentRoutes = require("./routes/content.routes");
const chatRoutes = require("./routes/chat.routes");
const emergencyRoutes = require("./routes/emergency.routes");
const parentalConsentRoutes = require("./routes/parental-consent.routes");
const parentRoutes = require("./routes/parent.routes");
const testimonialRoutes = require("./routes/testimonial.routes");
const notificationRoutes = require("./routes/notification.routes");

// Utiliser les routes
app.use("/api/admin", adminRoutes);
app.use("/api/admin", adminModerationRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/auth", parentalConsentRoutes);
app.use("/api/parent", parentRoutes);
app.use("/api/profile", profileRoutes);
app.use("/api/mood", moodRoutes);
app.use("/api/quizzes", quizRoutes);
app.use("/api/content", contentRoutes);
app.use("/api/chat", chatRoutes);
app.use("/api/emergency", emergencyRoutes);
app.use("/api/testimonials", testimonialRoutes);
app.use("/api/notifications", notificationRoutes);
//app.use("/api/users", userRoutes);

// Gestion des erreurs 404
app.use((req, res) => {
  res.status(404).json({ error: "Route non trouvée" });
});

// Gestion globale des erreurs
app.use((err, req, res, next) => {
  // PRODUCTION: Ne pas exposer les stack traces dans les logs
  if (process.env.NODE_ENV === "development") {
    console.error(err.stack);
  } else {
    console.error("Erreur serveur:", err.message);
  }
  res.status(err.status || 500).json({
    error: err.message || "Erreur serveur",
    ...(process.env.NODE_ENV === "development" && { stack: err.stack }),
  });
});

// Importer tous les modèles pour que sequelize.sync() crée les tables
require("./models/User");
require("./models/MoodEntry");
require("./models/Quiz");
require("./models/Article");
require("./models/Scenario");
require("./models/Conversation");
require("./models/Testimonial");
require("./models/TestimonialLike");
require("./models/TestimonialComment");
require("./models/Notification");
require("./models/ParentalConsent");
require("./models/FCMToken");

// Synchronisation des tables PostgreSQL puis démarrage du serveur
const sequelize = require("./config/database");
const pushService = require("./services/push.service");

sequelize
  .sync()
  .then(() => {
    console.log("✅ Tables PostgreSQL synchronisées");

    // Démarrer le cron job des rappels quotidiens
    pushService.startDailyReminderCron();

    app.listen(PORT, () => {
      console.log(`🚀 Serveur démarré sur le port ${PORT}`);
      console.log(`📍 Environnement: ${process.env.NODE_ENV || "development"}`);
    });
  })
  .catch((err) => {
    console.error("❌ Erreur synchronisation PostgreSQL:", err.message);
  });

module.exports = app;
