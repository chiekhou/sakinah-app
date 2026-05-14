const Testimonial = require("../models/Testimonial");
const TestimonialLike = require("../models/TestimonialLike");
const TestimonialComment = require("../models/TestimonialComment");
const Notification = require("../models/Notification");
const User = require("../models/User");
const pushService = require("../services/push.service");

/**
 * Controller pour gérer les témoignages
 */
class TestimonialController {
  /**
   * Créer un témoignage
   * POST /api/testimonials
   */
  async create(req, res) {
    try {
      const { content, mood_level, is_anonymous } = req.body;
      const userId = req.user.id; // Depuis le middleware auth

      // Validation
      if (!content || content.trim().length < 10) {
        return res.status(400).json({
          error: "Le témoignage doit contenir au moins 10 caractères",
        });
      }

      if (content.length > 5000) {
        return res.status(400).json({
          error: "Le témoignage ne peut pas dépasser 5000 caractères",
        });
      }

      // Créer le témoignage
      const testimonial = await Testimonial.create({
        user_id: userId,
        content: content.trim(),
        mood_level: mood_level || null,
        is_anonymous: is_anonymous !== false, // Par défaut true
        status: "PENDING",
      });

      // Notifier les admins
      pushService.notifyAdminNewTestimonial(testimonial.id).catch(() => {});

      // Log de supervision si l'auteur est un mineur
      const author = await User.findByPk(userId, {
        attributes: ["is_minor", "parent_id", "pseudo", "username"],
      });
      if (author?.is_minor && author?.parent_id) {
        Notification.supervisionLog(
          author.parent_id,
          userId,
          author.pseudo || author.username,
          "TESTIMONIAL"
        ).catch(() => {});
      }

      res.status(201).json({
        message:
          "Témoignage créé avec succès ! Il sera visible après modération.",
        testimonial: {
          id: testimonial.id,
          content: testimonial.content,
          mood_level: testimonial.mood_level,
          is_anonymous: testimonial.is_anonymous,
          status: testimonial.status,
          created_at: testimonial.created_at,
        },
      });
    } catch (error) {
      console.error("Erreur create testimonial:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la création du témoignage" });
    }
  }

  /**
   * Récupérer les témoignages approuvés (fil public)
   * GET /api/testimonials
   */
  async getAll(req, res) {
    try {
      const { limit = 50, offset = 0 } = req.query;
      const userId = req.user?.id; // Optionnel

      const testimonials = await Testimonial.getApproved({
        limit: parseInt(limit),
        offset: parseInt(offset),
      });

      // Enrichir avec les infos utilisateur (pseudo anonyme)
      const enrichedTestimonials = await Promise.all(
        testimonials.map(async (t) => {
          const user = await User.findByPk(t.user_id, {
            attributes: ["pseudo"],
          });

          // Vérifier si l'utilisateur a liké
          let hasLiked = false;
          if (userId) {
            hasLiked = await TestimonialLike.hasLiked(userId, t.id);
          }

          return {
            id: t.id,
            content: t.content,
            mood_level: t.mood_level,
            is_anonymous: t.is_anonymous,
            author: t.is_anonymous ? null : user?.pseudo,
            likes_count: t.likes_count,
            comments_count: t.comments_count,
            has_liked: hasLiked,
            created_at: t.created_at,
          };
        })
      );

      res.json({
        testimonials: enrichedTestimonials,
        total: enrichedTestimonials.length,
      });
    } catch (error) {
      console.error("Erreur getAll testimonials:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération des témoignages" });
    }
  }

  /**
   * Récupérer un témoignage par ID
   * GET /api/testimonials/:id
   */
  async getById(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user?.id;

      const testimonial = await Testimonial.findByPk(id);

      if (!testimonial) {
        return res.status(404).json({ error: "Témoignage non trouvé" });
      }

      // Vérifier les permissions
      if (!testimonial.canBeViewedBy(userId)) {
        return res.status(403).json({
          error: "Témoignage en attente de modération",
        });
      }

      // Récupérer les infos utilisateur
      const user = await User.findByPk(testimonial.user_id, {
        attributes: ["pseudo"],
      });

      // Vérifier si l'utilisateur a liké
      let hasLiked = false;
      if (userId) {
        hasLiked = await TestimonialLike.hasLiked(userId, testimonial.id);
      }

      // Récupérer les commentaires approuvés
      const comments = await TestimonialComment.getApprovedForTestimonial(id);
      const enrichedComments = await Promise.all(
        comments.map(async (c) => {
          const commentUser = await User.findByPk(c.user_id, {
            attributes: ["pseudo"],
          });
          return {
            id: c.id,
            content: c.content,
            author: commentUser?.pseudo,
            created_at: c.created_at,
          };
        })
      );

      res.json({
        id: testimonial.id,
        content: testimonial.content,
        mood_level: testimonial.mood_level,
        is_anonymous: testimonial.is_anonymous,
        author: testimonial.is_anonymous ? null : user?.pseudo,
        likes_count: testimonial.likes_count,
        comments_count: testimonial.comments_count,
        has_liked: hasLiked,
        comments: enrichedComments,
        created_at: testimonial.created_at,
      });
    } catch (error) {
      console.error("Erreur getById testimonial:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération du témoignage" });
    }
  }

  /**
   * Liker/Unlike un témoignage
   * POST /api/testimonials/:id/like
   */
  async toggleLike(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id;

      // Vérifier que le témoignage existe et est approuvé
      const testimonial = await Testimonial.findByPk(id);
      if (!testimonial) {
        return res.status(404).json({ error: "Témoignage non trouvé" });
      }

      if (testimonial.status !== "APPROVED") {
        return res.status(403).json({ error: "Témoignage non disponible" });
      }

      // Toggle like
      const result = await TestimonialLike.toggle(userId, id);

      // Si nouveau like, notifier l'auteur (sauf si c'est lui-même)
      if (result.liked && testimonial.user_id !== userId) {
        const user = await User.findByPk(userId, { attributes: ["pseudo"] });
        await Notification.testimonialLiked(
          testimonial.user_id,
          id,
          user.pseudo
        );
        await pushService.notifyTestimonialLiked(
          testimonial.user_id,
          id,
          user.pseudo
        );
      }

      res.json({
        liked: result.liked,
        message: result.liked ? "Témoignage liké !" : "Like retiré",
      });
    } catch (error) {
      console.error("Erreur toggleLike:", error);
      res.status(500).json({ error: "Erreur lors du like" });
    }
  }

  /**
   * Commenter un témoignage
   * POST /api/testimonials/:id/comment
   */
  async addComment(req, res) {
    try {
      const { id } = req.params;
      const { content } = req.body;
      const userId = req.user.id;

      // Validation
      if (!content || content.trim().length === 0) {
        return res
          .status(400)
          .json({ error: "Le commentaire ne peut pas être vide" });
      }

      if (content.length > 1000) {
        return res.status(400).json({
          error: "Le commentaire ne peut pas dépasser 1000 caractères",
        });
      }

      // Vérifier que le témoignage existe et est approuvé
      const testimonial = await Testimonial.findByPk(id);
      if (!testimonial) {
        return res.status(404).json({ error: "Témoignage non trouvé" });
      }

      if (testimonial.status !== "APPROVED") {
        return res.status(403).json({ error: "Témoignage non disponible" });
      }

      // Créer le commentaire (PENDING par défaut)
      const comment = await TestimonialComment.create({
        testimonial_id: id,
        user_id: userId,
        content: content.trim(),
        status: "PENDING",
      });

      // Log de supervision si le commentateur est un mineur
      const commenter = await User.findByPk(userId, {
        attributes: ["is_minor", "parent_id", "pseudo", "username"],
      });
      if (commenter?.is_minor && commenter?.parent_id) {
        Notification.supervisionLog(
          commenter.parent_id,
          userId,
          commenter.pseudo || commenter.username,
          "COMMENT"
        ).catch(() => {});
      }

      res.status(201).json({
        message: "Commentaire envoyé ! Il sera visible après modération.",
        comment: {
          id: comment.id,
          content: comment.content,
          status: comment.status,
          created_at: comment.created_at,
        },
      });
    } catch (error) {
      console.error("Erreur addComment:", error);
      res.status(500).json({ error: "Erreur lors de l'ajout du commentaire" });
    }
  }

  /**
   * Récupérer mes témoignages
   * GET /api/testimonials/my
   */
  async getMyTestimonials(req, res) {
    try {
      const userId = req.user.id;

      const testimonials = await Testimonial.findAll({
        where: { user_id: userId },
        order: [["created_at", "DESC"]],
      });

      res.json({
        testimonials: testimonials.map((t) => ({
          id: t.id,
          content: t.content,
          mood_level: t.mood_level,
          is_anonymous: t.is_anonymous,
          status: t.status,
          likes_count: t.likes_count,
          comments_count: t.comments_count,
          moderation_note: t.moderation_note,
          created_at: t.created_at,
        })),
      });
    } catch (error) {
      console.error("Erreur getMyTestimonials:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération de vos témoignages" });
    }
  }
}

module.exports = new TestimonialController();
