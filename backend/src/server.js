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
  "http://localhost:3000",
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
  })
);

// Parser JSON
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// Servir les fichiers statiques (avatars, diplômes)
app.use("/uploads", express.static("uploads"));

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
const adminRoutes = require("./routes/admin.routes");
const authRoutes = require("./routes/auth.routes");
const profileRoutes = require("./routes/profile.routes");
const moodRoutes = require("./routes/mood.routes");
const quizRoutes = require("./routes/quiz.routes");
const contentRoutes = require("./routes/content.routes");
const chatRoutes = require("./routes/chat.routes");
const emergencyRoutes = require("./routes/emergency.routes");
////const userRoutes = require("./routes/user.routes");

// Utiliser les routes
app.use("/api/admin", adminRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/profile", profileRoutes);
app.use("/api/mood", moodRoutes);
app.use("/api/quizzes", quizRoutes);
app.use("/api/content", contentRoutes);
app.use("/api/chat", chatRoutes);
app.use("/api/emergency", emergencyRoutes);
//app.use("/api/users", userRoutes);

// Gestion des erreurs 404
app.use((req, res) => {
  res.status(404).json({ error: "Route non trouvée" });
});

// Gestion globale des erreurs
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    error: err.message || "Erreur serveur",
    ...(process.env.NODE_ENV === "development" && { stack: err.stack }),
  });
});

// Démarrage du serveur
app.listen(PORT, () => {
  console.log(`🚀 Serveur démarré sur le port ${PORT}`);
  console.log(`📍 Environnement: ${process.env.NODE_ENV || "development"}`);
  console.log(`🌐 URL: http://localhost:${PORT}`);
});

module.exports = app;
