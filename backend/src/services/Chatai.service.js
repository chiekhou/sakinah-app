const axios = require("axios");

class ChatAIService {
  constructor() {
    this.apiKey = process.env.AI_API_KEY;
    this.apiUrl =
      process.env.AI_API_URL || "https://api.anthropic.com/v1/messages";
    this.model = "claude-sonnet-4-20250514";

    // Configuration retry
    this.maxRetries = 3;
    this.retryDelay = 1000; // 1 seconde

    // Mots-clés sensibles nécessitant une escalade
    this.emergencyKeywords = [
      "suicide",
      "me tuer",
      "mettre fin",
      "mourir",
      "disparaître",
      "violence",
      "abus",
      "maltraitance",
      "danger",
    ];

    // Messages d'erreur personnalisés
    this.errorMessages = {
      rate_limit: {
        response: "Je reçois beaucoup de messages en ce moment. 😊\n\nPeux-tu réessayer dans quelques secondes ? En attendant, tu peux explorer les articles ou les quiz de l'application.",
        retryable: true,
      },
      quota_exceeded: {
        response: "Je suis temporairement indisponible. 😔\n\nMais tu peux toujours :\n• Explorer les articles et quiz\n• Faire un exercice de respiration\n• Contacter le **3114** si tu as besoin de parler à quelqu'un immédiatement.",
        retryable: false,
      },
      network_error: {
        response: "Il semble y avoir un problème de connexion. 📶\n\nVérifie ta connexion internet et réessaie. Si le problème persiste, les contenus hors-ligne de l'app sont toujours disponibles.",
        retryable: true,
      },
      invalid_api_key: {
        response: "Je rencontre un problème de configuration. 🔧\n\nL'équipe technique a été notifiée. En attendant, n'hésite pas à explorer les autres fonctionnalités de l'application.",
        retryable: false,
      },
      default: {
        response: "Je suis désolé, je rencontre une difficulté technique. 😔\n\nEn attendant, n'hésite pas à explorer les contenus de l'application ou, si tu as besoin d'aide immédiate, à contacter le 3114.",
        retryable: false,
      },
    };
  }

  /**
   * Identifie le type d'erreur à partir de la réponse API
   */
  getErrorType(error) {
    const status = error.response?.status;
    const errorCode = error.response?.data?.error?.type;

    // Erreur réseau (pas de réponse)
    if (!error.response) {
      return "network_error";
    }

    // Rate limit (429)
    if (status === 429) {
      return "rate_limit";
    }

    // Authentification invalide (401)
    if (status === 401) {
      return "invalid_api_key";
    }

    // Quota épuisé (400 avec message spécifique ou 402)
    if (status === 402 || (status === 400 && errorCode === "insufficient_quota")) {
      return "quota_exceeded";
    }

    return "default";
  }

  /**
   * Log structuré pour le monitoring
   */
  logError(errorType, error, context = {}) {
    const logEntry = {
      timestamp: new Date().toISOString(),
      service: "ChatAI",
      errorType,
      statusCode: error.response?.status || null,
      errorMessage: error.response?.data?.error?.message || error.message,
      context,
    };

    // En production, ceci pourrait être envoyé à un service de monitoring
    console.error("[ChatAI Error]", JSON.stringify(logEntry, null, 2));

    return logEntry;
  }

  /**
   * Attend un délai avec backoff exponentiel
   */
  async wait(attempt) {
    const delay = this.retryDelay * Math.pow(2, attempt);
    return new Promise((resolve) => setTimeout(resolve, delay));
  }

  /**
   * Détecte si le message contient des mots-clés d'urgence
   */
  detectEmergency(message) {
    const lowerMessage = message.toLowerCase();
    return this.emergencyKeywords.some((keyword) =>
      lowerMessage.includes(keyword)
    );
  }

