// Service d'envoi de notifications push via Firebase Cloud Messaging
// Pattern similaire à email.service.js

const cron = require("node-cron");
const FCMToken = require("../models/FCMToken");
const User = require("../models/User");

// Firebase Admin SDK - chargé dynamiquement
let admin = null;
let firebaseInitialized = false;

/**
 * Initialize Firebase Admin SDK
 */
function initializeFirebase() {
  if (firebaseInitialized) return true;

  // Check if firebase-admin is installed
  try {
    admin = require("firebase-admin");
  } catch (error) {
    console.warn("⚠️ firebase-admin non installé - npm install firebase-admin");
    return false;
  }

  // Check for credentials
  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY;

  if (!projectId || !clientEmail || !privateKey) {
    if (process.env.NODE_ENV === "production") {
      console.error("❌ Variables Firebase manquantes en production!");
      console.error(
        "   Requis: FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY",
      );
    } else {
      console.warn(
        "⚠️ Firebase non configuré - Push notifications désactivées",
      );
    }
    return false;
  }

  try {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: projectId,
        clientEmail: clientEmail,
        privateKey: privateKey.replace(/\\n/g, "\n"),
      }),
    });

    firebaseInitialized = true;
    console.log("✅ Firebase Admin SDK initialisé");
    return true;
  } catch (error) {
    console.error("❌ Erreur initialisation Firebase:", error.message);
    return false;
  }
}

// Initialize on module load
initializeFirebase();

/**
 * Send push notification to a single user
 * @param {string} userId - User ID to send notification to
 * @param {object} notification - Notification data { title, body }
 * @param {object} data - Additional data payload
 */
async function sendToUser(userId, notification, data = {}) {
  /*
  console.log("==============================================");
  console.log("📱 ENVOI NOTIFICATION PUSH");
  console.log("==============================================");
  console.log(`User ID: ${userId}`);
  console.log(`Titre: ${notification.title}`);
  console.log(`Message: ${notification.body}`);
  console.log("==============================================");*/

  if (!firebaseInitialized) {
    console.warn("⚠️ Firebase non initialisé - Notification non envoyée");
    console.log("==============================================\n");
    return { success: false, reason: "firebase_not_initialized" };
  }

  try {
    // Get user's FCM tokens
    const tokens = await FCMToken.getTokensForUser(userId);

    if (tokens.length === 0) {
      console.log("⚠️ Aucun token FCM pour cet utilisateur");
      console.log("==============================================\n");
      return { success: false, reason: "no_tokens" };
    }

    const tokenStrings = tokens.map((t) => t.token);

    // Send to all user devices
    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: {
        ...Object.fromEntries(
          Object.entries(data).map(([k, v]) => [k, String(v)]),
        ),
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      tokens: tokenStrings,
    };

    const response = await admin.messaging().sendEachForMulticast(message);

    console.log(`✅ Envoyé: ${response.successCount}/${tokenStrings.length}`);

    // Handle invalid tokens
    if (response.failureCount > 0) {
      const invalidTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          const errorCode = resp.error?.code;
          if (
            errorCode === "messaging/invalid-registration-token" ||
            errorCode === "messaging/registration-token-not-registered"
          ) {
            invalidTokens.push(tokenStrings[idx]);
          }
        }
      });

      if (invalidTokens.length > 0) {
        await FCMToken.removeInvalidTokens(invalidTokens);
        console.log(`🗑️ ${invalidTokens.length} tokens invalides supprimés`);
      }
    }

    console.log("==============================================\n");
    return { success: true, sent: response.successCount };
  } catch (error) {
    console.error("❌ Erreur envoi push:", error.message);
    console.log("==============================================\n");
    return { success: false, error: error.message };
  }
}

/**
 * Send push notification to multiple users
 */
async function sendToUsers(userIds, notification, data = {}) {
  const results = await Promise.all(
    userIds.map((userId) => sendToUser(userId, notification, data)),
  );
  return results;
}

// ============================================
// NOTIFICATIONS SPÉCIFIQUES
// ============================================

/**
 * Notification: Témoignage approuvé
 */
async function notifyTestimonialApproved(userId, testimonialId) {
  return sendToUser(
    userId,
    {
      title: "🎉 Témoignage publié !",
      body: "Ton témoignage a été approuvé et est maintenant visible par la communauté.",
    },
    {
      type: "TESTIMONIAL_APPROVED",
      testimonial_id: testimonialId,
    },
  );
}

/**
 * Notification: Témoignage rejeté
 */
async function notifyTestimonialRejected(userId, testimonialId, reason) {
  return sendToUser(
    userId,
    {
      title: "Témoignage non publié",
      body: reason
        ? `Ton témoignage n'a pas pu être publié. Raison: ${reason.substring(0, 80)}`
        : "Ton témoignage n'a pas pu être publié.",
    },
    {
      type: "TESTIMONIAL_REJECTED",
      testimonial_id: testimonialId,
    },
  );
}

/**
 * Notification: Témoignage liké
 */
async function notifyTestimonialLiked(userId, testimonialId, likerPseudo) {
  return sendToUser(
    userId,
    {
      title: "❤️ Nouveau like !",
      body: `${likerPseudo} a aimé ton témoignage.`,
    },
    {
      type: "TESTIMONIAL_LIKED",
      testimonial_id: testimonialId,
    },
  );
}

