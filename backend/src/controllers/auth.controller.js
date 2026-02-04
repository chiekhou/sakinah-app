const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const User = require("../models/User");
const {
  sendVerificationEmail,
  sendPasswordResetEmail,
} = require("../services/email.service");

const JWT_SECRET =
  process.env.JWT_SECRET || "votre_secret_jwt_super_securise_a_changer";
const JWT_EXPIRES_IN = "7d";

/**
 * Générer un pseudo anonyme unique
 */
async function generateUniquePseudo() {
  const adjectives = [
    "Brave",
    "Calme",
    "Joyeux",
    "Serein",
    "Fort",
    "Doux",
    "Sage",
    "Libre",
    "Vif",
    "Zen",
  ];
  const nouns = [
    "Papillon",
    "Océan",
    "Étoile",
    "Nuage",
    "Arbre",
    "Lune",
    "Soleil",
    "Vent",
    "Fleur",
    "Oiseau",
  ];

  let attempts = 0;
  while (attempts < 100) {
    const adj = adjectives[Math.floor(Math.random() * adjectives.length)];
    const noun = nouns[Math.floor(Math.random() * nouns.length)];
    const num = Math.floor(Math.random() * 1000);
    const pseudo = `${adj}${noun}${num}`;

    const existing = await User.findOne({ where: { pseudo } });
    if (!existing) {
      return pseudo;
    }
    attempts++;
  }

  // Fallback
  return `Anonyme${Date.now()}`;
}

