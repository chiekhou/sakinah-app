const Testimonial = require("../models/Testimonial");
const TestimonialComment = require("../models/TestimonialComment");
const Notification = require("../models/Notification");
const User = require("../models/User");

/**
 * Controller Admin - Modération des Témoignages et Commentaires
 */
class AdminModerationController {
  /**
   * Récupérer les témoignages en attente de modération
   * GET /api/admin/testimonials/pending
   */
  async getPendingTestimonials(req, res) {
    try {
      const { limit = 50, offset = 0 } = req.query;

      const testimonials = await Testimonial.getPending({
        limit: parseInt(limit),
        offset: parseInt(offset),
      });

      // Enrichir avec les infos utilisateur
      const enrichedTestimonials = await Promise.all(
        testimonials.map(async (t) => {
          const user = await User.findByPk(t.user_id, {
            attributes: ["id", "username", "email", "pseudo", "age_range"],
          });

          return {
            id: t.id,
            content: t.content,
            mood_level: t.mood_level,
            is_anonymous: t.is_anonymous,
            user: {
              id: user.id,
              username: user.username,
              email: user.email,
              pseudo: user.pseudo,
              age_range: user.age_range,
            },
            created_at: t.created_at,
          };
        })
      );

      res.json({
        testimonials: enrichedTestimonials,
        total: enrichedTestimonials.length,
      });
    } catch (error) {
      console.error("Erreur getPendingTestimonials:", error);
      res.status(500).json({
        error: "Erreur lors de la récupération des témoignages en attente",
      });
    }
  }

  /**
   * Modérer un témoignage (approuver ou rejeter)
   * PUT /api/admin/testimonials/:id/moderate
   */
  async moderateTestimonial(req, res) {
    try {
      const { id } = req.params;
      const { status, moderation_note } = req.body;
      const adminId = req.user.id;

      // Validation
      if (!status || !["APPROVED", "REJECTED"].includes(status)) {
        return res.status(400).json({
          error: "Statut invalide. Utilisez APPROVED ou REJECTED",
        });
      }

      if (status === "REJECTED" && !moderation_note) {
        return res.status(400).json({
          error: "Une raison est requise pour rejeter un témoignage",
        });
      }

      // Modérer le témoignage
      const testimonial = await Testimonial.moderate(
        id,
        adminId,
        status,
        moderation_note
      );

      // Envoyer notification à l'auteur
      if (status === "APPROVED") {
        await Notification.testimonialApproved(testimonial.user_id, id);
      } else if (status === "REJECTED") {
        await Notification.testimonialRejected(
          testimonial.user_id,
          id,
          moderation_note
        );
      }

      res.json({
        message:
          status === "APPROVED"
            ? "Témoignage approuvé avec succès"
            : "Témoignage rejeté",
        testimonial: {
          id: testimonial.id,
          status: testimonial.status,
          moderated_at: testimonial.moderated_at,
          moderation_note: testimonial.moderation_note,
        },
      });
    } catch (error) {
      console.error("Erreur moderateTestimonial:", error);

      if (error.message === "Témoignage non trouvé") {
        return res.status(404).json({ error: error.message });
      }

      res
        .status(500)
        .json({ error: "Erreur lors de la modération du témoignage" });
    }
  }

  /**
   * Récupérer les commentaires en attente de modération
   * GET /api/admin/comments/pending
   */
  async getPendingComments(req, res) {
    try {
      const { limit = 50, offset = 0 } = req.query;

      const comments = await TestimonialComment.getPending({
        limit: parseInt(limit),
        offset: parseInt(offset),
      });

      // Enrichir avec les infos utilisateur et témoignage
      const enrichedComments = await Promise.all(
        comments.map(async (c) => {
          const user = await User.findByPk(c.user_id, {
            attributes: ["id", "username", "email", "pseudo", "age_range"],
          });

          const testimonial = await Testimonial.findByPk(c.testimonial_id, {
            attributes: ["id", "content"],
          });

          return {
            id: c.id,
            content: c.content,
            testimonial: {
              id: testimonial.id,
              content: testimonial.content.substring(0, 100) + "...",
            },
            user: {
              id: user.id,
              username: user.username,
              email: user.email,
              pseudo: user.pseudo,
              age_range: user.age_range,
            },
            created_at: c.created_at,
          };
        })
      );

      res.json({
        comments: enrichedComments,
        total: enrichedComments.length,
      });
    } catch (error) {
      console.error("Erreur getPendingComments:", error);
      res.status(500).json({
        error: "Erreur lors de la récupération des commentaires en attente",
      });
    }
  }