  /**
   * Construit le prompt système pour l'IA
   */
  buildSystemPrompt(userMood) {
    const moodContext = userMood
      ? `L'utilisateur a indiqué un niveau d'humeur de ${userMood}/7. `
      : "";

    return `Tu es un assistant bienveillant d'une application de bien-être mental pour jeunes de 6 à 25 ans.

${moodContext}

DIRECTIVES IMPORTANTES:
- Utilise un ton chaleureux, positif et encourageant
- Adapte ton langage à l'âge de l'utilisateur (simple pour 6-12 ans, plus mature pour 18-25 ans)
- Ne donne JAMAIS de diagnostic médical
- Rappelle que tu n'es pas un professionnel de santé, mais un compagnon de soutien
- Oriente vers des ressources concrètes (exercices de respiration, articles de l'app)
- Si tu détectes une urgence (suicide, violence), oriente IMMÉDIATEMENT vers les numéros d'urgence:
  * 3114 (Prévention du suicide - France)
  * 119 (Enfance en danger)
  * 3020 (Non au harcèlement)
- Pose des questions ouvertes pour encourager l'expression
- Valide les émotions de l'utilisateur
- Reste concis (2-4 phrases maximum par réponse)`;
  }

  /**
   * Effectue l'appel API avec retry automatique
   */
  async callAPIWithRetry(messages, userMood, attempt = 0) {
    try {
      const response = await axios.post(
        this.apiUrl,
        {
          model: this.model,
          max_tokens: 500,
          system: this.buildSystemPrompt(userMood),
          messages: messages,
        },
        {
          headers: {
            "Content-Type": "application/json",
            "x-api-key": this.apiKey,
            "anthropic-version": "2023-06-01",
          },
          timeout: 30000, // 30 secondes timeout
        }
      );

      return { success: true, data: response.data };
    } catch (error) {
      const errorType = this.getErrorType(error);
      const errorConfig = this.errorMessages[errorType];

      // Log l'erreur
      this.logError(errorType, error, { attempt, maxRetries: this.maxRetries });

      // Retry si l'erreur est retryable et qu'on n'a pas atteint le max
      if (errorConfig.retryable && attempt < this.maxRetries) {
        console.log(`[ChatAI] Retry ${attempt + 1}/${this.maxRetries} après erreur ${errorType}`);
        await this.wait(attempt);
        return this.callAPIWithRetry(messages, userMood, attempt + 1);
      }

      return { success: false, errorType, error };
    }
  }

  /**
   * Génère une réponse de l'IA
   */
  async generateResponse(
    userMessage,
    conversationHistory = [],
    userMood = null
  ) {
    // Vérification d'urgence (priorité absolue)
    if (this.detectEmergency(userMessage)) {
      return {
        response: `Je comprends que tu traverses un moment très difficile. 🫂\n\nIl est vraiment important que tu parles à quelqu'un qui peut t'aider immédiatement:\n\n📞 **3114** - Prévention du suicide (gratuit, anonyme, 24h/7j)\n📞 **119** - Enfance en danger\n📞 **3020** - Non au harcèlement\n\nTu n'es pas seul(e), et ces personnes sont là pour t'écouter et t'accompagner. 💙`,
        isEmergency: true,
      };
    }

    // Construction des messages pour l'API
    const messages = [
      ...conversationHistory.map((msg) => ({
        role: msg.role,
        content: msg.content,
      })),
      {
        role: "user",
        content: userMessage,
      },
    ];

    // Appel API avec retry automatique
    const result = await this.callAPIWithRetry(messages, userMood);

    if (result.success) {
      const aiResponse = result.data.content[0].text;
      return {
        response: aiResponse,
        isEmergency: false,
      };
    }

    // Gestion de l'erreur avec message personnalisé
    const errorConfig = this.errorMessages[result.errorType] || this.errorMessages.default;

    return {
      response: errorConfig.response,
      isEmergency: false,
      error: true,
      errorType: result.errorType,
    };
  }

  /**
   * Génère des suggestions de sujets de conversation
   */
  getSuggestions(userMood) {
    const allSuggestions = {
      low: [
        "J'aimerais parler de ce qui me tracasse",
        "Comment gérer une situation difficile ?",
        "J'ai besoin d'être rassuré(e)",
        "Propose-moi un exercice de relaxation",
      ],
      medium: [
        "Comment améliorer ma confiance en moi ?",
        "Parle-moi de la gestion du stress",
        "Comment faire face au harcèlement ?",
        "Conseils pour mieux dormir",
      ],
      high: [
        "Comment maintenir mon bien-être ?",
        "Partage-moi des conseils positifs",
        "Comment aider un ami qui va mal ?",
        "Quels sont les bienfaits de la gratitude ?",
      ],
    };

    if (userMood <= 3) return allSuggestions.low;
    if (userMood <= 5) return allSuggestions.medium;
    return allSuggestions.high;
  }
}

module.exports = new ChatAIService();
