const User = require("../models/User");
const Notification = require("../models/Notification");
const PendingProfileUpdate = require("../models/PendingProfileUpdate");
const { sendEmail } = require("../services/email.service");
const pushService = require("../services/push.service");

class SafetyController {
  /**
   * Enregistre que le mineur a lu et accepté le rappel de sécurité.
   * POST /api/safety/acknowledge
   */
  async acknowledgeReminder(req, res) {
    try {
      const user = req.user;
      await user.update({ safety_reminder_acknowledged_at: new Date() });
      res.json({
        message: "Rappel de sécurité accepté.",
        acknowledged_at: user.safety_reminder_acknowledged_at,
      });
    } catch (error) {
      console.error("Erreur acknowledgeReminder:", error);
      res.status(500).json({ error: "Erreur lors de l'enregistrement" });
    }
  }

  /**
   * Retourne le statut de sécurité de l'utilisateur connecté.
   * GET /api/safety/status
   */
  async getStatus(req, res) {
    try {
      const user = req.user;

      // Vérifier s'il y a une mise à jour en attente
      const pending = await PendingProfileUpdate.findOne({
        where: { user_id: user.id, status: "PENDING" },
      });

      res.json({
        is_minor: user.is_minor,
        safety_reminder_acknowledged: !!user.safety_reminder_acknowledged_at,
        can_post_content: user.is_minor
          ? (user.accessibility_settings?.can_post_content ?? false)
          : true,
        parent_supervision_active: !!user.parent_id,
        has_pending_update: !!pending,
      });
    } catch (error) {
      console.error("Erreur getStatus:", error);
      res.status(500).json({ error: "Erreur lors de la récupération du statut" });
    }
  }

  /**
   * Soumet une demande de modification de profil pour approbation parentale.
   * Les changements sont enregistrés en attente — pas encore appliqués au profil.
   * POST /api/safety/request-profile-update
   * Body: { pseudo?, bio?, avatar_url? }
   */
  async requestProfileUpdate(req, res) {
    try {
      const user = req.user;

      if (!user.is_minor) {
        return res.status(400).json({ error: "Réservé aux comptes mineurs" });
      }

      if (!user.parent_id) {
        return res.status(400).json({ error: "Aucun parent associé à ce compte" });
      }

      const { pseudo, bio, avatar_url } = req.body;
      const changes = {};
      if (pseudo !== undefined) changes.pseudo = pseudo;
      if (bio !== undefined) changes.bio = bio;
      if (avatar_url !== undefined) changes.avatar_url = avatar_url;

      if (Object.keys(changes).length === 0) {
        return res.status(400).json({ error: "Aucune modification fournie" });
      }

      // Annuler toute demande précédente en attente
      await PendingProfileUpdate.update(
        { status: "REJECTED", rejection_reason: "Remplacée par une nouvelle demande" },
        { where: { user_id: user.id, status: "PENDING" } }
      );

      // Créer la nouvelle demande
      const pending = await PendingProfileUpdate.create({
        user_id: user.id,
        changes,
        status: "PENDING",
      });

      const parent = await User.findByPk(user.parent_id, {
        attributes: ["id", "email", "pseudo"],
      });

      if (!parent) {
        return res.status(404).json({ error: "Compte parent introuvable" });
      }

      const childName = user.pseudo || user.username;
      const changesList = Object.keys(changes)
        .map((k) => ({ pseudo: "pseudo", bio: "description", avatar_url: "photo de profil" }[k] || k))
        .join(", ");

      // Email au parent
      sendEmail(
        parent.email,
        "Sakinah — Approbation requise : modification de profil",
        `<div style="font-family:sans-serif;max-width:520px;margin:auto;">
          <div style="background:linear-gradient(135deg,#2ECC71,#27AE60);padding:28px 32px;border-radius:12px 12px 0 0;">
            <h2 style="margin:0;color:#fff;font-size:20px;">✏️ Approbation requise</h2>
          </div>
          <div style="background:#fff;padding:28px 32px;border:1px solid #e5e7eb;border-top:none;border-radius:0 0 12px 12px;">
            <p style="color:#374151;">Bonjour ${parent.pseudo || ""},</p>
            <p style="color:#374151;">
              Votre enfant <strong>${childName}</strong> souhaite modifier
              <strong>${changesList}</strong> sur son profil Sakinah.
            </p>
            <p style="color:#374151;">
              <strong>Cette modification est en attente de votre approbation.</strong>
              Elle ne sera appliquée qu'après votre validation depuis l'Espace Parent.
            </p>
            <p style="margin-top:24px;color:#9ca3af;font-size:13px;">
              Ouvrez l'application Sakinah → Espace Parent → "Modifications en attente".
            </p>
          </div>
        </div>`
      ).catch(() => {});

      // Push au parent
      pushService.sendToUser(
        parent.id,
        {
          title: "✏️ Approbation requise",
          body: `${childName} souhaite modifier son profil. Votre accord est nécessaire.`,
        },
        { type: "PROFILE_UPDATE_PENDING", update_id: pending.id, childId: user.id }
      ).catch(() => {});

      Notification.supervisionLog(
        parent.id,
        user.id,
        childName,
        "PROFILE_UPDATE"
      ).catch(() => {});

      res.json({
        message: "Demande envoyée à ton parent. La modification sera appliquée après son approbation.",
        pending_id: pending.id,
      });
    } catch (error) {
      console.error("Erreur requestProfileUpdate:", error);
      res.status(500).json({ error: "Erreur lors de la demande de modification" });
    }
  }
}

module.exports = new SafetyController();
