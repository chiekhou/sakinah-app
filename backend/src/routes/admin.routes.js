const express = require("express");
const router = express.Router();
const adminController = require("../controllers/admin.controller");
const { authenticate, requireRole } = require("../middleware/auth.middleware");

// Toutes les routes admin nécessitent le rôle ADMIN
const adminOnly = [authenticate, requireRole(["ADMIN"])];

// Dashboard
router.get("/dashboard", adminOnly, adminController.getDashboard);
router.get("/activity-logs", adminOnly, adminController.getActivityLogs);

// Gestion des utilisateurs
router.get("/users", adminOnly, adminController.listUsers);
router.get("/users/:userId", adminOnly, adminController.getUserDetails);
router.patch(
  "/users/:userId/status",
  adminOnly,
  adminController.updateUserStatus
);
router.delete("/users/:userId", adminOnly, adminController.deleteUser);
router.post(
  "/users/:userId/promote",
  adminOnly,
  adminController.promoteToAdmin
);

// Gestion des professionnels
router.get(
  "/professionals/pending",
  adminOnly,
  adminController.listPendingProfessionals
);
router.post(
  "/professionals/:userId/verify",
  adminOnly,
  adminController.verifyProfessional
);
router.get(
  "/professionals/:userId/diploma",
  adminOnly,
  adminController.viewDiploma
);

module.exports = router;
