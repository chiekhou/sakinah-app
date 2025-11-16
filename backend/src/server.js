require("dotenv").config();
const express = require("express");
const cors = require("cors");
const helmet = require("helmet");

const app = express();
const PORT = process.env.PORT || 3000;

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

// Routes
app.get("/", (req, res) => {
  res.json({
    message: "API Sakinah la quiétude pour la santé ",
    version: "1.0.0",
    status: "healthy",
  });
});

// TODO: Importer et utiliser les routes
// const authRoutes = require('./routes/auth.routes');
// const moodRoutes = require('./routes/mood.routes');
// const contentRoutes = require('./routes/content.routes');
// const chatRoutes = require('./routes/chat.routes');
// const quizRoutes = require('./routes/quiz.routes');

// app.use('/api/auth', authRoutes);
// app.use('/api/mood', moodRoutes);
// app.use('/api/content', contentRoutes);
// app.use('/api/chat', chatRoutes);
// app.use('/api/quizzes', quizRoutes);

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
