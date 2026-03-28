const express = require("express");
const router = express.Router();
const profileController = require("../controllers/profile.controller");
const { authenticate, requireRole } = require("../middleware/auth.middleware");
const {
  uploadAvatar,
  uploadDiploma,
} = require("../middleware/upload.middleware");

// Routes protégées (nécessitent authentification)

// Profil personnel
router.get("/me/stats", authenticate, profileController.getMyStats);
router.put("/me", authenticate, profileController.updateProfile);
router.put("/me/password", authenticate, profileController.changePassword);
router.delete("/me", authenticate, profileController.deleteAccount);
router.post("/me/delete-request", authenticate, profileController.sendDeleteRequest);

// Avatar
router.post(
  "/me/avatar",
  authenticate,
  uploadAvatar,
  profileController.uploadAvatar
);
router.delete("/me/avatar", authenticate, profileController.deleteAvatar);

// Diplôme (professionnels uniquement)
router.post(
  "/me/diploma",
  authenticate,
  requireRole(["EDUCATEUR", "PSYCHOLOGUE", "INTERVENANT"]),
  uploadDiploma,
  profileController.uploadDiploma
);

// Profils publics
router.get("/:userId", profileController.getPublicProfile);

module.exports = router;
