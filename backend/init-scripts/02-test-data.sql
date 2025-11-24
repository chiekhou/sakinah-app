-- Script pour insérer des données de test

-- QUIZ DE TEST
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Comprendre le stress',
  'Teste tes connaissances sur le stress et comment le gérer au quotidien',
  'stress',
  'facile',
  5,
  ARRAY[1,2,3,4],
  '[
    {
      "question": "Qu''est-ce que le stress?",
      "answers": [
        "Une réaction naturelle du corps",
        "Une maladie grave",
        "Un signe de faiblesse",
        "Quelque chose à éviter totalement"
      ],
      "correct_answer": 0,
      "explanation": "Le stress est une réaction naturelle et normale du corps face à une situation perçue comme difficile ou menaçante."
    },
    {
      "question": "Quelle technique peut aider à réduire le stress?",
      "answers": [
        "Ignorer ses émotions",
        "La respiration profonde",
        "Manger beaucoup de sucre",
        "Ne jamais se reposer"
      ],
      "correct_answer": 1,
      "explanation": "La respiration profonde active le système nerveux parasympathique et aide à calmer le corps et l''esprit."
    },
    {
      "question": "Combien de temps par jour est recommandé pour l''activité physique?",
      "answers": [
        "5 minutes",
        "15 minutes",
        "30 minutes",
        "3 heures"
      ],
      "correct_answer": 2,
      "explanation": "30 minutes d''activité physique par jour est recommandé pour maintenir une bonne santé physique et mentale."
    }
  ]'::jsonb
),
(
  uuid_generate_v4(),
  'Estime de soi : te connais-tu bien?',
  'Découvre comment améliorer ton estime de toi-même',
  'estime',
  'moyen',
  5,
  ARRAY[3,4,5],
  '[
    {
      "question": "L''estime de soi, c''est:",
      "answers": [
        "Se croire meilleur que les autres",
        "S''aimer et se respecter soi-même",
        "Ne jamais admettre ses erreurs",
        "Être parfait en tout"
      ],
      "correct_answer": 1,
      "explanation": "L''estime de soi est la valeur que tu t''accordes et le respect que tu as pour toi-même, avec tes qualités ET tes défauts."
    },
    {
      "question": "Quand on fait une erreur, il est important de:",
      "answers": [
        "Se critiquer sévèrement",
        "Abandonner complètement",
        "Apprendre et continuer",
        "Prétendre que ça n''est pas arrivé"
      ],
      "correct_answer": 2,
      "explanation": "Les erreurs font partie de l''apprentissage. Il est important d''en tirer des leçons et de continuer à avancer."
    },
    {
      "question": "Pour améliorer ton estime de toi, tu peux:",
      "answers": [
        "Te comparer constamment aux autres",
        "Reconnaître tes réussites",
        "Ignorer tes émotions",
        "Être dur avec toi-même"
      ],
      "correct_answer": 1,
      "explanation": "Reconnaître et célébrer tes réussites, même les petites, aide à construire une estime de soi positive."
    }
  ]'::jsonb
),
(
  uuid_generate_v4(),
  'Reconnaître le harcèlement',
  'Apprends à identifier les différentes formes de harcèlement',
  'harcelement',
  'moyen',
  7,
  ARRAY[1,2,3],
  '[
    {
      "question": "Le harcèlement, c''est:",
      "answers": [
        "Une simple plaisanterie",
        "Des comportements répétés pour faire du mal",
        "Normal entre amis",
        "Pas grave si c''est sur Internet"
      ],
      "correct_answer": 1,
      "explanation": "Le harcèlement se caractérise par des comportements répétés et intentionnels visant à faire du mal à quelqu''un."
    },
    {
      "question": "Si tu es témoin de harcèlement, tu dois:",
      "answers": [
        "Rire avec les autres",
        "Ne rien faire pour éviter les problèmes",
        "En parler à un adulte de confiance",
        "Participer aussi"
      ],
      "correct_answer": 2,
      "explanation": "Être témoin d''une situation de harcèlement n''est pas facile, mais en parler à un adulte de confiance est la meilleure chose à faire."
    },
    {
      "question": "Le cyberharcèlement, c''est:",
      "answers": [
        "Moins grave que le harcèlement en personne",
        "Du harcèlement via Internet et les réseaux sociaux",
        "Impossible à arrêter",
        "Amusant pour tout le monde"
      ],
      "correct_answer": 1,
      "explanation": "Le cyberharcèlement utilise les technologies numériques et peut avoir des conséquences tout aussi graves que le harcèlement en personne."
    }
  ]'::jsonb
);

