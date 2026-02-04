const express = require("express");
const router = express.Router();
const parentalConsentController = require("../controllers/parental-consent.controller");

/**
 * @route   POST /api/auth/send-parental-consent
 * @desc    Envoyer une demande de consentement parental
 * @access  Public (appelé après l'inscription)
 * @body    { user_id: number, parent_email: string }
 */
router.post(
  "/send-parental-consent",
  parentalConsentController.sendConsentRequest
);

/**
 * @route   GET /api/auth/confirm-parental-consent/:token
 * @desc    Confirmer le consentement parental via le lien dans l'email
 * @access  Public
 * @params  token - Token de confirmation
 */
router.get(
  "/confirm-parental-consent/:token",
  parentalConsentController.confirmConsent
);

/**
 * @route   POST /api/auth/revoke-parental-consent
 * @desc    Révoquer le consentement parental
 * @access  Public (mais vérifié par email parent)
 * @body    { user_id: number, parent_email: string, reason?: string }
 */
router.post(
  "/revoke-parental-consent",
  parentalConsentController.revokeConsent
);

/**
 * @route   GET /api/auth/parental-consent-status/:userId
 * @desc    Vérifier le statut du consentement parental
 * @access  Public
 * @params  userId - ID de l'utilisateur
 */
router.get(
  "/parental-consent-status/:userId",
  parentalConsentController.getConsentStatus
);

module.exports = router;