  /**
   * Modérer un commentaire (approuver ou rejeter)
   * PUT /api/admin/comments/:id/moderate
   */
  async moderateComment(req, res) {
    try {
      const { id } = req.params;
      const { status, moderation_note } = req.body;
      const adminId = req.user.id;

      // Validation
      if (!status || !["APPROVED", "REJECTED"].includes(status)) {
        return res.status(400).json({
          error: "Statut invalide. Utilisez APPROVED ou REJECTED",
        });
      }

      if (status === "REJECTED" && !moderation_note) {
        return res.status(400).json({
          error: "Une raison est requise pour rejeter un commentaire",
        });
      }

      // Modérer le commentaire
      const comment = await TestimonialComment.moderate(
        id,
        adminId,
        status,
        moderation_note
      );

      // Envoyer notification à l'auteur du commentaire
      if (status === "APPROVED") {
        await Notification.commentApproved(
          comment.user_id,
          id,
          comment.testimonial_id
        );

        // Notifier l'auteur du témoignage
        const testimonial = await Testimonial.findByPk(comment.testimonial_id);
        if (testimonial && testimonial.user_id !== comment.user_id) {
          const commenter = await User.findByPk(comment.user_id, {
            attributes: ["pseudo"],
          });
          await Notification.testimonialCommented(
            testimonial.user_id,
            comment.testimonial_id,
            commenter.pseudo
          );
        }
      } else if (status === "REJECTED") {
        await Notification.commentRejected(
          comment.user_id,
          id,
          comment.testimonial_id,
          moderation_note
        );
      }

      res.json({
        message:
          status === "APPROVED"
            ? "Commentaire approuvé avec succès"
            : "Commentaire rejeté",
        comment: {
          id: comment.id,
          status: comment.status,
          moderated_at: comment.moderated_at,
          moderation_note: comment.moderation_note,
        },
      });
    } catch (error) {
      console.error("Erreur moderateComment:", error);

      if (error.message === "Commentaire non trouvé") {
        return res.status(404).json({ error: error.message });
      }

      res
        .status(500)
        .json({ error: "Erreur lors de la modération du commentaire" });
    }
  }

  /**
   * Statistiques de modération
   * GET /api/admin/moderation/stats
   */
  async getModerationStats(req, res) {
    try {
      const pendingTestimonials = await Testimonial.count({
        where: { status: "PENDING" },
      });

      const approvedTestimonials = await Testimonial.count({
        where: { status: "APPROVED" },
      });

      const rejectedTestimonials = await Testimonial.count({
        where: { status: "REJECTED" },
      });

      const pendingComments = await TestimonialComment.count({
        where: { status: "PENDING" },
      });

      const approvedComments = await TestimonialComment.count({
        where: { status: "APPROVED" },
      });

      const rejectedComments = await TestimonialComment.count({
        where: { status: "REJECTED" },
      });

      res.json({
        testimonials: {
          pending: pendingTestimonials,
          approved: approvedTestimonials,
          rejected: rejectedTestimonials,
          total:
            pendingTestimonials + approvedTestimonials + rejectedTestimonials,
        },
        comments: {
          pending: pendingComments,
          approved: approvedComments,
          rejected: rejectedComments,
          total: pendingComments + approvedComments + rejectedComments,
        },
        total_pending: pendingTestimonials + pendingComments,
      });
    } catch (error) {
      console.error("Erreur getModerationStats:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération des statistiques" });
    }
  }
}

module.exports = new AdminModerationController();
