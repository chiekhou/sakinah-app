/**
 * Service de détection de contenu en crise
 * Utilisé pour identifier les témoignages nécessitant une intervention urgente
 */

const CRISIS_KEYWORDS = [
  // Suicide / mort
  "suicide", "suicidaire", "suicider", "me suicider", "se suicider",
  "envie de mourir", "veux mourir", "plus envie de vivre", "mourir",
  "me tuer", "se tuer", "en finir", "m'en finir", "mettre fin",
  "fin de ma vie", "plus la peine de vivre", "ça sert à rien de vivre",
  // Automutilation
  "automutilation", "me couper", "me blesser", "me faire du mal",
  "me faire souffrir", "me mutiler",
  // Abus / violence
  "violé", "violée", "viol", "agression sexuelle", "maltraitance",
  "abus sexuel", "touché", "il m'a touché", "elle m'a touchée",
  "violence", "frappé", "frappée",
  // Détresse extrême
  "disparaître", "plus là", "personne ne m'aime",
  "je suis un fardeau", "sans moi", "mieux sans moi",
];

/**
 * Détecte si un texte contient des mots-clés de crise
 * @param {string} text
 * @returns {boolean}
 */
function detectCrisis(text) {
  const lower = text.toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "");
  return CRISIS_KEYWORDS.some((keyword) => {
    const normalizedKeyword = keyword.toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "");
    return lower.includes(normalizedKeyword);
  });
}

/**
 * Retourne les mots-clés détectés dans un texte
 * @param {string} text
 * @returns {string[]}
 */
function getMatchedKeywords(text) {
  const lower = text.toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "");
  return CRISIS_KEYWORDS.filter((keyword) => {
    const normalizedKeyword = keyword.toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "");
    return lower.includes(normalizedKeyword);
  });
}

module.exports = { detectCrisis, getMatchedKeywords, CRISIS_KEYWORDS };
