const express = require("express");
const router = express.Router();
const authController = require("../controllers/auth.controller");
const { authenticate } = require("../middleware/auth.middleware");

// Routes publiques
router.post("/register", authController.register);
router.post("/login", authController.login);
router.get("/verify-email/:token", authController.verifyEmail);
router.post("/resend-verification", authController.resendVerification);
router.post("/forgot-password", authController.forgotPassword);
router.post("/reset-password/:token", authController.resetPassword);

// Routes protégées (nécessitent authentification)
router.get("/me", authenticate, authController.getMe);

module.exports = router;
