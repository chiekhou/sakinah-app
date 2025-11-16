const axios = require("axios");

class ChatAIService {
  constructor() {
    this.apiKey = process.env.AI_API_KEY;
    this.apiUrl =
      process.env.AI_API_URL || "https://api.anthropic.com/v1/messages";
    this.model = "claude-sonnet-4-20250514";

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
   * Génère une réponse de l'IA
   */
  async generateResponse(
    userMessage,
    conversationHistory = [],
    userMood = null
  ) {
    try {
      // Vérification d'urgence
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

      // Appel à l'API Anthropic
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
        }
      );

      const aiResponse = response.data.content[0].text;

      return {
        response: aiResponse,
        isEmergency: false,
      };
    } catch (error) {
      console.error("Erreur ChatAI:", error.response?.data || error.message);

      // Réponse de secours en cas d'erreur API
      return {
        response:
          "Je suis désolé, je rencontre une difficulté technique. 😔\n\nEn attendant, n'hésite pas à explorer les contenus de l'application ou, si tu as besoin d'aide immédiate, à contacter le 3114. Tu peux aussi réessayer dans quelques instants.",
        isEmergency: false,
        error: true,
      };
    }
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
