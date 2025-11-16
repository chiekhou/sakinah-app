const mongoose = require("mongoose");

const connectMongoDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log("✅ Connexion MongoDB établie avec succès");
  } catch (error) {
    console.error("❌ Erreur de connexion MongoDB:", error.message);
    process.exit(1);
  }
};

mongoose.connection.on("disconnected", () => {
  console.log("⚠️ MongoDB déconnecté");
});

mongoose.connection.on("error", (err) => {
  console.error("❌ Erreur MongoDB:", err.message);
});

module.exports = connectMongoDB;
