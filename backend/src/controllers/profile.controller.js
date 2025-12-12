const User = require("../models/User");
const bcrypt = require("bcrypt");
const path = require("path");
const fs = require("fs").promises;

class ProfileController {
  /**
   * Obtenir le profil d'un utilisateur (public)
   * GET /api/profile/:userId
   */
  async getPublicProfile(req, res) {
    try {
      const { userId } = req.params;

      const user = await User.findByPk(userId, {
        attributes: [
          "id",
          "pseudo",
          "avatar_url",
          "bio",
          "role",
          "professional_title",
          "verification_status",
          "created_at",
        ],
      });

      if (!user) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }

      res.json({
        profile: user.toPublicJSON(),
      });
    } catch (error) {
      console.error("Erreur getPublicProfile:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération du profil" });
    }
  }

  /**
   * Mettre à jour son propre profil
   * PUT /api/profile
   */
  async updateProfile(req, res) {
    try {
      const userId = req.user.id;
      const {
        bio,
        pseudo,
        professional_title,
        accessibility_settings,
        notification_preferences,
      } = req.body;

      const user = await User.findByPk(userId);

      if (!user) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }

      // Vérifier si le nouveau pseudo est disponible
      if (pseudo && pseudo !== user.pseudo) {
        const existingPseudo = await User.findOne({ where: { pseudo } });
        if (existingPseudo) {
          return res.status(400).json({ error: "Ce pseudo est déjà utilisé" });
        }
      }

      // Préparer les données à mettre à jour
      const updateData = {};

      if (bio !== undefined) updateData.bio = bio;
      if (pseudo !== undefined) updateData.pseudo = pseudo;
      if (professional_title !== undefined && user.isProfessional()) {
        updateData.professional_title = professional_title;
      }
      if (accessibility_settings !== undefined) {
        updateData.accessibility_settings = {
          ...user.accessibility_settings,
          ...accessibility_settings,
        };
      }
      if (notification_preferences !== undefined) {
        updateData.notification_preferences = {
          ...user.notification_preferences,
          ...notification_preferences,
        };
      }

      await user.update(updateData);

      res.json({
        message: "Profil mis à jour avec succès",
        user: user.toSafeJSON(),
      });
    } catch (error) {
      console.error("Erreur updateProfile:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la mise à jour du profil" });
    }
  }

  /**
   * Changer son mot de passe
   * PUT /api/profile/password
   */
  async changePassword(req, res) {
    try {
      const userId = req.user.id;
      const { current_password, new_password } = req.body;

      if (!current_password || !new_password) {
        return res.status(400).json({
          error: "Mot de passe actuel et nouveau mot de passe requis",
        });
      }

      const user = await User.findByPk(userId);

      if (!user) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }

      // Vérifier le mot de passe actuel
      const isPasswordValid = await user.validatePassword(current_password);

      if (!isPasswordValid) {
        return res.status(401).json({ error: "Mot de passe actuel incorrect" });
      }

      // Valider le nouveau mot de passe
      if (new_password.length < 8) {
        return res.status(400).json({
          error: "Le nouveau mot de passe doit contenir au moins 8 caractères",
        });
      }

      // Mettre à jour le mot de passe (le hook beforeUpdate va le hasher)
      await user.update({
        password_hash: new_password,
      });

      res.json({ message: "Mot de passe changé avec succès" });
    } catch (error) {
      console.error("Erreur changePassword:", error);
      res
        .status(500)
        .json({ error: "Erreur lors du changement de mot de passe" });
    }
  }

  /**
   * Upload d'avatar
   * POST /api/profile/avatar
   * Nécessite multer middleware
   */
  async uploadAvatar(req, res) {
    try {
      const userId = req.user.id;

      if (!req.file) {
        return res.status(400).json({ error: "Aucun fichier uploadé" });
      }

      const user = await User.findByPk(userId);

      if (!user) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }

      // Supprimer l'ancien avatar si existant
      if (user.avatar_url) {
        const oldAvatarPath = path.join(
          __dirname,
          "../../uploads/avatars",
          path.basename(user.avatar_url)
        );
        try {
          await fs.unlink(oldAvatarPath);
        } catch (err) {
          console.log("Ancien avatar non trouvé ou déjà supprimé");
        }
      }

      // URL de l'avatar (accessible publiquement)
      const avatarUrl = `/uploads/avatars/${req.file.filename}`;

      await user.update({ avatar_url: avatarUrl });

      res.json({
        message: "Avatar uploadé avec succès",
        avatar_url: avatarUrl,
      });
    } catch (error) {
      console.error("Erreur uploadAvatar:", error);
      res.status(500).json({ error: "Erreur lors de l'upload de l'avatar" });
    }
  }

  /**
   * Supprimer son avatar
   * DELETE /api/profile/avatar
   */
  async deleteAvatar(req, res) {
    try {
      const userId = req.user.id;
      const user = await User.findByPk(userId);

      if (!user) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }

      if (!user.avatar_url) {
        return res.status(400).json({ error: "Aucun avatar à supprimer" });
      }

      // Supprimer le fichier
      const avatarPath = path.join(
        __dirname,
        "../../uploads/avatars",
        path.basename(user.avatar_url)
      );
      try {
        await fs.unlink(avatarPath);
      } catch (err) {
        console.log("Fichier avatar non trouvé");
      }

      await user.update({ avatar_url: null });

      res.json({ message: "Avatar supprimé avec succès" });
    } catch (error) {
      console.error("Erreur deleteAvatar:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la suppression de l'avatar" });
    }
  }

  /**
   * Upload de diplôme (professionnels uniquement)
   * POST /api/profile/diploma
   */
  async uploadDiploma(req, res) {
    try {
      const userId = req.user.id;

      if (!req.file) {
        return res.status(400).json({ error: "Aucun fichier uploadé" });
      }

      const user = await User.findByPk(userId);

      if (!user) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }

      if (!user.isProfessional()) {
        return res.status(403).json({
          error: "Seuls les professionnels peuvent uploader des diplômes",
        });
      }

      // Supprimer l'ancien diplôme si existant
      if (user.diploma_url) {
        const oldDiplomaPath = path.join(
          __dirname,
          "../../uploads/diplomas",
          path.basename(user.diploma_url)
        );
        try {
          await fs.unlink(oldDiplomaPath);
        } catch (err) {
          console.log("Ancien diplôme non trouvé ou déjà supprimé");
        }
      }

      const diplomaUrl = `/uploads/diplomas/${req.file.filename}`;

      await user.update({
        diploma_url: diplomaUrl,
        verification_status: "PENDING", // Repasser en attente de vérification
      });

      res.json({
        message:
          "Diplôme uploadé avec succès. En attente de vérification par un administrateur.",
        diploma_url: diplomaUrl,
      });
    } catch (error) {
      console.error("Erreur uploadDiploma:", error);
      res.status(500).json({ error: "Erreur lors de l'upload du diplôme" });
    }
  }

  /**
   * Obtenir ses propres statistiques
   * GET /api/profile/stats
   */
  async getMyStats(req, res) {
    try {
      const userId = req.user.id;

      // TODO: Calculer les statistiques réelles depuis les différentes tables
      // Pour l'instant, retourner des statistiques basiques

      const user = await User.findByPk(userId);

      const stats = {
        account_created: user.created_at,
        last_login: user.last_login,
        login_count: user.login_count,
        // TODO: Ajouter plus de stats
        // mood_entries_count: await MoodEntry.count({ where: { user_id: userId } }),
        // quizzes_completed: await QuizResult.count({ where: { user_id: userId } }),
        // testimonials_count: await Testimonial.count({ where: { user_id: userId } }),
      };

      res.json({ stats });
    } catch (error) {
      console.error("Erreur getMyStats:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération des statistiques" });
    }
  }

  /**
   * Supprimer son compte
   * DELETE /api/profile
   */
  async deleteAccount(req, res) {
    try {
      const userId = req.user.id;
      const { password } = req.body;

      if (!password) {
        return res.status(400).json({
          error: "Mot de passe requis pour supprimer le compte",
        });
      }

      const user = await User.findByPk(userId);

      if (!user) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }

      // Vérifier le mot de passe
      const isPasswordValid = await user.validatePassword(password);

      if (!isPasswordValid) {
        return res.status(401).json({ error: "Mot de passe incorrect" });
      }

      // Supprimer l'avatar si existant
      if (user.avatar_url) {
        const avatarPath = path.join(
          __dirname,
          "../../uploads/avatars",
          path.basename(user.avatar_url)
        );
        try {
          await fs.unlink(avatarPath);
        } catch (err) {
          console.log("Avatar non trouvé");
        }
      }

      // Supprimer le diplôme si existant
      if (user.diploma_url) {
        const diplomaPath = path.join(
          __dirname,
          "../../uploads/diplomas",
          path.basename(user.diploma_url)
        );
        try {
          await fs.unlink(diplomaPath);
        } catch (err) {
          console.log("Diplôme non trouvé");
        }
      }

      // Supprimer l'utilisateur (cascade va supprimer les données liées)
      await user.destroy();

      res.json({ message: "Compte supprimé avec succès" });
    } catch (error) {
      console.error("Erreur deleteAccount:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la suppression du compte" });
    }
  }
}

module.exports = new ProfileController();
