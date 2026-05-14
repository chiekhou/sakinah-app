const User = require("../models/User");
const { sendEmail } = require("../services/email.service");

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
   * Utilisé par l'app pour savoir quelles actions afficher/bloquer.
   * GET /api/safety/status
   */
  async getStatus(req, res) {
    try {
      const user = req.user;

      res.json({
        is_minor: user.is_minor,
        safety_reminder_acknowledged: !!user.safety_reminder_acknowledged_at,
        can_post_content: user.is_minor
          ? (user.accessibility_settings?.can_post_content ?? false)
          : true,
        parent_supervision_active: !!user.parent_id,
      });
    } catch (error) {
      console.error("Erreur getStatus:", error);
      res.status(500).json({ error: "Erreur lors de la récupération du statut" });
    }
  }

  /**
   * Notifie le parent qu'un mineur veut mettre à jour ses informations personnelles.
   * L'app appelle cet endpoint avant d'autoriser la modification du profil (bio, avatar).
   * POST /api/safety/request-profile-update
   */
  async requestProfileUpdate(req, res) {
    try {
      const user = req.user;

      if (!user.is_minor) {
        return res.status(400).json({ error: "Réservé aux comptes mineurs" });
      }

      if (!user.parent_id) {
        return res.status(400).json({
          error: "Aucun parent associé à ce compte",
        });
      }

      const parent = await User.findByPk(user.parent_id, {
        attributes: ["email", "pseudo"],
      });

      if (!parent) {
        return res.status(404).json({ error: "Compte parent introuvable" });
      }

      await sendEmail({
        to: parent.email,
        subject: "Sakinah — Demande de modification de profil",
        html: `
          <div style="font-family: sans-serif; max-width: 520px; margin: auto;">
            <div style="background: linear-gradient(135deg, #2ECC71, #27AE60); padding: 28px 32px; border-radius: 12px 12px 0 0;">
              <h2 style="margin: 0; color: #fff; font-size: 20px;">Demande de modification de profil</h2>
            </div>
            <div style="background: #fff; padding: 28px 32px; border: 1px solid #e5e7eb; border-top: none; border-radius: 0 0 12px 12px;">
              <p style="color: #374151;">Bonjour ${parent.pseudo || ""},</p>
              <p style="color: #374151;">
                Votre enfant <strong>${user.pseudo || user.username}</strong>
                souhaite modifier ses informations personnelles sur Sakinah
                (photo de profil ou description).
              </p>
              <p style="color: #374151;">
                Vous pouvez superviser et autoriser cette modification depuis votre espace parent.
              </p>
              <p style="margin-top: 24px; color: #9ca3af; font-size: 13px;">
                Si vous n'êtes pas à l'origine de cette demande, ignorez cet email.
              </p>
            </div>
          </div>
        `,
      });

      res.json({
        message: "Ton parent a été notifié. Tu pourras modifier ton profil après son accord.",
      });
    } catch (error) {
      console.error("Erreur requestProfileUpdate:", error);
      res.status(500).json({ error: "Erreur lors de la notification du parent" });
    }
  }
}

module.exports = new SafetyController();