/**
 * Notification: Nouveau commentaire sur témoignage
 */
async function notifyTestimonialCommented(
  userId,
  testimonialId,
  commenterPseudo,
) {
  return sendToUser(
    userId,
    {
      title: "💬 Nouveau commentaire !",
      body: `${commenterPseudo} a commenté ton témoignage.`,
    },
    {
      type: "TESTIMONIAL_COMMENTED",
      testimonial_id: testimonialId,
    },
  );
}

/**
 * Notification: Commentaire approuvé
 */
async function notifyCommentApproved(userId, commentId, testimonialId) {
  return sendToUser(
    userId,
    {
      title: "💬 Commentaire publié !",
      body: "Ton commentaire a été approuvé et est maintenant visible.",
    },
    {
      type: "COMMENT_APPROVED",
      comment_id: commentId,
      testimonial_id: testimonialId,
    },
  );
}

/**
 * Notification: Commentaire rejeté
 */
async function notifyCommentRejected(userId, commentId, reason) {
  return sendToUser(
    userId,
    {
      title: "Commentaire non publié",
      body: reason
        ? `Ton commentaire n'a pas pu être publié. Raison: ${reason.substring(0, 80)}`
        : "Ton commentaire n'a pas pu être publié.",
    },
    {
      type: "COMMENT_REJECTED",
      comment_id: commentId,
    },
  );
}

/**
 * Notification: Nouveau témoignage en attente de modération (admins)
 */
async function notifyAdminNewTestimonial(testimonialId) {
  try {
    const admins = await User.findAll({ where: { role: "ADMIN", status: "ACTIVE" } });
    const adminIds = admins.map((a) => a.id);
    if (adminIds.length === 0) return;
    return sendToUsers(
      adminIds,
      {
        title: "📝 Nouveau témoignage",
        body: "Un nouveau témoignage est en attente de modération.",
      },
      {
        type: "NEW_TESTIMONIAL_PENDING",
        testimonial_id: testimonialId,
      },
    );
  } catch (e) {
    console.error("notifyAdminNewTestimonial error:", e);
  }
}

/**
 * Rappel quotidien (appelé par un cron job)
 */
async function sendDailyReminder() {
  console.log("==============================================");
  console.log("📱 ENVOI RAPPELS QUOTIDIENS");
  console.log("==============================================");

  if (!firebaseInitialized) {
    console.warn("⚠️ Firebase non initialisé - Rappels non envoyés");
    return;
  }

  try {
    const User = require("../models/User");

    // Get all active users
    const users = await User.findAll({
      where: {
        status: "ACTIVE",
        is_email_verified: true,
      },
      attributes: ["id"],
    });

    console.log(`Utilisateurs à notifier: ${users.length}`);

    const reminders = [
      "Comment te sens-tu aujourd'hui ? Prends un moment pour noter ton humeur. 🌟",
      "N'oublie pas de faire une pause bien-être ! Tu mérites de prendre soin de toi. 💚",
      "As-tu pris le temps de respirer aujourd'hui ? Une petite pause peut faire du bien. 🌿",
      "Ta santé mentale compte. Viens partager ou lire des témoignages inspirants. 💫",
    ];

    const randomReminder =
      reminders[Math.floor(Math.random() * reminders.length)];

    let sent = 0;
    for (const user of users) {
      const result = await sendToUser(
        user.id,
        {
          title: "🌿 Rappel Sakinah",
          body: randomReminder,
        },
        { type: "DAILY_REMINDER" },
      );
      if (result.success) sent++;
    }

    console.log(`✅ Rappels envoyés: ${sent}/${users.length}`);
    console.log("==============================================\n");
  } catch (error) {
    console.error("❌ Erreur envoi rappels:", error.message);
  }
}

/**
 * Démarrer le cron job pour les rappels quotidiens
 * Planifié à 9h00 heure de Paris, tous les jours
 */
function startDailyReminderCron() {
  cron.schedule("0 9 * * *", () => {
    console.log(`[${new Date().toISOString()}] Cron: lancement rappel quotidien`);
    sendDailyReminder();
  }, {
    timezone: "Europe/Paris",
  });

  console.log("✅ Cron job rappel quotidien planifié (tous les jours à 9h00 Paris)");
}

async function notifyAdminCriticalContent(testimonialId, authorPseudo) {
  try {
    const admins = await User.findAll({ where: { role: "ADMIN", status: "ACTIVE" } });
    const adminIds = admins.map((a) => a.id);
    if (adminIds.length === 0) return;
    return sendToUsers(
      adminIds,
      {
        title: "🚨 Contenu critique détecté",
        body: `Un témoignage de ${authorPseudo || "un utilisateur"} contient des mots-clés de détresse. Intervention requise.`,
      },
      { type: "CRITICAL_CONTENT", testimonial_id: testimonialId },
    );
  } catch (e) {
    console.error("notifyAdminCriticalContent error:", e);
  }
}

module.exports = {
  sendToUser,
  sendToUsers,
  notifyTestimonialApproved,
  notifyTestimonialRejected,
  notifyTestimonialLiked,
  notifyTestimonialCommented,
  notifyCommentApproved,
  notifyCommentRejected,
  notifyAdminNewTestimonial,
  notifyAdminCriticalContent,
  sendDailyReminder,
  startDailyReminderCron,
};
