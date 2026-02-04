const { Sequelize } = require("sequelize");

// Configuration pour Sequelize CLI
const config = {
  development: {
    username: process.env.PG_USER || "sakinah_app_user",
    password: process.env.PG_PASSWORD || "sakinah_app_password_2025",
    database: process.env.PG_DATABASE || "sakinah_app_db",
    host: process.env.PG_HOST || "localhost",
    port: process.env.PG_PORT || 5432,
    dialect: "postgres",
    logging: console.log,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
  },
  production: {
    username: process.env.PG_USER,
    password: process.env.PG_PASSWORD,
    database: process.env.PG_DATABASE,
    host: process.env.PG_HOST,
    port: process.env.PG_PORT || 5432,
    dialect: "postgres",
    logging: false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
  },
};

const env = process.env.NODE_ENV || "development";
const sequelize = new Sequelize(config[env]);

// Test de connexion
async function testConnection() {
  try {
    await sequelize.authenticate();
    console.log("✅ Connexion PostgreSQL établie avec succès");
  } catch (error) {
    console.error("❌ Erreur de connexion PostgreSQL:", error.message);
  }
}

testConnection();

module.exports = sequelize;
module.exports.config = config;
