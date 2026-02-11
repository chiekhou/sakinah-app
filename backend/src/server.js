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
const testimonialRoutes = require("./routes/testimonial.routes");
const notificationRoutes = require("./routes/notification.routes");

// Utiliser les routes
app.use("/api/admin", adminRoutes);
app.use("/api/admin", adminModerationRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/auth", parentalConsentRoutes);
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
sequelize.sync().then(() => {
  console.log("✅ Tables PostgreSQL synchronisées");
  app.listen(PORT, () => {
    console.log(`🚀 Serveur démarré sur le port ${PORT}`);
    console.log(`📍 Environnement: ${process.env.NODE_ENV || "development"}`);
  });
}).catch((err) => {
  console.error("❌ Erreur synchronisation PostgreSQL:", err.message);
});

module.exports = app;
