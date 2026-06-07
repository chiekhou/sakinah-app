const User = require("../models/User");
const MoodEntry = require("../models/MoodEntry");
const ParentalConsent = require("../models/ParentalConsent");
const Testimonial = require("../models/Testimonial");
const TestimonialLike = require("../models/TestimonialLike");
const TestimonialComment = require("../models/TestimonialComment");
const Notification = require("../models/Notification");
const FCMToken = require("../models/FCMToken");
const PendingProfileUpdate = require("../models/PendingProfileUpdate");
const pushService = require("../services/push.service");
const { sendEmail } = require("../services/email.service");

class ParentController {
  /**
   * Récupérer le profil de l'enfant lié au parent connecté
   * GET /api/parent/child
   */
  async getChildProfile(req, res) {
    try {
      const children = await User.findAll({
        where: { parent_id: req.user.id },
        attributes: [
          "id",
          "username",
          "pseudo",
          "email",
          "age_range",
          "avatar_url",
          "status",
          "created_at",
          "last_active",
          "accessibility_settings",
        ],
      });

      if (!children.length) {
        return res.status(200).json({ children: [] });
      }

      // Récupérer le consentement de chaque enfant
      const childrenWithConsent = await Promise.all(
        children.map(async (child) => {
          const consent = await ParentalConsent.findOne({
            where: { user_id: child.id },
            attributes: ["consent_given", "consent_date", "revoked"],
          });
          return {
            ...child.toJSON(),
            consent: consent ? consent.toJSON() : null,
          };
        }),
      );

      res.status(200).json({ children: childrenWithConsent });
    } catch (error) {
      console.error("Erreur getChildProfile:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération du profil" });
    }
  }

  /**
   * Récupérer les activités de l'enfant (humeurs, quiz, articles)
   * GET /api/parent/child/activities
   */
  async getChildActivities(req, res) {
    try {
      const { child_id } = req.query;

      const where = child_id
        ? { id: child_id, parent_id: req.user.id }
        : { parent_id: req.user.id };

      const child = await User.findOne({ where });

      if (!child) {
        return res.status(404).json({ error: "Aucun enfant lié à ce compte" });
      }

      // Humeurs des 30 derniers jours
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      const moods = await MoodEntry.findAll({
        where: { user_id: child.id },
        order: [["timestamp", "DESC"]],
        limit: 30,
        attributes: ["mood_level", "note", "timestamp"],
      });

      // Calcul humeur moyenne
      const avgMood =
        moods.length > 0
          ? (
              moods.reduce((sum, m) => sum + m.mood_level, 0) / moods.length
            ).toFixed(1)
          : null;

      res.status(200).json({
        child_id: child.id,
        child_username: child.username,
        activities: {
          moods: {
            entries: moods,
            average: avgMood,
            count: moods.length,
          },
        },
      });
    } catch (error) {
      console.error("Erreur getChildActivities:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération des activités" });
    }
  }

  /**
   * Supprimer le compte de l'enfant
   * DELETE /api/parent/child
   */
  async deleteChildAccount(req, res) {
    try {
      const { child_id } = req.body;
      const where = child_id
        ? { id: child_id, parent_id: req.user.id }
        : { parent_id: req.user.id };

      const child = await User.findOne({ where });

      if (!child) {
        return res.status(404).json({ error: "Aucun enfant lié à ce compte" });
      }

      // Supprimer toutes les données liées avant de supprimer l'utilisateur
      // (évite les erreurs de contrainte de clé étrangère)
      const childId = child.id;
      await FCMToken.destroy({ where: { user_id: childId } });
      await Notification.destroy({ where: { user_id: childId } });
      await MoodEntry.destroy({ where: { user_id: childId } });

      // Pour les témoignages : supprimer likes/commentaires puis les témoignages
      const testimonials = await Testimonial.findAll({ where: { user_id: childId } });
      for (const t of testimonials) {
        await TestimonialLike.destroy({ where: { testimonial_id: t.id } });
        await TestimonialComment.destroy({ where: { testimonial_id: t.id } });
      }
      await TestimonialLike.destroy({ where: { user_id: childId } });
      await TestimonialComment.destroy({ where: { user_id: childId } });
      await Testimonial.destroy({ where: { user_id: childId } });

      // Supprimer les consentements parentaux (toutes entrées, actives ou non)
      await ParentalConsent.destroy({ where: { user_id: childId } });

      await child.destroy();

      res.status(200).json({
        message: "Le compte de votre enfant a été supprimé avec succès",
      });
    } catch (error) {
      console.error("Erreur deleteChildAccount:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la suppression du compte" });
    }
  }

  /**
   * Révoquer le consentement depuis le dashboard parent
   * POST /api/parent/revoke
   */
  async revokeConsent(req, res) {
    try {
      const { reason, child_id } = req.body;

      const where = child_id
        ? { id: child_id, parent_id: req.user.id }
        : { parent_id: req.user.id };

      const child = await User.findOne({ where });

      if (!child) {
        return res.status(404).json({ error: "Aucun enfant lié à ce compte" });
      }

      await ParentalConsent.revokeConsent(
        child.id,
        reason || "Révocation par le parent",
      );

      child.status = "SUSPENDED";
      await child.save();

      res.status(200).json({
        message:
          "Consentement révoqué. Le compte de votre enfant a été désactivé.",
      });
    } catch (error) {
      console.error("Erreur revokeConsent parent:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la révocation du consentement" });
    }
  }

  /**
   * Créer un compte enfant directement depuis le dashboard parent
   * POST /api/parent/add-child
   */
  async addChild(req, res) {
    try {
      const { username, email, password, age_range } = req.body;

      if (!username || !email || !password || !age_range) {
        return res.status(400).json({ error: "Tous les champs sont requis" });
      }

      if (password.length < 8) {
        return res.status(400).json({ error: "Le mot de passe doit faire au moins 8 caractères" });
      }

      const existing = await User.findOne({ where: { email } });
      if (existing) {
        return res.status(409).json({ error: "Un compte existe déjà avec cet email" });
      }

      const child = await User.create({
        username,
        email,
        password_hash: password,
        age_range,
        role: "USER",
        status: "ACTIVE",
        is_email_verified: true,
        is_minor: true,
        parent_id: req.user.id,
        pseudo: username,
      });

      res.status(201).json({
        message: "Compte enfant créé avec succès",
        child: { id: child.id, username: child.username, email: child.email },
      });
    } catch (error) {
      console.error("Erreur addChild:", error);
      res.status(500).json({ error: "Erreur lors de la création du compte" });
    }
  }

  /**
   * Envoyer une demande de suppression de compte à l'équipe Sakinah
   * POST /api/parent/delete-request
   */
  async sendDeleteRequest(req, res) {
    try {
      const parent = await User.findByPk(req.user.id);
      const child = await User.findOne({ where: { parent_id: req.user.id } });

      const subject = "Demande de suppression de compte - Sakinah";
      const html = `
        <h2>Demande de suppression de compte</h2>
        <p><strong>Parent :</strong> ${parent.email}</p>
        ${child ? `<p><strong>Enfant :</strong> ${child.username} (${child.email})</p>` : ""}
        <p><strong>Date :</strong> ${new Date().toLocaleDateString("fr-FR")}</p>
        <p>Merci de traiter cette demande dans les plus brefs délais.</p>
      `;

      await sendEmail(
        process.env.SUPPORT_EMAIL || "st.services92@gmail.com",
        subject,
        html,
      );

      res.status(200).json({
        message:
          "Votre demande de suppression a bien été envoyée. Notre équipe vous contactera sous 48h.",
      });
    } catch (error) {
      console.error("Erreur sendDeleteRequest:", error);
      res.status(500).json({ error: "Erreur lors de l'envoi de la demande" });
    }
  }
  /**
   * Activer / désactiver les publications communautaires d'un enfant
   * PATCH /api/parent/child/permissions
   */
  async toggleChildPosting(req, res) {
    try {
      const { child_id, can_post_content } = req.body;

      if (typeof can_post_content !== "boolean") {
        return res.status(400).json({ error: "can_post_content doit être un booléen" });
      }

      const child = await User.findOne({
        where: { id: child_id, parent_id: req.user.id, is_minor: true },
      });

      if (!child) {
        return res.status(404).json({ error: "Enfant introuvable" });
      }

      const updatedSettings = {
        ...child.accessibility_settings,
        can_post_content,
      };

      await child.update({ accessibility_settings: updatedSettings });

      res.status(200).json({
        message: can_post_content
          ? "Publications activées pour cet enfant."
          : "Publications désactivées pour cet enfant.",
        can_post_content,
      });
    } catch (error) {
      console.error("Erreur toggleChildPosting:", error);
      res.status(500).json({ error: "Erreur lors de la mise à jour des permissions" });
    }
  }
  /**
   * Récupérer le journal de supervision pour un enfant
   * GET /api/parent/child/supervision-logs?child_id=xxx
   */
  async getSupervisionLogs(req, res) {
    try {
      const { child_id } = req.query;
      if (!child_id) {
        return res.status(400).json({ error: "child_id requis" });
      }

      // Vérifier que l'enfant appartient bien à ce parent
      const child = await User.findOne({
        where: { id: child_id, parent_id: req.user.id },
      });
      if (!child) {
        return res.status(404).json({ error: "Enfant introuvable" });
      }

      const logs = await Notification.getSupervisionLogs(
        req.user.id,
        child_id
      );

      res.json({
        logs: logs.map((l) => ({
          id: l.id,
          title: l.title,
          message: l.message,
          action: l.metadata?.action,
          created_at: l.created_at,
          is_read: l.is_read,
        })),
      });
    } catch (error) {
      console.error("Erreur getSupervisionLogs:", error);
      res.status(500).json({ error: "Erreur lors de la récupération des logs" });
    }
  }
  /**
   * Récupérer les modifications de profil en attente pour un enfant
   * GET /api/parent/child/pending-updates?child_id=xxx
   */
  async getPendingUpdates(req, res) {
    try {
      const { child_id } = req.query;
      if (!child_id) {
        return res.status(400).json({ error: "child_id requis" });
      }

      const child = await User.findOne({
        where: { id: child_id, parent_id: req.user.id },
      });
      if (!child) {
        return res.status(404).json({ error: "Enfant introuvable" });
      }

      const pending = await PendingProfileUpdate.findAll({
        where: { user_id: child_id, status: "PENDING" },
        order: [["created_at", "DESC"]],
      });

      res.json({
        pending_updates: pending.map((p) => ({
          id: p.id,
          changes: p.changes,
          created_at: p.created_at,
        })),
      });
    } catch (error) {
      console.error("Erreur getPendingUpdates:", error);
      res.status(500).json({ error: "Erreur lors de la récupération" });
    }
  }

  /**
   * Approuver une modification de profil — applique les changements
   * POST /api/parent/child/approve-update
   * Body: { update_id }
   */
  async approveUpdate(req, res) {
    try {
      const { update_id } = req.body;
      if (!update_id) {
        return res.status(400).json({ error: "update_id requis" });
      }

      const pending = await PendingProfileUpdate.findByPk(update_id);
      if (!pending) {
        return res.status(404).json({ error: "Demande introuvable" });
      }

      // Vérifier que l'enfant appartient bien à ce parent
      const child = await User.findOne({
        where: { id: pending.user_id, parent_id: req.user.id },
      });
      if (!child) {
        return res.status(403).json({ error: "Accès refusé" });
      }

      if (pending.status !== "PENDING") {
        return res.status(400).json({ error: "Cette demande a déjà été traitée" });
      }

      // Appliquer les changements au profil de l'enfant
      const allowedFields = ["pseudo", "bio", "avatar_url"];
      const updateData = {};
      for (const key of allowedFields) {
        if (pending.changes[key] !== undefined) {
          updateData[key] = pending.changes[key];
        }
      }
      await child.update(updateData);

      // Marquer comme approuvé
      await pending.update({ status: "APPROVED", reviewed_at: new Date() });

      // Notifier l'enfant
      pushService.sendToUser(
        child.id,
        {
          title: "✅ Modification approuvée",
          body: "Ton parent a approuvé la modification de ton profil.",
        },
        { type: "PROFILE_UPDATE_APPROVED" }
      ).catch(() => {});

      res.json({ message: "Modification approuvée et appliquée au profil." });
    } catch (error) {
      console.error("Erreur approveUpdate:", error);
      res.status(500).json({ error: "Erreur lors de l'approbation" });
    }
  }

  /**
   * Rejeter une modification de profil
   * POST /api/parent/child/reject-update
   * Body: { update_id, reason? }
   */
  async rejectUpdate(req, res) {
    try {
      const { update_id, reason } = req.body;
      if (!update_id) {
        return res.status(400).json({ error: "update_id requis" });
      }

      const pending = await PendingProfileUpdate.findByPk(update_id);
      if (!pending) {
        return res.status(404).json({ error: "Demande introuvable" });
      }

      const child = await User.findOne({
        where: { id: pending.user_id, parent_id: req.user.id },
      });
      if (!child) {
        return res.status(403).json({ error: "Accès refusé" });
      }

      if (pending.status !== "PENDING") {
        return res.status(400).json({ error: "Cette demande a déjà été traitée" });
      }

      await pending.update({
        status: "REJECTED",
        rejection_reason: reason || null,
        reviewed_at: new Date(),
      });

      // Notifier l'enfant
      pushService.sendToUser(
        child.id,
        {
          title: "❌ Modification refusée",
          body: reason
            ? `Ton parent a refusé la modification : ${reason}`
            : "Ton parent a refusé la modification de ton profil.",
        },
        { type: "PROFILE_UPDATE_REJECTED" }
      ).catch(() => {});

      res.json({ message: "Modification refusée." });
    } catch (error) {
      console.error("Erreur rejectUpdate:", error);
      res.status(500).json({ error: "Erreur lors du refus" });
    }
  }
}

module.exports = new ParentController();
