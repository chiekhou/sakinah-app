const { Sequelize } = require("sequelize");

const sequelize = new Sequelize(
  process.env.PG_DATABASE,
  process.env.PG_USER,
  process.env.PG_PASSWORD,
  {
    host: process.env.PG_HOST,
    port: process.env.PG_PORT || 5432,
    dialect: "postgres",
    logging: process.env.NODE_ENV === "development" ? console.log : false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
  }
);

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
