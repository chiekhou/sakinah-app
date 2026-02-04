const User = require("../models/User");
const { Op } = require("sequelize");

class AdminController {
  /**
   * Dashboard - Statistiques globales
   * GET /api/admin/dashboard
   */
  async getDashboard(req, res) {
    try {
      // Statistiques utilisateurs
      const totalUsers = await User.count();
      const activeUsers = await User.count({ where: { status: "ACTIVE" } });
      const pendingUsers = await User.count({ where: { status: "PENDING" } });
      const suspendedUsers = await User.count({
        where: { status: "SUSPENDED" },
      });

      // Utilisateurs par rôle
      const usersByRole = await User.findAll({
        attributes: [
          "role",
          [User.sequelize.fn("COUNT", User.sequelize.col("id")), "count"],
        ],
        group: ["role"],
      });

      // Professionnels en attente de vérification
      const pendingProfessionals = await User.count({
        where: {
          role: {
            [Op.in]: ["EDUCATEUR", "PSYCHOLOGUE", "INTERVENANT"],
          },
          verification_status: "PENDING",
        },
      });

      // Inscriptions des 7 derniers jours
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

      const recentSignups = await User.count({
        where: {
          created_at: {
            [Op.gte]: sevenDaysAgo,
          },
        },
      });

      // Derniers utilisateurs inscrits
      const latestUsers = await User.findAll({
        limit: 10,
        order: [["created_at", "DESC"]],
        attributes: ["id", "username", "email", "role", "status", "created_at"],
      });

      // TODO: Ajouter stats des témoignages, signalements, etc.

      res.json({
        stats: {
          users: {
            total: totalUsers,
            active: activeUsers,
            pending: pendingUsers,
            suspended: suspendedUsers,
            recent_signups: recentSignups,
          },
          by_role: usersByRole,
          pending_professionals: pendingProfessionals,
        },
        latest_users: latestUsers,
      });
    } catch (error) {
      console.error("Erreur getDashboard:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération du dashboard" });
    }
  }

  /**
   * Lister tous les utilisateurs avec filtres et pagination
   * GET /api/admin/users?page=1&limit=20&role=USER&status=ACTIVE&search=john
   */
  async listUsers(req, res) {
    try {
      const {
        page = 1,
        limit = 20,
        role,
        status,
        search,
        sort_by = "created_at",
        sort_order = "DESC",
      } = req.query;

      const offset = (parseInt(page) - 1) * parseInt(limit);

      // Construire les filtres
      const where = {};

      // Filtre par rôle
      if (role) {
        const validRoles = [
          "USER",
          "EDUCATEUR",
          "PSYCHOLOGUE",
          "INTERVENANT",
          "ADMIN",
        ];
        if (validRoles.includes(role.toUpperCase())) {
          where.role = role.toUpperCase();
        } else {
          return res.status(400).json({
            error:
              "Rôle invalide. Valeurs possibles: USER, EDUCATEUR, PSYCHOLOGUE, INTERVENANT, ADMIN",
          });
        }
      }

      // Filtre par statut
      if (status) {
        const validStatuses = ["PENDING", "ACTIVE", "SUSPENDED", "REJECTED"];
        if (validStatuses.includes(status.toUpperCase())) {
          where.status = status.toUpperCase();
        } else {
          return res.status(400).json({
            error:
              "Statut invalide. Valeurs possibles: PENDING, ACTIVE, SUSPENDED, REJECTED",
          });
        }
      }

      // Filtre de recherche
      if (search && search.trim() !== "") {
        where[Op.or] = [
          { username: { [Op.iLike]: `%${search}%` } },
          { email: { [Op.iLike]: `%${search}%` } },
          { pseudo: { [Op.iLike]: `%${search}%` } },
        ];
      }

      // Valider sort_by
      const validSortFields = [
        "created_at",
        "updated_at",
        "username",
        "email",
        "last_login",
        "login_count",
      ];
      const sortBy = validSortFields.includes(sort_by) ? sort_by : "created_at";
      const sortOrder = sort_order.toUpperCase() === "ASC" ? "ASC" : "DESC";

      // Récupérer les utilisateurs
      const { count, rows: users } = await User.findAndCountAll({
        where,
        limit: parseInt(limit),
        offset,
        order: [[sortBy, sortOrder]],
        attributes: {
          exclude: [
            "password_hash",
            "email_verification_token",
            "reset_password_token",
          ],
        },
      });

      res.json({
        users,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(count / parseInt(limit)),
        },
        filters_applied: {
          role: role || "all",
          status: status || "all",
          search: search || "none",
          sort_by: sortBy,
          sort_order: sortOrder,
        },
      });
    } catch (error) {
      console.error("Erreur listUsers:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération des utilisateurs" });
    }
  }

  /**
   * Voir les détails complets d'un utilisateur
   * GET /api/admin/users/:userId
   */
  async getUserDetails(req, res) {
    try {
      const { userId } = req.params;

      const user = await User.findByPk(userId, {
        attributes: { exclude: ["password_hash"] },
      });

      if (!user) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }

      // TODO: Ajouter les stats de l'utilisateur
      // - Nombre de témoignages
      // - Nombre de quiz complétés
      // - Nombre de signalements reçus
      // - etc.

      res.json({
        user,
        // stats: { ... }
      });
    } catch (error) {
      console.error("Erreur getUserDetails:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération de l'utilisateur" });
    }
  }

  /**
   * Changer le statut d'un utilisateur
   * PATCH /api/admin/users/:userId/status
   */
  async updateUserStatus(req, res) {
    try {
      const { userId } = req.params;
      const { status, reason } = req.body;

      const validStatuses = ["ACTIVE", "SUSPENDED", "REJECTED"];
      if (!validStatuses.includes(status)) {
        return res.status(400).json({ error: "Statut invalide" });
      }

      const user = await User.findByPk(userId);

      if (!user) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }

      await user.update({ status });

      // TODO: Envoyer un email à l'utilisateur pour l'informer
      console.log(
        `📧 Email à envoyer à ${user.email}: Statut changé à ${status}`
      );
      if (reason) {
        console.log(`Raison: ${reason}`);
      }

      res.json({
        message: `Statut de l'utilisateur changé à ${status}`,
        user: user.toSafeJSON(),
      });
    } catch (error) {
      console.error("Erreur updateUserStatus:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la mise à jour du statut" });
    }
  }

  /**
   * Supprimer un utilisateur (admin only)
   * DELETE /api/admin/users/:userId
   */
  async deleteUser(req, res) {
    try {
      const { userId } = req.params;
      const { reason } = req.body;

      // Empêcher de se supprimer soi-même
      if (userId === req.user.id) {
        return res
          .status(400)
          .json({ error: "Vous ne pouvez pas supprimer votre propre compte" });
      }

      const user = await User.findByPk(userId);

      if (!user) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }

      // Log avant suppression
      console.log(
        `🗑️ Admin ${req.user.email} supprime l'utilisateur ${user.email}`
      );
      if (reason) {
        console.log(`Raison: ${reason}`);
      }

      await user.destroy();

      res.json({ message: "Utilisateur supprimé avec succès" });
    } catch (error) {
      console.error("Erreur deleteUser:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la suppression de l'utilisateur" });
    }
  }

  /**
   * Lister les professionnels en attente de vérification
   * GET /api/admin/professionals/pending
   */
  async listPendingProfessionals(req, res) {
    try {
      // Debug: voir tous les professionnels d'abord
      const allProfessionals = await User.findAll({
        where: {
          role: {
            [Op.in]: ["EDUCATEUR", "PSYCHOLOGUE", "INTERVENANT"],
          },
        },
        attributes: [
          "id",
          "email",
          "role",
          "status",
          "verification_status",
          "diploma_url",
          "is_email_verified",
        ],
      });

      console.log(
        `📊 Debug: Total professionnels en base: ${allProfessionals.length}`
      );
      allProfessionals.forEach((p) => {
        console.log(
          `   - ${p.email}: role=${p.role}, status=${p.status}, verification=${
            p.verification_status
          }, diploma=${p.diploma_url ? "OUI" : "NON"}, email_verified=${
            p.is_email_verified
          }`
        );
      });

      // Filtrer pour avoir seulement ceux en attente avec diplôme
      const professionals = allProfessionals.filter(
        (p) =>
          p.verification_status === "PENDING" &&
          p.diploma_url !== null &&
          p.diploma_url !== "" &&
          p.is_email_verified === true
      );

      console.log(
        `✅ Professionnels en attente avec diplôme: ${professionals.length}`
      );

      res.json({
        professionals,
        count: professionals.length,
        debug: {
          total_professionals: allProfessionals.length,
          with_diploma: allProfessionals.filter((p) => p.diploma_url !== null)
            .length,
          with_email_verified: allProfessionals.filter(
            (p) => p.is_email_verified === true
          ).length,
          pending_verification: allProfessionals.filter(
            (p) => p.verification_status === "PENDING"
          ).length,
        },
      });
    } catch (error) {
      console.error("Erreur listPendingProfessionals:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération des professionnels" });
    }
  }

  /**
   * Vérifier/Approuver un professionnel
   * POST /api/admin/professionals/:userId/verify
   */
  async verifyProfessional(req, res) {
    try {
      const { userId } = req.params;
      const { decision, note } = req.body; // decision: 'VERIFIED' ou 'REJECTED'

      if (!["VERIFIED", "REJECTED"].includes(decision)) {
        return res
          .status(400)
          .json({ error: "Décision invalide (VERIFIED ou REJECTED)" });
      }

      const professional = await User.findByPk(userId);

      if (!professional) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }

      if (!professional.isProfessional()) {
        return res
          .status(400)
          .json({ error: "Cet utilisateur n'est pas un professionnel" });
      }

      // Mettre à jour le statut de vérification
      await professional.update({
        verification_status: decision,
        verified_at: new Date(),
        verified_by: req.user.id,
        status: decision === "VERIFIED" ? "ACTIVE" : "REJECTED",
      });

      // TODO: Envoyer un email au professionnel
      console.log(`📧 Email à envoyer à ${professional.email}`);
      console.log(`Décision: ${decision}`);
      if (note) {
        console.log(`Note: ${note}`);
      }

      res.json({
        message:
          decision === "VERIFIED"
            ? "Professionnel vérifié et activé avec succès"
            : "Demande rejetée",
        user: professional.toSafeJSON(),
      });
    } catch (error) {
      console.error("Erreur verifyProfessional:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la vérification du professionnel" });
    }
  }

  /**
   * Obtenir les logs d'activité récents (TODO: implémenter système de logs)
   * GET /api/admin/activity-logs
   */
  async getActivityLogs(req, res) {
    try {
      // TODO: Implémenter un système de logs
      // Pour l'instant, retourner une liste vide

      const logs = [
        {
          id: 1,
          action: "USER_SUSPENDED",
          admin_id: req.user.id,
          target_user_id: "some-uuid",
          timestamp: new Date(),
          details: "Compte suspendu pour non-respect des règles",
        },
      ];

      res.json({
        logs,
        message: "Système de logs à implémenter",
      });
    } catch (error) {
      console.error("Erreur getActivityLogs:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération des logs" });
    }
  }

  /**
   * Promouvoir un utilisateur en admin
   * POST /api/admin/users/:userId/promote
   */
  async promoteToAdmin(req, res) {
    try {
      const { userId } = req.params;

      const user = await User.findByPk(userId);

      if (!user) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }

      if (user.role === "ADMIN") {
        return res
          .status(400)
          .json({ error: "Cet utilisateur est déjà admin" });
      }

      await user.update({
        role: "ADMIN",
        status: "ACTIVE",
      });

      console.log(`👑 ${user.email} a été promu ADMIN par ${req.user.email}`);

      res.json({
        message: "Utilisateur promu en administrateur",
        user: user.toSafeJSON(),
      });
    } catch (error) {
      console.error("Erreur promoteToAdmin:", error);
      res.status(500).json({ error: "Erreur lors de la promotion" });
    }
  }

  /**
   * Télécharger le diplôme d'un professionnel
   * GET /api/admin/professionals/:userId/diploma
   */
  async viewDiploma(req, res) {
    try {
      const { userId } = req.params;

      const user = await User.findByPk(userId);

      if (!user) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }

      if (!user.diploma_url) {
        return res.status(404).json({ error: "Aucun diplôme uploadé" });
      }

      // Retourner l'URL du diplôme
      res.json({
        diploma_url: user.diploma_url,
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          role: user.role,
          professional_title: user.professional_title,
          verification_status: user.verification_status,
        },
      });
    } catch (error) {
      console.error("Erreur viewDiploma:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération du diplôme" });
    }
  }
}

module.exports = new AdminController();
