class EmergencyController {
  /**
   * Obtenir les ressources d'urgence
   * GET /api/emergency/resources
   */
  async getResources(req, res) {
    try {
      const resources = {
        france: {
          hotlines: [
            {
              name: "3114",
              description: "Numéro national de prévention du suicide",
              phone: "3114",
              availability: "24h/24, 7j/7",
              type: "suicide_prevention",
              is_free: true,
              is_anonymous: true,
            },
            {
              name: "119 - Allô Enfance en Danger",
              description:
                "Service national d'accueil téléphonique pour l'enfance en danger",
              phone: "119",
              availability: "24h/24, 7j/7",
              type: "child_abuse",
              is_free: true,
              is_anonymous: true,
            },
            {
              name: "3020 - Non au Harcèlement",
              description: "Numéro vert contre le harcèlement scolaire",
              phone: "3020",
              availability:
                "Du lundi au vendredi de 9h à 20h, samedi de 9h à 18h (hors jours fériés)",
              type: "bullying",
              is_free: true,
              is_anonymous: true,
            },
            {
              name: "3018 - Net Écoute",
              description:
                "Numéro national pour les victimes de cyberharcèlement",
              phone: "3018",
              availability: "Du lundi au samedi de 9h à 20h",
              type: "cyberbullying",
              is_free: true,
              is_anonymous: true,
            },
            {
              name: "Fil Santé Jeunes",
              description: "Service d'aide et d'écoute pour les jeunes",
              phone: "0 800 235 236",
              availability: "24h/24, 7j/7",
              type: "youth_support",
              is_free: true,
              is_anonymous: true,
              website: "https://www.filsantejeunes.com",
            },
            {
              name: "SOS Amitié",
              description: "Service d'écoute pour toute personne en détresse",
              phone: "09 72 39 40 50",
              availability: "24h/24, 7j/7",
              type: "general_support",
              is_free: false,
              is_anonymous: true,
              website: "https://www.sos-amitie.com",
            },
          ],
          emergency_services: [
            {
              name: "SAMU",
              phone: "15",
              description: "Urgence médicale",
              type: "medical",
            },
            {
              name: "Police Secours",
              phone: "17",
              description: "Urgence police",
              type: "police",
            },
            {
              name: "Pompiers",
              phone: "18",
              description: "Urgence incendie et secours",
              type: "fire",
            },
            {
              name: "Numéro d'urgence européen",
              phone: "112",
              description: "Toutes urgences",
              type: "general",
            },
          ],
          online_resources: [
            {
              name: "Fil Santé Jeunes - Chat",
              url: "https://www.filsantejeunes.com/tchat-individuel",
              description: "Chat en ligne avec un professionnel",
              type: "chat",
              availability: "Du lundi au dimanche de 9h à 22h",
            },
            {
              name: "Nightline France",
              url: "https://www.nightline.fr",
              description:
                "Service d'écoute nocturne par et pour les étudiants",
              type: "chat",
              availability: "De 21h à 2h30 du matin",
            },
            {
              name: "e-Enfance",
              url: "https://www.e-enfance.org",
              description: "Protection des enfants sur Internet",
              type: "website",
            },
          ],
        },
        international: {
          note: "Pour les utilisateurs hors de France, consultez les ressources locales de votre pays.",
          resources: [
            {
              name: "Befrienders Worldwide",
              url: "https://www.befrienders.org",
              description:
                "Annuaire international de lignes d'écoute pour la prévention du suicide",
            },
            {
              name: "International Association for Suicide Prevention",
              url: "https://www.iasp.info/resources/Crisis_Centres",
              description: "Liste des centres de crise dans le monde",
            },
          ],
        },
      };

      res.json(resources);
    } catch (error) {
      console.error("Erreur getResources:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération des ressources" });
    }
  }

  /**
   * Obtenir des conseils en cas de crise
   * GET /api/emergency/advice
   */
  async getAdvice(req, res) {
    try {
      const advice = {
        immediate_danger: {
          title: "⚠️ En cas de danger immédiat",
          actions: [
            "Appelle le 15 (SAMU) ou le 112 immédiatement",
            "Si tu es en danger, mets-toi en sécurité",
            "Demande de l'aide à une personne de confiance proche de toi",
          ],
        },
        suicidal_thoughts: {
          title: "💙 Si tu as des pensées suicidaires",
          actions: [
            "Tu n'es pas seul(e). Ces pensées sont temporaires.",
            "Appelle le 3114 (numéro national de prévention du suicide) - 24h/24, gratuit et anonyme",
            "Parle à un adulte de confiance (parent, prof, médecin)",
            "Va aux urgences de l'hôpital le plus proche si tu te sens en danger",
          ],
          important:
            "Ces pensées ne te définissent pas. Il existe toujours une autre solution, même si tu ne la vois pas maintenant.",
        },
        crisis_management: {
          title: "🆘 Gérer une crise",
          techniques: [
            {
              name: "Respiration 5-5-5",
              description:
                "Inspire pendant 5 secondes, retiens ta respiration 5 secondes, expire pendant 5 secondes. Répète 5 fois.",
            },
            {
              name: "Ancrage sensoriel",
              description:
                "Identifie 5 choses que tu vois, 4 que tu touches, 3 que tu entends, 2 que tu sens, 1 que tu goûtes.",
            },
            {
              name: "Eau froide",
              description:
                "Passe tes mains ou ton visage sous l'eau froide pour calmer ton système nerveux.",
            },
            {
              name: "Appeler quelqu'un",
              description:
                "Parler à quelqu'un, même de choses banales, peut aider.",
            },
          ],
        },
        when_to_seek_help: {
          title: "🚨 Quand chercher de l'aide",
          signs: [
            "Tu penses à te faire du mal",
            "Tu ne peux plus faire tes activités quotidiennes",
            "Tu te sens désespéré(e) sans voir d'issue",
            "Tu consommes des substances pour gérer tes émotions",
            "Tu as des changements importants dans ton sommeil ou ton appétit",
            "Tu t'isoles complètement de tes proches",
          ],
          message:
            "Ces signes montrent que tu as besoin d'aide professionnelle. Ce n'est pas un échec, c'est du courage.",
        },
      };

      res.json(advice);
    } catch (error) {
      console.error("Erreur getAdvice:", error);
      res
        .status(500)
        .json({ error: "Erreur lors de la récupération des conseils" });
    }
  }
}

module.exports = new EmergencyController();