-- ARTICLES DE TEST
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  '5 techniques de respiration anti-stress',
  E'# 5 techniques de respiration anti-stress\n\n## 1. La respiration 4-7-8\n\nInspire par le nez pendant 4 secondes, retiens ta respiration 7 secondes, puis expire lentement par la bouche pendant 8 secondes.\n\n## 2. La respiration abdominale\n\nPose une main sur ton ventre. Inspire profondément en gonflant ton ventre (pas ta poitrine). Expire lentement.\n\n## 3. La respiration carrée\n\nInspire 4 secondes, retiens 4 secondes, expire 4 secondes, attends 4 secondes. Répète.\n\n## 4. La respiration alternée\n\nBouche une narine, inspire par l''autre. Alterne à chaque respiration.\n\n## 5. La respiration de la vague\n\nImagine une vague qui monte (inspiration) et descend (expiration) doucement.\n\n## Quand utiliser ces techniques?\n\n- Avant un examen\n- Quand tu te sens anxieux\n- Avant de dormir\n- Pendant une dispute\n\nCes techniques sont simples et peuvent se faire n''importe où, n''importe quand !',
  'Découvre 5 techniques de respiration simples et efficaces pour gérer ton stress au quotidien.',
  'stress',
  ARRAY[1,2,3,4],
  3,
  true
),
(
  uuid_generate_v4(),
  'Comment améliorer son estime de soi?',
  E'# Comment améliorer son estime de soi?\n\nL''estime de soi se construit jour après jour. Voici quelques conseils pratiques:\n\n## Accepte-toi tel que tu es\n\nPersonne n''est parfait ! Tes "défauts" font partie de toi et c''est OK.\n\n## Célèbre tes réussites\n\nMême les petites ! Tu as réussi un contrôle ? Tu as aidé quelqu''un ? Félicite-toi !\n\n## Arrête de te comparer\n\nChacun a son propre chemin. Les réseaux sociaux ne montrent qu''une partie de la réalité.\n\n## Entoure-toi bien\n\nPasse du temps avec des personnes qui te valorisent et te respectent.\n\n## Prends soin de toi\n\nDors bien, mange équilibré, fais du sport. Ton corps te dira merci !\n\n## Fixe-toi des objectifs réalistes\n\nDes petits objectifs atteignables qui te permettront d''avancer pas à pas.\n\n## Parle-toi gentiment\n\nSois ton meilleur ami, pas ton pire ennemi. Utilise des mots bienveillants envers toi-même.\n\nRappelle-toi : l''estime de soi se travaille, c''est normal d''avoir des hauts et des bas !',
  'Des conseils concrets et bienveillants pour construire une estime de soi solide.',
  'estime',
  ARRAY[2,3,4,5],
  4,
  true
),
(
  uuid_generate_v4(),
  'Que faire si tu es victime de harcèlement?',
  E'# Que faire si tu es victime de harcèlement?\n\n## 1. Ce n''est PAS de ta faute\n\nAucune victime de harcèlement n''est responsable. Le harceleur est le seul fautif.\n\n## 2. N''reste pas seul(e)\n\nParle-en ! Plus tu gardes ça pour toi, plus c''est difficile.\n\n## 3. À qui en parler?\n\n- Tes parents ou un adulte de confiance\n- Un professeur ou le CPE\n- L''infirmière scolaire\n- Un psychologue\n- Le 3020 (numéro vert contre le harcèlement)\n\n## 4. Garde des preuves\n\nSi c''est du cyberharcèlement : screenshots, messages, etc.\n\n## 5. Bloque et signale\n\nSur les réseaux sociaux, bloque les harceleurs et signale leur comportement.\n\n## 6. Ne réponds pas\n\nNe rentre pas dans leur jeu. Ça les encourage.\n\n## 7. Entoure-toi de personnes bienveillantes\n\nTu mérites d''être respecté(e) et aimé(e).\n\n## Numéros utiles:\n\n- 3020 : Non au harcèlement\n- 3018 : Net Écoute (cyberharcèlement)\n- 119 : Enfance en danger\n\nTu n''es pas seul(e), il y a des gens prêts à t''aider !',
  'Guide pratique pour savoir comment réagir face au harcèlement.',
  'harcelement',
  ARRAY[1,2,3],
  5,
  false
);