class AuthController {
  /**
   * Inscription d'un nouvel utilisateur
   * POST /api/auth/register
   */
  async register(req, res) {
    try {
      const {
        username,
        email,
        password,
        date_of_birth,
        age_range,
        role = "USER",
        professional_title,
        is_minor,
        parent_email,
      } = req.body;

      // Validations
      if (!username || !email || !password || !age_range) {
        return res.status(400).json({
          error: "Username, email, password et age_range sont requis",
        });
      }

      // Vérifier si l'email existe déjà
      const existingUser = await User.findOne({ where: { email } });
      if (existingUser) {
        return res.status(400).json({ error: "Cet email est déjà utilisé" });
      }

      // Vérifier si le username existe déjà
      const existingUsername = await User.findOne({ where: { username } });
      if (existingUsername) {
        return res
          .status(400)
          .json({ error: "Ce nom d'utilisateur est déjà pris" });
      }

      // Valider le rôle
      const validRoles = ["USER", "EDUCATEUR", "PSYCHOLOGUE", "INTERVENANT"];
      if (!validRoles.includes(role)) {
        return res.status(400).json({ error: "Rôle invalide" });
      }

      // Déterminer si l'utilisateur est mineur
      const isMinorUser = is_minor || ["6-12", "13-17"].includes(age_range);

      // Vérifier que l'email parent est fourni pour les mineurs
      if (isMinorUser && !parent_email) {
        return res.status(400).json({
          error: "L'email du parent est requis pour les utilisateurs mineurs",
        });
      }

      // Générer un token de vérification email
      const email_verification_token = crypto.randomBytes(32).toString("hex");
      const email_verification_expires = new Date(
        Date.now() + 24 * 60 * 60 * 1000
      ); // 24h

      // Générer un pseudo anonyme
      const pseudo = await generateUniquePseudo();

      // Déterminer le statut initial selon le rôle et l'âge
      let status = "PENDING";
      let verification_status = "PENDING";

      if (isMinorUser) {
        // Les mineurs doivent avoir le consentement parental
        status = "PENDING_PARENTAL_CONSENT";
        verification_status = null;
      } else if (role === "USER") {
        // Les utilisateurs majeurs doivent juste vérifier leur email
        status = "PENDING";
        verification_status = null;
      } else {
        // Les professionnels doivent être validés par un admin
        status = "PENDING";
        verification_status = "PENDING";
      }

      // Créer l'utilisateur
      const user = await User.create({
        username,
        email,
        password_hash: password, // Le hook beforeCreate va le hasher automatiquement
        date_of_birth,
        age_range,
        role,
        status,
        pseudo,
        professional_title: role !== "USER" ? professional_title : null,
        verification_status: role !== "USER" ? verification_status : null,
        is_minor: isMinorUser,
        email_verification_token,
        email_verification_expires,
        is_email_verified: false,
      });

      // Gérer le consentement parental si mineur
      if (isMinorUser && parent_email) {
        try {
          const ParentalConsent = require("../models/ParentalConsent");
          const {
            getParentalConsentEmail,
          } = require("../utils/email-templates/parental-consent-email");
          const { sendEmail } = require("../services/email.service");

          // Créer le consentement parental
          const consent = await ParentalConsent.createConsent(
            user.id,
            parent_email
          );

          // Générer le lien de confirmation
          const confirmationLink = `${
            process.env.FRONTEND_URL || "http://localhost:3001"
          }/confirm-parental-consent/${consent.consent_token}`;

          // Préparer l'email pour le parent
          const emailData = {
            parentEmail: parent_email,
            childUsername: user.username,
            childEmail: user.email,
            ageRange: user.age_range,
            confirmationLink: confirmationLink,
          };

          const { subject, html } = getParentalConsentEmail(emailData);

          // Envoyer l'email au parent
          await sendEmail(parent_email, subject, html);

          // Marquer comme envoyé
          consent.notification_sent = true;
          consent.notification_sent_date = new Date();
          await consent.save();

          console.log(
            `✅ Email de consentement parental envoyé à ${parent_email}`
          );
        } catch (parentalError) {
          console.error("❌ Erreur consentement parental:", parentalError);
          // On continue l'inscription même si l'email échoue
        }
      }

      // Envoyer l'email de vérification à l'utilisateur
      // (même pour les mineurs, pour qu'ils vérifient leur email)
      try {
        await sendVerificationEmail(email, email_verification_token);
      } catch (emailError) {
        console.error("Erreur envoi email:", emailError);
        // On continue même si l'email échoue
      }

      // Préparer le message de réponse
      let message;
      if (isMinorUser) {
        message =
          "Inscription réussie ! Un email a été envoyé à ton parent/tuteur pour obtenir son consentement. Tu pourras te connecter une fois que le consentement sera confirmé.";
      } else if (role === "USER") {
        message =
          "Inscription réussie ! Vérifie ton email pour activer ton compte.";
      } else {
        message =
          "Inscription réussie ! Vérifie ton email pour activer ton compte et ton compte sera activé après vérification de tes diplômes.";
      }

      res.status(201).json({
        message: message,
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          pseudo: user.pseudo,
          role: user.role,
          status: user.status,
          is_minor: user.is_minor,
          requires_email_verification: true,
          requires_parental_consent: isMinorUser,
          requires_admin_approval: role !== "USER",
          parent_email_sent: isMinorUser ? true : false,
        },
      });
    } catch (error) {
      console.error("Erreur register:", error);
      res.status(500).json({ error: "Erreur lors de l'inscription" });
    }
  }

  /**
   * Vérification de l'email
   * GET /api/auth/verify-email/:token
   */
  async verifyEmail(req, res) {
    try {
      const { token } = req.params;

      const user = await User.findOne({
        where: {
          email_verification_token: token,
        },
      });

      if (!user) {
        return res
          .status(400)
          .json({ error: "Token de vérification invalide" });
      }

      // Vérifier si le token a expiré
      if (new Date() > user.email_verification_expires) {
        return res
          .status(400)
          .json({ error: "Le token a expiré. Demande un nouveau lien." });
      }

      // Activer l'email
      // Tous les utilisateurs passent en ACTIVE après vérification email
      // Les professionnels auront verification_status = PENDING jusqu'à validation admin
      await user.update({
        is_email_verified: true,
        email_verification_token: null,
        email_verification_expires: null,
        status: "ACTIVE", // Tous deviennent ACTIVE après vérification email
      });

      const isProfessional = user.isProfessional();

      res.json({
        message: isProfessional
          ? "Email vérifié ! Tu peux maintenant te connecter et uploader tes diplômes pour validation."
          : "Email vérifié ! Tu peux maintenant te connecter.",
      });
    } catch (error) {
      console.error("Erreur verifyEmail:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la vérification de l'email" });
    }
  }

  /**
   * Connexion
   * POST /api/auth/login
   */
  async login(req, res) {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({ error: "Email et mot de passe requis" });
      }

      // Trouver l'utilisateur
      const user = await User.findOne({ where: { email } });

      if (!user) {
        return res
          .status(401)
          .json({ error: "Email ou mot de passe incorrect" });
      }

      // Vérifier le mot de passe
      const isPasswordValid = await bcrypt.compare(
        password,
        user.password_hash
      );

      if (!isPasswordValid) {
        return res
          .status(401)
          .json({ error: "Email ou mot de passe incorrect" });
      }

      // Vérifier le statut du compte
      if (user.status === "SUSPENDED") {
        return res
          .status(403)
          .json({ error: "Ton compte a été suspendu. Contacte le support." });
      }

      if (user.status === "REJECTED") {
        return res
          .status(403)
          .json({ error: "Ta demande de compte a été rejetée." });
      }

      if (!user.is_email_verified) {
        return res.status(403).json({
          error: "Vérifie ton email avant de te connecter.",
          requires_email_verification: true,
        });
      }

      // Note: Les professionnels peuvent se connecter même avec status PENDING
      // Le frontend les redirigera vers la page d'upload de diplôme
      // Seuls les USERs doivent être ACTIVE pour se connecter
      if (user.status === "PENDING" && user.role === "USER") {
        return res.status(403).json({
          error:
            "Ton compte est en cours d'activation. Réessaie dans quelques instants.",
        });
      }

      // Mettre à jour les stats de connexion
      await user.update({
        last_login: new Date(),
        last_active: new Date(),
        login_count: user.login_count + 1,
      });

      // Générer le JWT
      const token = jwt.sign(
        {
          id: user.id,
          email: user.email,
          role: user.role,
          pseudo: user.pseudo,
        },
        JWT_SECRET,
        { expiresIn: JWT_EXPIRES_IN }
      );

      res.json({
        message: "Connexion réussie",
        token,
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          pseudo: user.pseudo,
          role: user.role,
          status: user.status,
          avatar_url: user.avatar_url,
          is_minor: user.is_minor,
          // Informations pour professionnels
          ...(user.isProfessional() && {
            professional_title: user.professional_title,
            verification_status: user.verification_status,
            diploma_url: user.diploma_url,
            needs_diploma_upload:
              user.verification_status === "PENDING" && !user.diploma_url,
            awaiting_admin_approval:
              user.verification_status === "PENDING" &&
              user.diploma_url !== null,
            is_verified: user.verification_status === "VERIFIED",
          }),
        },
      });
    } catch (error) {
      console.error("Erreur login:", error);
      res.status(500).json({ error: "Erreur lors de la connexion" });
    }
  }

  /**
   * Récupérer les infos de l'utilisateur connecté
   * GET /api/auth/me
   */
  async getMe(req, res) {
    try {
      // req.user est ajouté par le middleware auth
      const user = await User.findByPk(req.user.id, {
        attributes: {
          exclude: [
            "password_hash",
            "email_verification_token",
            "reset_password_token",
          ],
        },
      });

      if (!user) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }

      res.json({ user });
    } catch (error) {
      console.error("Erreur getMe:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération du profil" });
    }
  }

  /**
   * Renvoyer l'email de vérification
   * POST /api/auth/resend-verification
   */
  async resendVerification(req, res) {
    try {
      const { email } = req.body;

      const user = await User.findOne({ where: { email } });

      if (!user) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }

      if (user.is_email_verified) {
        return res.status(400).json({ error: "Email déjà vérifié" });
      }

      // Générer un nouveau token
      const email_verification_token = crypto.randomBytes(32).toString("hex");
      const email_verification_expires = new Date(
        Date.now() + 24 * 60 * 60 * 1000
      );

      await user.update({
        email_verification_token,
        email_verification_expires,
      });

      await sendVerificationEmail(email, email_verification_token);

      res.json({ message: "Email de vérification renvoyé !" });
    } catch (error) {
      console.error("Erreur resendVerification:", error);
      res.status(500).json({ error: "Erreur lors de l'envoi de l'email" });
    }
  }

  /**
   * Demander un reset de mot de passe
   * POST /api/auth/forgot-password
   */
  async forgotPassword(req, res) {
    try {
      const { email } = req.body;

      const user = await User.findOne({ where: { email } });

      if (!user) {
        // Pour des raisons de sécurité, on ne dit pas si l'email existe ou non
        return res.json({
          message:
            "Si cet email existe, un lien de réinitialisation a été envoyé.",
        });
      }

      // Générer un token de reset
      const reset_password_token = crypto.randomBytes(32).toString("hex");
      const reset_password_expires = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24h au lieu de 1h pour debug

      console.log("🔑 Génération token reset password");
      console.log("Email:", email);
      console.log("Token:", reset_password_token);
      console.log("Expire à:", reset_password_expires);

      await user.update({
        reset_password_token,
        reset_password_expires,
      });

      console.log("✅ Token sauvegardé en base de données");

      await sendPasswordResetEmail(email, reset_password_token);

      res.json({
        message:
          "Si cet email existe, un lien de réinitialisation a été envoyé.",
      });
    } catch (error) {
      console.error("Erreur forgotPassword:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la demande de réinitialisation" });
    }
  }

  /**
   * Réinitialiser le mot de passe
   * POST /api/auth/reset-password/:token
   */
  async resetPassword(req, res) {
    try {
      const { token } = req.params;
      const { password } = req.body;

      const user = await User.findOne({
        where: { reset_password_token: token },
      });

      if (!user) {
        console.log("❌ Token introuvable dans la base de données");
        return res.status(400).json({ error: "Token invalide" });
      }

      console.log("✅ User trouvé:", user.email);
      console.log("📅 Token expire à:", user.reset_password_expires);
      console.log("🕐 Date actuelle:", new Date());
      console.log("⏰ Token expiré?", new Date() > user.reset_password_expires);

      if (new Date() > user.reset_password_expires) {
        return res.status(400).json({ error: "Le token a expiré" });
      }

      // Le hook beforeUpdate va hasher automatiquement
      await user.update({
        password_hash: password,
        reset_password_token: null,
        reset_password_expires: null,
      });

      res.json({ message: "Mot de passe réinitialisé avec succès !" });
    } catch (error) {
      console.error("Erreur resetPassword:", error);
      res.status(500).json({ error: "Erreur lors de la réinitialisation" });
    }
  }
}

module.exports = new AuthController();