-- SCENARIOS DE TEST
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Face au harcèlement scolaire',
  'Tu vois ton ami se faire harceler dans la cour. Comment réagis-tu?',
  'harcelement',
  10,
  ARRAY[2,3,4],
  '{
    "start": {
      "text": "Tu es dans la cour de récréation. Tu vois un groupe d''élèves qui embête ton ami : ils se moquent de ses vêtements et le poussent. Que fais-tu?",
      "choices": [
        {
          "text": "Tu interviens directement pour défendre ton ami",
          "next": "intervene_direct"
        },
        {
          "text": "Tu vas chercher un surveillant ou un adulte",
          "next": "get_adult"
        },
        {
          "text": "Tu rejoins ton ami pour lui montrer ton soutien",
          "next": "support_friend"
        },
        {
          "text": "Tu ne fais rien car tu as peur",
          "next": "do_nothing"
        }
      ]
    },
    "intervene_direct": {
      "text": "Tu t''approches du groupe et tu leur dis d''arrêter. Ils se retournent vers toi...",
      "feedback": "C''est courageux ! Mais attention, intervenir seul peut être risqué. Voici ce qui aurait pu se passer:",
      "consequences": "Parfois, les harceleurs peuvent se retourner contre toi. Il est souvent plus sûr d''aller chercher un adulte.",
      "best_practice": "✅ Mieux vaut: Aller chercher un adulte qui pourra gérer la situation en toute sécurité.",
      "choices": []
    },
    "get_adult": {
      "text": "Tu pars rapidement chercher un surveillant. Tu lui expliques la situation et il te suit dans la cour.",
      "feedback": "Excellent choix ! 🌟",
      "consequences": "Le surveillant intervient et met fin au harcèlement. Il prend le temps de discuter avec chacun et signale l''incident.",
      "best_practice": "✅ Tu as fait le bon choix ! Alerter un adulte est la meilleure façon d''aider ton ami en toute sécurité.",
      "next_action": "Plus tard, tu vas voir ton ami pour lui parler et le soutenir.",
      "choices": []
    },
    "support_friend": {
      "text": "Tu rejoins ton ami et tu lui dis \"Je suis là\". Les harceleurs vous regardent tous les deux.",
      "feedback": "Montrer ton soutien c''est important ! 💙",
      "consequences": "Le groupe finit par partir. Ton ami te remercie mais il est encore triste. Vous allez ensemble voir un adulte.",
      "best_practice": "✅ Bon choix ! Soutenir son ami + alerter un adulte = combinaison parfaite.",
      "choices": []
    },
    "do_nothing": {
      "text": "Tu t''éloignes, mal à l''aise. Plus tard, tu regrettes...",
      "feedback": "C''est normal d''avoir peur, mais ton ami a besoin d''aide.",
      "consequences": "Le harcèlement continue. Ton ami se sent seul et la situation empire.",
      "best_practice": "💡 Ce que tu peux faire: Même si tu as peur d''intervenir, tu peux toujours aller discrètement prévenir un adulte. C''est déjà beaucoup !",
      "second_chance": "Tu décides de te racheter et d''aller en parler à un adulte de confiance.",
      "choices": []
    }
  }'::jsonb
),
(
  uuid_generate_v4(),
  'Gérer le stress avant un examen',
  'Demain, tu as un examen important. Comment te prépares-tu?',
  'stress',
  8,
  ARRAY[2,3,4,5],
  '{
    "start": {
      "text": "C''est la veille d''un examen important. Tu commences à stresser. Que fais-tu?",
      "choices": [
        {
          "text": "Tu révises toute la nuit",
          "next": "all_night"
        },
        {
          "text": "Tu révises un peu puis tu te détends",
          "next": "balanced"
        },
        {
          "text": "Tu paniques et tu ne fais rien",
          "next": "panic"
        },
        {
          "text": "Tu pratiques des exercices de respiration",
          "next": "breathing"
        }
      ]
    },
    "all_night": {
      "text": "Tu révises jusqu''à 3h du matin. Le lendemain, tu es épuisé...",
      "feedback": "Le manque de sommeil nuit à tes performances ! 😴",
      "consequences": "Pendant l''examen, tu as du mal à te concentrer et à te souvenir de ce que tu as révisé.",
      "best_practice": "💡 Mieux vaut: Réviser raisonnablement et dormir au moins 8h. Ton cerveau a besoin de repos pour bien fonctionner !",
      "choices": []
    },
    "balanced": {
      "text": "Tu révises 2 heures, puis tu fais une activité relaxante. Tu te couches à une heure raisonnable.",
      "feedback": "Excellent ! C''est l''approche idéale ! 🌟",
      "consequences": "Le lendemain, tu es reposé et concentré. Tu te sens confiant et l''examen se passe bien.",
      "best_practice": "✅ Tu as trouvé le bon équilibre entre révisions et repos !",
      "choices": []
    },
    "panic": {
      "text": "Tu es tellement stressé que tu bloques complètement. Tu passes la soirée à angoisser sans réviser.",
      "feedback": "Le stress t''a paralysé. Ça arrive, mais tu peux apprendre à le gérer ! 💙",
      "consequences": "Le lendemain, tu te sens mal préparé et encore plus stressé.",
      "best_practice": "💡 Astuce: Quand tu sens le stress monter, fais une pause. Respire, marche, parle à quelqu''un. Puis reprends doucement.",
      "choices": []
    },
    "breathing": {
      "text": "Tu pratiques la technique de respiration 4-7-8 pendant 10 minutes. Tu te sens plus calme.",
      "feedback": "Super ! La respiration est un outil puissant contre le stress ! 🧘",
      "consequences": "Tu es plus détendu. Tu arrives à réviser sereinement puis à bien dormir.",
      "best_practice": "✅ Les exercices de respiration aident vraiment ! Continue à les utiliser quand tu en as besoin.",
      "next_step": "Le lendemain, tu refais un exercice de respiration avant d''entrer dans la salle d''examen.",
      "choices": []
    }
  }'::jsonb
);

-- Message de confirmation
SELECT 'Données de test insérées avec succès !' AS message;

SELECT 'Quiz créés: ' || COUNT(*) FROM quizzes;

SELECT 'Articles créés: ' || COUNT(*) FROM articles;

SELECT 'Scénarios créés: ' || COUNT(*) FROM scenarios;