-- Script pour insérer du contenu additionnel basé sur des situations réelles
-- Scénarios, Quiz et Articles sur le harcèlement, l'estime de soi, le post-partum, etc.

-- =====================================================
-- SCENARIOS ADDITIONNELS (20 scénarios)
-- =====================================================

-- Scénario 1: Harcèlement sur le poids
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Les surnoms blessants',
  'Une élève reçoit des surnoms méchants à cause de son poids. Comment réagir?',
  'harcelement',
  10,
  ARRAY[1,2,3],
  '{
    "start": {
      "text": "Tu remarques qu''une élève de ta classe, Léa, est appelée par des surnoms blessants comme \"La Boule\" à cause de son poids. Les autres refusent de s''asseoir à côté d''elle. Que fais-tu?",
      "choices": [
        {"text": "Tu vas t''asseoir à côté d''elle pour lui montrer ton soutien", "next": "sit_with_her"},
        {"text": "Tu en parles à un professeur", "next": "tell_teacher"},
        {"text": "Tu confrontes ceux qui se moquent", "next": "confront"},
        {"text": "Tu ne fais rien par peur d''être ciblé aussi", "next": "do_nothing"}
      ]
    },
    "sit_with_her": {
      "text": "Tu vas t''asseoir à côté de Léa. Elle te regarde, surprise mais soulagée.",
      "feedback": "Beau geste de solidarité ! 💙",
      "consequences": "D''autres élèves voient ton exemple et certains commencent à changer d''attitude.",
      "best_practice": "✅ Montrer son soutien est puissant. Continue aussi à en parler à un adulte.",
      "choices": []
    },
    "tell_teacher": {
      "text": "Tu vas voir ton professeur principal et lui expliques la situation.",
      "feedback": "Excellent choix ! 🌟",
      "consequences": "Le professeur organise une discussion en classe sur le respect et surveille la situation.",
      "best_practice": "✅ Alerter un adulte est la meilleure façon d''aider durablement.",
      "choices": []
    },
    "confront": {
      "text": "Tu dis aux moqueurs d''arrêter. Ils se retournent vers toi...",
      "feedback": "C''est courageux mais risqué.",
      "consequences": "Ils peuvent se calmer ou te prendre pour cible aussi.",
      "best_practice": "💡 Il vaut mieux prévenir un adulte qui a l''autorité pour agir.",
      "choices": []
    },
    "do_nothing": {
      "text": "Tu ne fais rien. Léa s''isole de plus en plus...",
      "feedback": "C''est normal d''avoir peur, mais ton silence peut aggraver sa souffrance.",
      "consequences": "Léa finit par ne plus venir en cours.",
      "best_practice": "💡 Tu peux toujours agir discrètement en parlant à un adulte.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario 2: Moqueries en EPS
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Les moqueries en sport',
  'Un élève se fait moquer pendant le cours d''EPS. Comment l''aider?',
  'harcelement',
  8,
  ARRAY[2,3,4],
  '{
    "start": {
      "text": "Pendant le cours d''EPS, un élève essaie de faire une roulade. Toute la classe éclate de rire et certains filment avec leur téléphone. L''élève est au bord des larmes. Que fais-tu?",
      "choices": [
        {"text": "Tu demandes aux autres d''arrêter de filmer", "next": "stop_filming"},
        {"text": "Tu vas voir l''élève pour le réconforter", "next": "comfort"},
        {"text": "Tu préviens le prof d''EPS", "next": "tell_teacher"},
        {"text": "Tu ris avec les autres pour ne pas être exclu", "next": "laugh"}
      ]
    },
    "stop_filming": {
      "text": "Tu demandes fermement aux autres de ranger leurs téléphones. Certains obéissent.",
      "feedback": "C''est courageux ! 👏",
      "consequences": "Tu empêches la vidéo de se répandre sur les réseaux.",
      "best_practice": "✅ Bon réflexe ! Préviens aussi un adulte pour que les téléphones soient confisqués.",
      "choices": []
    },
    "comfort": {
      "text": "Tu vas vers l''élève et tu lui dis que c''est pas grave, que ça arrive à tout le monde.",
      "feedback": "Ta gentillesse compte beaucoup ! 💙",
      "consequences": "L''élève se sent moins seul face aux moqueries.",
      "best_practice": "✅ Le soutien d''un camarade peut faire toute la différence.",
      "choices": []
    },
    "tell_teacher": {
      "text": "Tu préviens le prof qui intervient immédiatement et confisque les téléphones.",
      "feedback": "Excellent choix ! 🌟",
      "consequences": "Le prof rappelle les règles et les vidéos sont supprimées.",
      "best_practice": "✅ Un adulte peut agir avec autorité pour protéger l''élève.",
      "choices": []
    },
    "laugh": {
      "text": "Tu ris avec les autres pour te fondre dans le groupe...",
      "feedback": "Tu participes au harcèlement, même sans le vouloir.",
      "consequences": "L''élève se sent trahi et humilié. Il ne viendra plus en cours.",
      "best_practice": "💡 Même rire peut faire très mal. Le silence complice aussi.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario 3: Cyberharcèlement - Vidéo non consentie
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'La vidéo partagée sans consentement',
  'Une vidéo intime a été partagée sans accord. Comment réagir?',
  'harcelement',
  7,
  ARRAY[1,2,3],
  '{
    "start": {
      "text": "Tu apprends qu''une vidéo intime d''une camarade circule sur un groupe de classe. Elle n''était pas au courant et elle est dévastée. Que fais-tu?",
      "choices": [
        {"text": "Tu refuses de regarder et tu préviens un adulte", "next": "refuse_alert"},
        {"text": "Tu vas voir la victime pour la soutenir", "next": "support_victim"},
        {"text": "Tu signales le contenu sur les réseaux sociaux", "next": "report_online"},
        {"text": "Tu gardes ça pour toi", "next": "stay_silent"}
      ]
    },
    "refuse_alert": {
      "text": "Tu refuses de regarder la vidéo et tu vas immédiatement en parler à un adulte de confiance.",
      "feedback": "C''est la meilleure réaction ! 🌟",
      "consequences": "L''adulte peut agir rapidement : signalement, soutien à la victime, sanctions.",
      "best_practice": "✅ Partager ou regarder cette vidéo est ILLÉGAL. Alerter un adulte protège tout le monde.",
      "choices": []
    },
    "support_victim": {
      "text": "Tu vas voir ta camarade pour lui dire que tu es là pour elle.",
      "feedback": "Ton soutien est précieux ! 💙",
      "consequences": "Elle se sent moins seule dans cette épreuve terrible.",
      "best_practice": "✅ Le soutien + alerter un adulte = la combinaison idéale.",
      "choices": []
    },
    "report_online": {
      "text": "Tu signales la vidéo sur tous les réseaux où tu la vois.",
      "feedback": "Bon réflexe ! 👏",
      "consequences": "Les plateformes peuvent retirer le contenu plus rapidement.",
      "best_practice": "✅ Signaler aide à limiter la diffusion. Pense aussi à prévenir un adulte.",
      "choices": []
    },
    "stay_silent": {
      "text": "Tu ne dis rien. La vidéo continue de circuler...",
      "feedback": "Ton silence permet au harcèlement de continuer.",
      "consequences": "La victime souffre seule et la situation empire.",
      "best_practice": "💡 Le silence protège les harceleurs, pas les victimes. Agis !",
      "choices": []
    }
  }'::jsonb
);

-- Scénario 4: Moqueries sur l'accent
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'L''élève qu''on traite de "bledard"',
  'Un nouvel élève est moqué pour son accent. Comment réagir?',
  'harcelement',
  6,
  ARRAY[2,3,4],
  '{
    "start": {
      "text": "Karim vient d''arriver de l''étranger. Les élèves se moquent de son accent et le traitent de \"bledard\". Il n''ose plus participer en classe. Que fais-tu?",
      "choices": [
        {"text": "Tu lui parles et l''encourages à ne pas se décourager", "next": "encourage"},
        {"text": "Tu dénonces les moqueries au professeur", "next": "tell_teacher"},
        {"text": "Tu l''invites à manger avec toi à la cantine", "next": "invite_lunch"},
        {"text": "Tu ne fais rien car tu ne le connais pas", "next": "ignore"}
      ]
    },
    "encourage": {
      "text": "Tu vas voir Karim et tu lui dis que son accent est cool et qu''il ne doit pas écouter les autres.",
      "feedback": "Tes mots peuvent lui redonner confiance ! 💙",
      "consequences": "Karim se sent accepté et reprend confiance peu à peu.",
      "best_practice": "✅ L''encouragement sincère peut changer la vie de quelqu''un.",
      "choices": []
    },
    "tell_teacher": {
      "text": "Tu expliques la situation au professeur principal.",
      "feedback": "Excellent choix ! 🌟",
      "consequences": "Le professeur organise une sensibilisation sur le respect des différences.",
      "best_practice": "✅ Les adultes ont les moyens d''agir durablement contre les discriminations.",
      "choices": []
    },
    "invite_lunch": {
      "text": "Tu invites Karim à ta table à la cantine.",
      "feedback": "Un geste simple mais puissant ! 🤝",
      "consequences": "Karim se fait des amis et s''intègre mieux.",
      "best_practice": "✅ L''inclusion commence par des gestes simples comme celui-ci.",
      "choices": []
    },
    "ignore": {
      "text": "Tu ne fais rien. Les moqueries continuent...",
      "feedback": "L''indifférence peut faire aussi mal que les moqueries.",
      "consequences": "Karim s''isole complètement et arrête de venir en cours.",
      "best_practice": "💡 Tu peux toujours tendre la main, même à quelqu''un que tu ne connais pas.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario 5: Exclusion pour les vêtements
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Pas la bonne marque',
  'Un enfant est exclu car il ne porte pas de vêtements de marque.',
  'harcelement',
  6,
  ARRAY[2,3,4],
  '{
    "start": {
      "text": "À la récréation, tu vois des enfants qui refusent de jouer avec Lucas parce qu''il ne porte pas de vêtements de marque. Lucas est triste et seul. Que fais-tu?",
      "choices": [
        {"text": "Tu vas jouer avec Lucas", "next": "play_with"},
        {"text": "Tu expliques aux autres que c''est injuste", "next": "explain"},
        {"text": "Tu en parles à un surveillant", "next": "tell_supervisor"},
        {"text": "Tu rejoins le groupe qui exclut Lucas", "next": "join_group"}
      ]
    },
    "play_with": {
      "text": "Tu vas vers Lucas et tu lui proposes de jouer ensemble.",
      "feedback": "Super initiative ! 🌟",
      "consequences": "Lucas retrouve le sourire et d''autres enfants vous rejoignent.",
      "best_practice": "✅ Un vrai ami ne juge pas sur les apparences.",
      "choices": []
    },
    "explain": {
      "text": "Tu dis aux autres que les vêtements ne font pas la valeur d''une personne.",
      "feedback": "C''est courageux de défendre tes valeurs ! 👏",
      "consequences": "Certains réfléchissent et changent d''attitude.",
      "best_practice": "✅ Parfois, il suffit d''une voix pour faire changer les choses.",
      "choices": []
    },
    "tell_supervisor": {
      "text": "Tu vas voir le surveillant pour signaler la situation.",
      "feedback": "Bon réflexe ! 💙",
      "consequences": "Le surveillant intervient et rappelle les règles du vivre-ensemble.",
      "best_practice": "✅ Les adultes peuvent aider à résoudre ces situations.",
      "choices": []
    },
    "join_group": {
      "text": "Tu rejoins le groupe et tu ignores Lucas aussi...",
      "feedback": "Tu participes à son exclusion.",
      "consequences": "Lucas se sent rejeté par tout le monde.",
      "best_practice": "💡 Suivre le groupe n''est pas toujours la bonne chose. Écoute ta conscience.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario 6: Moqueries sur l'apparence physique
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Les surnoms sur l''apparence',
  'Une enfant est surnommée à cause de son apparence physique.',
  'harcelement',
  6,
  ARRAY[1,2,3],
  '{
    "start": {
      "text": "Tu remarques qu''Emma est appelée \"Bob l''éponge\" par des enfants à cause de son apparence. Elle qui était toujours souriante ne sourit plus. Que fais-tu?",
      "choices": [
        {"text": "Tu lui demandes si elle va bien", "next": "ask_wellbeing"},
        {"text": "Tu défends Emma devant les moqueurs", "next": "defend"},
        {"text": "Tu en parles à un animateur ou adulte", "next": "tell_adult"},
        {"text": "Tu fais comme si tu n''avais rien vu", "next": "ignore"}
      ]
    },
    "ask_wellbeing": {
      "text": "Tu prends Emma à part et tu lui demandes comment elle va vraiment.",
      "feedback": "L''écoute est un cadeau précieux ! 💙",
      "consequences": "Emma se confie et se sent moins seule.",
      "best_practice": "✅ Écouter quelqu''un qui souffre est déjà l''aider beaucoup.",
      "choices": []
    },
    "defend": {
      "text": "Tu dis aux moqueurs que ce qu''ils font n''est pas drôle.",
      "feedback": "C''est courageux ! 👏",
      "consequences": "Certains arrêtent, d''autres continuent en cachette.",
      "best_practice": "✅ Bien joué ! Pense aussi à alerter un adulte pour une solution durable.",
      "choices": []
    },
    "tell_adult": {
      "text": "Tu en parles à un animateur qui prend la situation en main.",
      "feedback": "Excellent choix ! 🌟",
      "consequences": "L''animateur discute avec tout le groupe et le harcèlement cesse.",
      "best_practice": "✅ Un adulte peut intervenir efficacement et protéger Emma.",
      "choices": []
    },
    "ignore": {
      "text": "Tu fais comme si de rien n''était...",
      "feedback": "Emma se sent invisible et abandonnée.",
      "consequences": "Elle perd ses amis et s''isole complètement.",
      "best_practice": "💡 Ne pas agir, c''est laisser la souffrance continuer.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario 7: Exclusion sportive
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Toujours au but',
  'Un enfant est toujours mis au poste qu''il n''aime pas car il est plus petit.',
  'harcelement',
  8,
  ARRAY[2,3,4],
  '{
    "start": {
      "text": "Pendant le foot, tu remarques que Théo est TOUJOURS envoyé au but par les autres parce qu''il est le plus petit. Il a l''air triste mais ne dit rien. Que fais-tu?",
      "choices": [
        {"text": "Tu proposes à Théo de jouer attaquant", "next": "propose_position"},
        {"text": "Tu en parles au coach/éducateur", "next": "tell_coach"},
        {"text": "Tu demandes aux autres de faire tourner les postes", "next": "rotate"},
        {"text": "Tu continues à jouer sans rien dire", "next": "continue"}
      ]
    },
    "propose_position": {
      "text": "Tu proposes à Théo de prendre ta place sur le terrain.",
      "feedback": "C''est généreux ! 🌟",
      "consequences": "Théo est content et montre qu''il a des qualités sur le terrain.",
      "best_practice": "✅ Donner sa chance à chacun, c''est l''esprit du sport !",
      "choices": []
    },
    "tell_coach": {
      "text": "Tu vas discrètement voir le coach et tu lui expliques la situation.",
      "feedback": "Excellent choix ! 👏",
      "consequences": "Le coach met en place une rotation obligatoire des postes.",
      "best_practice": "✅ Le coach peut garantir que tout le monde joue à tous les postes.",
      "choices": []
    },
    "rotate": {
      "text": "Tu proposes au groupe de faire tourner les postes à chaque match.",
      "feedback": "Belle initiative d''équité ! 💙",
      "consequences": "Certains acceptent et Théo peut enfin jouer ailleurs.",
      "best_practice": "✅ L''équité dans le sport, c''est important pour que tout le monde s''amuse.",
      "choices": []
    },
    "continue": {
      "text": "Tu continues à jouer sans intervenir...",
      "feedback": "Théo reste malheureux à un poste qu''il n''aime pas.",
      "consequences": "Il finit par ne plus vouloir jouer au foot.",
      "best_practice": "💡 Une petite action de ta part aurait pu tout changer pour lui.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario 8: Post-partum - Soutenir une nouvelle maman
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Ma soeur vient d''avoir un bébé',
  'Ta soeur ou une proche semble épuisée et triste après son accouchement.',
  'famille',
  6,
  ARRAY[3,4,5],
  '{
    "start": {
      "text": "Ta grande soeur vient d''avoir un bébé il y a 3 semaines. Elle pleure souvent, dort très peu et dit qu''elle n''y arrive pas. Que fais-tu?",
      "choices": [
        {"text": "Tu lui dis que c''est normal et que ça va passer", "next": "minimize"},
        {"text": "Tu proposes de l''aider concrètement", "next": "help"},
        {"text": "Tu en parles à tes parents ou un adulte", "next": "alert_family"},
        {"text": "Tu l''encourages à consulter un médecin", "next": "suggest_doctor"}
      ]
    },
    "minimize": {
      "text": "Tu lui dis que toutes les mamans passent par là et que ça va aller.",
      "feedback": "Attention, minimiser peut empêcher quelqu''un de chercher de l''aide.",
      "consequences": "Ta soeur se sent incomprise et n''ose pas demander de l''aide.",
      "best_practice": "💡 Le post-partum peut être sérieux. Il vaut mieux l''écouter et l''orienter vers un professionnel.",
      "choices": []
    },
    "help": {
      "text": "Tu proposes de garder le bébé pendant qu''elle se repose ou de faire des courses pour elle.",
      "feedback": "L''aide concrète est précieuse ! 💙",
      "consequences": "Ta soeur peut souffler un peu et se sent soutenue.",
      "best_practice": "✅ L''aide pratique soulage beaucoup. Reste attentif à son état émotionnel aussi.",
      "choices": []
    },
    "alert_family": {
      "text": "Tu en parles à tes parents pour qu''ils puissent l''aider.",
      "feedback": "Bonne idée de mobiliser la famille ! 👏",
      "consequences": "Toute la famille s''organise pour soutenir ta soeur.",
      "best_practice": "✅ Le soutien familial est essentiel dans cette période.",
      "choices": []
    },
    "suggest_doctor": {
      "text": "Tu lui suggères gentiment de parler de ce qu''elle ressent à son médecin.",
      "feedback": "Excellent conseil ! 🌟",
      "consequences": "Le médecin diagnostique un baby blues et l''accompagne.",
      "best_practice": "✅ Le post-partum se soigne très bien quand il est pris en charge !",
      "choices": []
    }
  }'::jsonb
);

-- Scénario 9: Recevoir des insultes en ligne
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Des insultes sur les réseaux',
  'Tu reçois des messages insultants sur les réseaux sociaux.',
  'harcelement',
  6,
  ARRAY[1,2,3],
  '{
    "start": {
      "text": "Tu reçois des messages insultants d''un compte anonyme sur Instagram. Ça te fait très mal. Que fais-tu?",
      "choices": [
        {"text": "Tu réponds pour te défendre", "next": "respond"},
        {"text": "Tu bloques et signales le compte", "next": "block_report"},
        {"text": "Tu en parles à un adulte de confiance", "next": "tell_adult"},
        {"text": "Tu gardes ça pour toi", "next": "keep_secret"}
      ]
    },
    "respond": {
      "text": "Tu réponds au message pour te défendre...",
      "feedback": "Répondre peut aggraver la situation.",
      "consequences": "Le harceleur continue de plus belle et prend du plaisir à ta réaction.",
      "best_practice": "💡 Ne jamais répondre aux harceleurs. Ça les encourage.",
      "choices": []
    },
    "block_report": {
      "text": "Tu fais des captures d''écran, bloques le compte et le signales à la plateforme.",
      "feedback": "Très bons réflexes ! 🌟",
      "consequences": "Tu te protèges et le compte peut être supprimé.",
      "best_practice": "✅ Bloquer + signaler + garder des preuves = la bonne combinaison.",
      "choices": []
    },
    "tell_adult": {
      "text": "Tu montres les messages à tes parents ou un adulte de confiance.",
      "feedback": "C''est la meilleure chose à faire ! 💙",
      "consequences": "L''adulte t''aide à gérer la situation et te soutient.",
      "best_practice": "✅ Tu n''as pas à affronter ça seul(e). Les adultes peuvent t''aider.",
      "choices": []
    },
    "keep_secret": {
      "text": "Tu ne dis rien à personne et tu rumines seul(e)...",
      "feedback": "Garder ça pour toi peut te faire beaucoup de mal.",
      "consequences": "Tu te sens de plus en plus mal et isolé(e).",
      "best_practice": "💡 Parler à quelqu''un, c''est déjà aller mieux.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario 10: Témoin d'une tentative de suicide
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Mon ami(e) parle de se faire du mal',
  'Un(e) ami(e) te confie qu''il/elle pense à se faire du mal.',
  'sante_mentale',
  7,
  ARRAY[1,2,3],
  '{
    "start": {
      "text": "Ton ami(e) te confie qu''il/elle n''en peut plus et pense à se faire du mal. Tu es choqué(e). Que fais-tu?",
      "choices": [
        {"text": "Tu l''écoutes et tu prends ça au sérieux", "next": "listen"},
        {"text": "Tu lui promets de garder le secret", "next": "keep_secret"},
        {"text": "Tu préviens immédiatement un adulte", "next": "alert_adult"},
        {"text": "Tu changes de sujet car c''est trop dur", "next": "change_subject"}
      ]
    },
    "listen": {
      "text": "Tu l''écoutes avec attention sans juger. Tu lui dis que tu es là pour lui/elle.",
      "feedback": "L''écoute est cruciale ! 💙",
      "consequences": "Ton ami(e) se sent entendu(e) mais a besoin d''aide professionnelle.",
      "best_practice": "✅ Écouter + alerter un adulte = tu peux sauver une vie.",
      "choices": []
    },
    "keep_secret": {
      "text": "Tu promets de ne rien dire à personne...",
      "feedback": "Dans ce cas, garder le secret peut être dangereux.",
      "consequences": "Si ton ami(e) passe à l''acte, tu te sentiras responsable.",
      "best_practice": "⚠️ TOUJOURS alerter un adulte quand quelqu''un parle de se faire du mal, même si on nous demande de garder le secret.",
      "choices": []
    },
    "alert_adult": {
      "text": "Tu préviens immédiatement un adulte de confiance (parent, prof, infirmière).",
      "feedback": "Tu fais ce qu''il faut ! 🌟",
      "consequences": "L''adulte prend les choses en main et ton ami(e) reçoit de l''aide.",
      "best_practice": "✅ C''est LA bonne réaction. Tu peux sauver une vie.",
      "choices": []
    },
    "change_subject": {
      "text": "Tu changes de sujet car tu ne sais pas quoi dire...",
      "feedback": "C''est compréhensible d''être mal à l''aise, mais ton ami(e) a besoin d''aide.",
      "consequences": "Ton ami(e) se sent encore plus seul(e) et incompris(e).",
      "best_practice": "💡 Même si c''est dur, il faut en parler à un adulte. Tu n''as pas à gérer ça seul(e).",
      "choices": []
    }
  }'::jsonb
);

-- Scénario 11: La rumeur qui se propage
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'La rumeur qui fait le tour du collège',
  'Une fausse rumeur circule sur toi ou un(e) ami(e).',
  'harcelement',
  6,
  ARRAY[1,2,3],
  '{
    "start": {
      "text": "Une rumeur complètement fausse circule sur toi dans tout le collège. Les gens te regardent bizarrement et chuchotent. Que fais-tu?",
      "choices": [
        {"text": "Tu essaies de te justifier auprès de tout le monde", "next": "justify"},
        {"text": "Tu en parles à un adulte de confiance", "next": "tell_adult"},
        {"text": "Tu identifies qui a lancé la rumeur", "next": "find_source"},
        {"text": "Tu t''isoles et tu attends que ça passe", "next": "isolate"}
      ]
    },
    "justify": {
      "text": "Tu essaies de te justifier auprès de chaque personne...",
      "feedback": "Te justifier constamment peut être épuisant et contre-productif.",
      "consequences": "Plus tu en parles, plus la rumeur se propage.",
      "best_practice": "💡 Il vaut mieux agir à la source et demander l''aide d''un adulte.",
      "choices": []
    },
    "tell_adult": {
      "text": "Tu en parles à un professeur ou au CPE qui prend la situation au sérieux.",
      "feedback": "Excellent choix ! 🌟",
      "consequences": "L''adulte intervient et organise une médiation.",
      "best_practice": "✅ Les adultes peuvent agir pour stopper la rumeur officiellement.",
      "choices": []
    },
    "find_source": {
      "text": "Tu cherches à savoir qui a lancé la rumeur.",
      "feedback": "Comprendre d''où ça vient peut aider.",
      "consequences": "Tu identifies la personne mais la confrontation peut mal tourner.",
      "best_practice": "💡 Une fois la source identifiée, mieux vaut en parler à un adulte plutôt que de régler ça seul(e).",
      "choices": []
    },
    "isolate": {
      "text": "Tu t''isoles en espérant que ça passe...",
      "feedback": "L''isolement peut aggraver ta souffrance.",
      "consequences": "Tu te sens de plus en plus mal et la rumeur continue.",
      "best_practice": "💡 Ne reste pas seul(e) face à ça. Parle à quelqu''un de confiance.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario 12: Chantage avec des photos
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'On me fait du chantage',
  'Quelqu''un menace de publier des photos de toi.',
  'harcelement',
  6,
  ARRAY[1,2,3],
  '{
    "start": {
      "text": "Quelqu''un possède des photos gênantes de toi et menace de les publier si tu ne fais pas ce qu''il/elle veut. Que fais-tu?",
      "choices": [
        {"text": "Tu cèdes au chantage pour éviter la diffusion", "next": "give_in"},
        {"text": "Tu en parles immédiatement à tes parents", "next": "tell_parents"},
        {"text": "Tu gardes des preuves et tu vas voir la police", "next": "police"},
        {"text": "Tu essaies de négocier", "next": "negotiate"}
      ]
    },
    "give_in": {
      "text": "Tu fais ce qu''on te demande...",
      "feedback": "Céder au chantage ne fait qu''encourager le maître-chanteur.",
      "consequences": "Les demandes deviennent de plus en plus exigeantes.",
      "best_practice": "⚠️ Ne JAMAIS céder au chantage. Ça ne fait qu''empirer les choses.",
      "choices": []
    },
    "tell_parents": {
      "text": "Tu en parles à tes parents malgré la honte.",
      "feedback": "C''est la meilleure chose à faire ! 🌟",
      "consequences": "Tes parents t''aident à porter plainte et te soutiennent.",
      "best_practice": "✅ Tes parents sont là pour te protéger, même dans les situations difficiles.",
      "choices": []
    },
    "police": {
      "text": "Tu gardes toutes les preuves et tu vas porter plainte.",
      "feedback": "Excellent réflexe ! 👏",
      "consequences": "Le chantage est un délit puni par la loi. La police peut agir.",
      "best_practice": "✅ Le chantage est ILLÉGAL. La justice peut te protéger.",
      "choices": []
    },
    "negotiate": {
      "text": "Tu essaies de négocier avec la personne...",
      "feedback": "Négocier avec un maître-chanteur est rarement efficace.",
      "consequences": "La personne continue ses menaces.",
      "best_practice": "💡 Il n''y a pas de négociation possible. Alerte un adulte et la police.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario 13: L'ami(e) qui s'isole
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Mon ami(e) s''isole',
  'Ton ami(e) ne parle plus et s''isole de tout le monde.',
  'sante_mentale',
  6,
  ARRAY[2,3,4],
  '{
    "start": {
      "text": "Depuis quelques semaines, ton ami(e) ne vient plus manger avec vous, ne répond plus aux messages et semble très triste. Que fais-tu?",
      "choices": [
        {"text": "Tu lui envoies un message bienveillant", "next": "send_message"},
        {"text": "Tu vas le/la voir en personne", "next": "visit"},
        {"text": "Tu en parles à un adulte qui peut l''aider", "next": "tell_adult"},
        {"text": "Tu respectes son besoin d''espace", "next": "give_space"}
      ]
    },
    "send_message": {
      "text": "Tu lui envoies un message : \"Je suis là si tu as besoin, sans pression.\"",
      "feedback": "Un message bienveillant peut faire beaucoup ! 💙",
      "consequences": "Ton ami(e) sait qu''il/elle peut compter sur toi.",
      "best_practice": "✅ Montrer sa présence sans forcer est important.",
      "choices": []
    },
    "visit": {
      "text": "Tu vas le/la voir en personne pour prendre de ses nouvelles.",
      "feedback": "Le contact direct est souvent plus efficace ! 🤝",
      "consequences": "Ton ami(e) s''ouvre peut-être sur ce qui ne va pas.",
      "best_practice": "✅ Parfois, une présence physique est plus réconfortante qu''un message.",
      "choices": []
    },
    "tell_adult": {
      "text": "Tu en parles à un adulte (parent, prof, infirmière) car tu t''inquiètes vraiment.",
      "feedback": "Tu as raison de t''inquiéter et d''agir ! 🌟",
      "consequences": "L''adulte peut prendre le relais pour aider ton ami(e).",
      "best_practice": "✅ Si tu sens que c''est grave, alerter un adulte est la bonne décision.",
      "choices": []
    },
    "give_space": {
      "text": "Tu le/la laisses tranquille en pensant bien faire...",
      "feedback": "Parfois, quelqu''un qui s''isole a besoin qu''on vienne vers lui/elle.",
      "consequences": "Ton ami(e) peut se sentir abandonné(e).",
      "best_practice": "💡 Il vaut mieux montrer sa présence tout en respectant son rythme.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario 14: Le professeur qui humilie
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Un professeur se moque de moi',
  'Un enseignant fait des remarques humiliantes devant la classe.',
  'harcelement',
  6,
  ARRAY[1,2,3],
  '{
    "start": {
      "text": "Un professeur se moque régulièrement de toi devant toute la classe. Les autres élèves rient. Tu te sens humilié(e). Que fais-tu?",
      "choices": [
        {"text": "Tu en parles à tes parents", "next": "tell_parents"},
        {"text": "Tu vas voir le/la CPE ou le principal", "next": "see_admin"},
        {"text": "Tu confrontes le professeur", "next": "confront"},
        {"text": "Tu subis en silence", "next": "suffer"}
      ]
    },
    "tell_parents": {
      "text": "Tu en parles à tes parents qui prennent la situation au sérieux.",
      "feedback": "Bien joué ! 🌟",
      "consequences": "Tes parents demandent un rendez-vous avec la direction.",
      "best_practice": "✅ Tes parents peuvent intervenir et te défendre.",
      "choices": []
    },
    "see_admin": {
      "text": "Tu vas voir le/la CPE pour signaler le comportement du professeur.",
      "feedback": "C''est courageux et c''est ton droit ! 👏",
      "consequences": "La direction peut intervenir pour que ça cesse.",
      "best_practice": "✅ Les enseignants aussi doivent respecter les élèves. Tu as le droit de signaler.",
      "choices": []
    },
    "confront": {
      "text": "Tu dis au professeur que ses remarques te blessent...",
      "feedback": "C''est courageux mais risqué.",
      "consequences": "Le professeur peut mal réagir ou se remettre en question.",
      "best_practice": "💡 Il vaut mieux passer par la voie officielle (parents, direction).",
      "choices": []
    },
    "suffer": {
      "text": "Tu subis en silence, cours après cours...",
      "feedback": "Tu ne devrais pas avoir à supporter ça.",
      "consequences": "Tu perds confiance en toi et tu dreads d''aller en cours.",
      "best_practice": "💡 Personne n''a le droit de t''humilier, même un professeur. Parle !",
      "choices": []
    }
  }'::jsonb
);

-- Scénario 15: Aider un ami en dépression
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Mon ami(e) semble déprimé(e)',
  'Tu remarques que ton ami(e) montre des signes de dépression.',
  'sante_mentale',
  6,
  ARRAY[2,3,4],
  '{
    "start": {
      "text": "Ton ami(e) dort beaucoup, ne mange plus, a arrêté ses activités et dit souvent \"À quoi bon?\". Tu t''inquiètes. Que fais-tu?",
      "choices": [
        {"text": "Tu lui proposes des activités pour le/la distraire", "next": "distract"},
        {"text": "Tu lui parles de ce que tu observes", "next": "talk"},
        {"text": "Tu en parles à un adulte de confiance", "next": "tell_adult"},
        {"text": "Tu attends que ça passe", "next": "wait"}
      ]
    },
    "distract": {
      "text": "Tu lui proposes des sorties et activités...",
      "feedback": "C''est gentil mais la dépression ne se guérit pas par la distraction.",
      "consequences": "Ton ami(e) refuse ou n''a pas l''énergie.",
      "best_practice": "💡 La dépression est une maladie. Il faut une aide professionnelle.",
      "choices": []
    },
    "talk": {
      "text": "Tu lui dis : \"Je vois que tu ne vas pas bien. Je suis là pour toi.\"",
      "feedback": "Lui montrer que tu vois sa souffrance est important ! 💙",
      "consequences": "Ton ami(e) se sent compris(e) et peut s''ouvrir.",
      "best_practice": "✅ Écouter sans juger + l''encourager à chercher de l''aide = parfait.",
      "choices": []
    },
    "tell_adult": {
      "text": "Tu en parles à un adulte (parent, infirmière scolaire).",
      "feedback": "Tu fais ce qu''il faut ! 🌟",
      "consequences": "L''adulte peut orienter ton ami(e) vers un professionnel de santé.",
      "best_practice": "✅ La dépression se soigne ! Alerter un adulte peut sauver une vie.",
      "choices": []
    },
    "wait": {
      "text": "Tu penses que c''est juste une mauvaise passe...",
      "feedback": "La dépression ne passe pas toute seule.",
      "consequences": "L''état de ton ami(e) peut s''aggraver.",
      "best_practice": "💡 Ne pas attendre. Plus tôt on agit, mieux c''est.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario 16: Le groupe qui exclut
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Exclu(e) du groupe',
  'Du jour au lendemain, tes amis t''excluent sans explication.',
  'harcelement',
  6,
  ARRAY[2,3,4],
  '{
    "start": {
      "text": "Tes amis ne te parlent plus, ne t''invitent plus et t''ignorent complètement. Tu ne comprends pas pourquoi. Que fais-tu?",
      "choices": [
        {"text": "Tu demandes une explication à l''un d''eux", "next": "ask"},
        {"text": "Tu essaies de te faire de nouveaux amis", "next": "new_friends"},
        {"text": "Tu en parles à un adulte", "next": "tell_adult"},
        {"text": "Tu fais tout pour qu''ils t''acceptent à nouveau", "next": "please_them"}
      ]
    },
    "ask": {
      "text": "Tu demandes à l''un d''eux ce qui s''est passé.",
      "feedback": "Chercher à comprendre est légitime ! 💙",
      "consequences": "Tu obtiens peut-être une explication et peux clarifier les choses.",
      "best_practice": "✅ La communication peut résoudre des malentendus.",
      "choices": []
    },
    "new_friends": {
      "text": "Tu décides de te tourner vers d''autres personnes.",
      "feedback": "Parfois, s''éloigner de personnes toxiques est la meilleure chose ! 🌟",
      "consequences": "Tu découvres de vraies amitiés avec des gens qui te respectent.",
      "best_practice": "✅ Les vrais amis ne t''excluent pas sans raison.",
      "choices": []
    },
    "tell_adult": {
      "text": "Tu en parles à un adulte car tu souffres de cette exclusion.",
      "feedback": "Bien joué ! 👏",
      "consequences": "L''adulte peut t''aider à gérer la situation et tes émotions.",
      "best_practice": "✅ L''exclusion sociale fait très mal. Tu as le droit de demander de l''aide.",
      "choices": []
    },
    "please_them": {
      "text": "Tu fais tout pour leur plaire et être accepté(e) à nouveau...",
      "feedback": "Tu ne devrais pas avoir à changer qui tu es pour des \"amis\".",
      "consequences": "Tu perds confiance en toi et tu n''es pas plus accepté(e).",
      "best_practice": "💡 De vrais amis t''acceptent comme tu es.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario 17: Harcèlement dans les transports
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Dans le bus scolaire',
  'Tu te fais embêter régulièrement dans le bus par d''autres élèves.',
  'harcelement',
  8,
  ARRAY[1,2,3],
  '{
    "start": {
      "text": "Chaque jour dans le bus, des élèves te lancent des insultes, te volent tes affaires ou te bousculent. Que fais-tu?",
      "choices": [
        {"text": "Tu changes de place ou d''horaire", "next": "avoid"},
        {"text": "Tu en parles au chauffeur", "next": "tell_driver"},
        {"text": "Tu alertes tes parents et le collège", "next": "alert_all"},
        {"text": "Tu te défends physiquement", "next": "fight_back"}
      ]
    },
    "avoid": {
      "text": "Tu essaies d''éviter ces élèves en changeant de place...",
      "feedback": "L''évitement peut aider temporairement mais ne règle pas le problème.",
      "consequences": "Les harceleurs peuvent te suivre ou continuer ailleurs.",
      "best_practice": "💡 L''évitement seul ne suffit pas. Il faut alerter des adultes.",
      "choices": []
    },
    "tell_driver": {
      "text": "Tu signales le problème au chauffeur du bus.",
      "feedback": "Bon réflexe ! 👏",
      "consequences": "Le chauffeur peut intervenir et signaler à l''établissement.",
      "best_practice": "✅ Le chauffeur est responsable de la sécurité dans le bus.",
      "choices": []
    },
    "alert_all": {
      "text": "Tu en parles à tes parents qui contactent le collège.",
      "feedback": "Excellent ! C''est la meilleure solution ! 🌟",
      "consequences": "Une action coordonnée peut être mise en place pour que ça cesse.",
      "best_practice": "✅ Parents + collège ensemble = action efficace.",
      "choices": []
    },
    "fight_back": {
      "text": "Tu te défends en les frappant...",
      "feedback": "La violence n''est jamais la solution.",
      "consequences": "Tu risques d''être puni(e) aussi et la situation empire.",
      "best_practice": "💡 Te défendre verbalement oui, physiquement non. Alerte des adultes.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario 18: L'ami qui se scarifie
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'J''ai vu des marques sur ses bras',
  'Tu remarques des cicatrices sur les bras de ton ami(e).',
  'sante_mentale',
  6,
  ARRAY[1,2,3],
  '{
    "start": {
      "text": "Tu remarques des marques de coupures sur les bras de ton ami(e) qu''il/elle essaie de cacher. Tu es choqué(e) et inquiet(e). Que fais-tu?",
      "choices": [
        {"text": "Tu lui poses la question doucement et en privé", "next": "ask_gently"},
        {"text": "Tu en parles immédiatement à un adulte", "next": "tell_adult"},
        {"text": "Tu fais comme si tu n''avais rien vu", "next": "ignore"},
        {"text": "Tu lui fais promettre d''arrêter", "next": "make_promise"}
      ]
    },
    "ask_gently": {
      "text": "Tu lui dis en privé : \"J''ai remarqué... Je suis inquiet(e). Est-ce que tu veux en parler?\"",
      "feedback": "Aborder le sujet avec douceur est important ! 💙",
      "consequences": "Ton ami(e) peut s''ouvrir ou se fermer, mais il/elle sait que tu te soucies.",
      "best_practice": "✅ Écouter sans juger + alerter ensuite un adulte = la bonne approche.",
      "choices": []
    },
    "tell_adult": {
      "text": "Tu en parles immédiatement à un adulte de confiance.",
      "feedback": "C''est la bonne réaction ! 🌟",
      "consequences": "L''adulte peut mettre en place un accompagnement professionnel.",
      "best_practice": "✅ L''automutilation est un signe de grande souffrance. Alerter un adulte peut sauver une vie.",
      "choices": []
    },
    "ignore": {
      "text": "Tu fais comme si tu n''avais rien vu...",
      "feedback": "Ignorer peut laisser ton ami(e) dans une spirale dangereuse.",
      "consequences": "La situation peut s''aggraver sans aide.",
      "best_practice": "💡 Même si c''est difficile, il faut agir. Ton ami(e) a besoin d''aide.",
      "choices": []
    },
    "make_promise": {
      "text": "Tu lui demandes de te promettre d''arrêter...",
      "feedback": "L''automutilation ne s''arrête pas par une simple promesse.",
      "consequences": "Ton ami(e) se sent coupable mais ne peut pas s''arrêter seul(e).",
      "best_practice": "💡 L''automutilation est une maladie. Il faut une aide professionnelle.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario 19: Pression pour envoyer des photos
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'On me demande des photos intimes',
  'Quelqu''un te met la pression pour envoyer des photos de toi.',
  'harcelement',
  6,
  ARRAY[1,2,3],
  '{
    "start": {
      "text": "Quelqu''un (que tu connais ou pas) te demande d''envoyer des photos intimes de toi. Il/elle insiste beaucoup. Que fais-tu?",
      "choices": [
        {"text": "Tu refuses fermement et tu bloques", "next": "refuse_block"},
        {"text": "Tu en parles à un adulte", "next": "tell_adult"},
        {"text": "Tu envoies pour qu''il/elle te laisse tranquille", "next": "send"},
        {"text": "Tu demandes pourquoi et tu négocies", "next": "negotiate"}
      ]
    },
    "refuse_block": {
      "text": "Tu dis NON fermement et tu bloques cette personne.",
      "feedback": "C''est exactement ce qu''il faut faire ! 🌟",
      "consequences": "Tu te protèges et tu coupes le contact.",
      "best_practice": "✅ TON CORPS = TES RÈGLES. Personne n''a le droit de te forcer.",
      "choices": []
    },
    "tell_adult": {
      "text": "Tu montres les messages à tes parents ou un adulte de confiance.",
      "feedback": "Excellente décision ! 👏",
      "consequences": "L''adulte peut t''aider à gérer la situation et signaler si nécessaire.",
      "best_practice": "✅ Ce comportement est du harcèlement. Tu as bien fait d''en parler.",
      "choices": []
    },
    "send": {
      "text": "Tu envoies une photo en espérant que ça s''arrête...",
      "feedback": "⚠️ ATTENTION : Une fois envoyée, tu perds le contrôle de cette image.",
      "consequences": "La personne peut demander plus ou partager la photo.",
      "best_practice": "⚠️ N''envoie JAMAIS de photos intimes. Elles peuvent être utilisées contre toi.",
      "choices": []
    },
    "negotiate": {
      "text": "Tu essaies de discuter et de comprendre...",
      "feedback": "Il n''y a pas de négociation possible avec ce type de demande.",
      "consequences": "La personne continue d''insister.",
      "best_practice": "💡 La seule réponse est NON. Pas de discussion, pas de négociation.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario 20: Témoignage au tribunal
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'On me demande de témoigner',
  'Tu as été témoin de harcèlement et on te demande de témoigner.',
  'harcelement',
  6,
  ARRAY[2,3,4],
  '{
    "start": {
      "text": "Tu as vu ce qui s''est passé. La victime ou un adulte te demande de témoigner officiellement. Tu as peur des représailles. Que fais-tu?",
      "choices": [
        {"text": "Tu acceptes de témoigner", "next": "testify"},
        {"text": "Tu refuses par peur", "next": "refuse"},
        {"text": "Tu témoignes anonymement", "next": "anonymous"},
        {"text": "Tu demandes comment tu seras protégé(e)", "next": "ask_protection"}
      ]
    },
    "testify": {
      "text": "Tu acceptes de témoigner de ce que tu as vu.",
      "feedback": "C''est très courageux ! 🌟",
      "consequences": "Ton témoignage peut aider la victime à obtenir justice.",
      "best_practice": "✅ Les témoins sont essentiels pour faire cesser le harcèlement.",
      "choices": []
    },
    "refuse": {
      "text": "Tu refuses de témoigner par peur...",
      "feedback": "Ta peur est compréhensible mais la victime a besoin de soutien.",
      "consequences": "Sans témoins, il est plus difficile de prouver le harcèlement.",
      "best_practice": "💡 Parle de tes peurs à un adulte. Il existe des protections pour les témoins.",
      "choices": []
    },
    "anonymous": {
      "text": "Tu demandes s''il est possible de témoigner de façon anonyme.",
      "feedback": "Bonne idée pour te protéger ! 💙",
      "consequences": "Dans certains cas, c''est possible et ça aide quand même.",
      "best_practice": "✅ Un témoignage même anonyme peut faire avancer les choses.",
      "choices": []
    },
    "ask_protection": {
      "text": "Tu demandes quelles protections existent pour les témoins.",
      "feedback": "Question très pertinente ! 👏",
      "consequences": "On t''explique les mesures de protection possibles.",
      "best_practice": "✅ Il existe des dispositifs pour protéger les témoins. Renseigne-toi !",
      "choices": []
    }
  }'::jsonb
);

SELECT 'Les 20 scénarios ont été insérés avec succès !' AS message;

-- =====================================================
-- QUIZ ADDITIONNELS (20 quiz)
-- =====================================================

-- Quiz 1: Reconnaître le cyberharcèlement
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Le cyberharcèlement, c''est quoi?',
  'Teste tes connaissances sur le harcèlement en ligne et comment t''en protéger.',
  'harcelement',
  'facile',
  5,
  ARRAY[1,2,3],
  '[
    {
      "question": "Le cyberharcèlement, c''est:",
      "answers": [
        "Des blagues entre amis sur Internet",
        "Des actes répétés de violence via les outils numériques",
        "Poster des photos sur Instagram",
        "Jouer en ligne avec des inconnus"
      ],
      "correct_answer": 1,
      "explanation": "Le cyberharcèlement désigne des comportements répétés et malveillants utilisant les outils numériques (réseaux sociaux, SMS, etc.)."
    },
    {
      "question": "Que faire si tu reçois des messages insultants?",
      "answers": [
        "Répondre avec des insultes aussi",
        "Ne rien faire et espérer que ça passe",
        "Faire des captures d''écran, bloquer et en parler à un adulte",
        "Supprimer les messages et oublier"
      ],
      "correct_answer": 2,
      "explanation": "Il est important de garder des preuves, de bloquer l''agresseur et d''en parler à un adulte de confiance."
    },
    {
      "question": "Quel numéro appeler en cas de cyberharcèlement en France?",
      "answers": [
        "Le 15",
        "Le 3018",
        "Le 112",
        "Le 17"
      ],
      "correct_answer": 1,
      "explanation": "Le 3018 est le numéro national contre le cyberharcèlement. Il est gratuit et anonyme."
    }
  ]'::jsonb
);

-- Quiz 2: Body shaming et acceptation de soi
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Accepter son corps',
  'Comprends ce qu''est le body shaming et comment s''en protéger.',
  'estime',
  'moyen',
  6,
  ARRAY[2,3,4],
  '[
    {
      "question": "Le body shaming, c''est:",
      "answers": [
        "Faire du sport pour être en forme",
        "Se moquer du physique de quelqu''un",
        "Manger équilibré",
        "Choisir ses vêtements"
      ],
      "correct_answer": 1,
      "explanation": "Le body shaming consiste à se moquer, critiquer ou humilier quelqu''un à cause de son apparence physique."
    },
    {
      "question": "Si quelqu''un se moque de ton poids, quelle est la meilleure réaction?",
      "answers": [
        "Te mettre au régime immédiatement",
        "Te moquer de lui aussi",
        "Savoir que sa critique en dit plus sur lui que sur toi",
        "Te cacher et éviter tout le monde"
      ],
      "correct_answer": 2,
      "explanation": "Les moqueries sur le physique reflètent les insécurités de celui qui les fait. Tu n''as pas à changer pour plaire aux autres."
    },
    {
      "question": "Qu''est-ce qui est vrai sur l''apparence physique?",
      "answers": [
        "Seuls les gens minces sont beaux",
        "La valeur d''une personne ne dépend pas de son physique",
        "Il faut ressembler aux influenceurs",
        "Les vêtements de marque te rendent meilleur"
      ],
      "correct_answer": 1,
      "explanation": "Ta valeur ne dépend pas de ton apparence. Chaque corps est unique et mérite le respect."
    }
  ]'::jsonb
);

-- Quiz 3: Les signes du harcèlement
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Reconnaître les signes du harcèlement',
  'Apprends à identifier si quelqu''un est victime de harcèlement.',
  'harcelement',
  'moyen',
  7,
  ARRAY[1,2,3],
  '[
    {
      "question": "Quel signe peut indiquer qu''un(e) ami(e) est harcelé(e)?",
      "answers": [
        "Il/elle a beaucoup d''amis",
        "Il/elle refuse soudainement d''aller à l''école",
        "Il/elle participe en classe",
        "Il/elle mange bien"
      ],
      "correct_answer": 1,
      "explanation": "Le refus soudain d''aller à l''école peut être un signe de harcèlement. D''autres signes: isolement, tristesse, chute des notes."
    },
    {
      "question": "Le harcèlement peut avoir lieu:",
      "answers": [
        "Seulement à l''école",
        "Seulement sur Internet",
        "Partout: école, transports, Internet, activités...",
        "Seulement entre adultes"
      ],
      "correct_answer": 2,
      "explanation": "Le harcèlement peut se produire partout: en classe, dans la cour, dans le bus, sur les réseaux sociaux, etc."
    },
    {
      "question": "Pour qu''on parle de harcèlement, il faut:",
      "answers": [
        "Un seul incident grave",
        "Des actes répétés dans le temps",
        "Que ce soit filmé",
        "Au moins 10 personnes impliquées"
      ],
      "correct_answer": 1,
      "explanation": "Le harcèlement se caractérise par la répétition des actes malveillants dans le temps."
    }
  ]'::jsonb
);

-- Quiz 4: La santé mentale des jeunes
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Prendre soin de sa santé mentale',
  'Découvre l''importance de la santé mentale et comment en prendre soin.',
  'sante_mentale',
  'facile',
  5,
  ARRAY[2,3,4,5],
  '[
    {
      "question": "La santé mentale, c''est:",
      "answers": [
        "Ne jamais être triste",
        "Un état de bien-être émotionnel et psychologique",
        "Être toujours positif",
        "Ne pas avoir de problèmes"
      ],
      "correct_answer": 1,
      "explanation": "La santé mentale est un état de bien-être global. C''est normal d''avoir des hauts et des bas."
    },
    {
      "question": "Qu''est-ce qui aide à maintenir une bonne santé mentale?",
      "answers": [
        "S''isoler complètement",
        "Dormir 4h par nuit",
        "Bouger, bien dormir et parler de ses émotions",
        "Garder tout pour soi"
      ],
      "correct_answer": 2,
      "explanation": "L''activité physique, un bon sommeil et parler de ses émotions sont essentiels pour la santé mentale."
    },
    {
      "question": "Demander de l''aide quand on ne va pas bien, c''est:",
      "answers": [
        "Un signe de faiblesse",
        "Un acte de courage et de force",
        "Inutile car personne ne peut aider",
        "Réservé aux adultes"
      ],
      "correct_answer": 1,
      "explanation": "Demander de l''aide est un acte courageux. Personne ne devrait souffrir seul."
    }
  ]'::jsonb
);

-- Quiz 5: Discrimination et diversité
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Respecter les différences',
  'Comprends ce qu''est la discrimination et pourquoi la diversité est une richesse.',
  'harcelement',
  'moyen',
  6,
  ARRAY[2,3,4],
  '[
    {
      "question": "Se moquer de l''accent de quelqu''un, c''est:",
      "answers": [
        "Juste une blague innocente",
        "De la discrimination",
        "Normal entre amis",
        "Un compliment déguisé"
      ],
      "correct_answer": 1,
      "explanation": "Se moquer de l''accent de quelqu''un est une forme de discrimination liée à l''origine. C''est blessant et irrespectueux."
    },
    {
      "question": "Exclure quelqu''un car il n''a pas de vêtements de marque:",
      "answers": [
        "Est compréhensible, les marques c''est important",
        "Est une forme de discrimination sociale",
        "Est le choix de chacun",
        "Est normal chez les jeunes"
      ],
      "correct_answer": 1,
      "explanation": "Exclure quelqu''un pour ses vêtements est une forme de discrimination basée sur l''apparence et le statut social."
    },
    {
      "question": "La diversité (origines, cultures, physiques...) est:",
      "answers": [
        "Un problème à résoudre",
        "Une richesse pour la société",
        "Sans importance",
        "Quelque chose à cacher"
      ],
      "correct_answer": 1,
      "explanation": "La diversité est une richesse qui nous permet d''apprendre les uns des autres et de grandir ensemble."
    }
  ]'::jsonb
);

-- Quiz 6: Les réseaux sociaux et leurs dangers
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Bien utiliser les réseaux sociaux',
  'Apprends à naviguer sur les réseaux sociaux en toute sécurité.',
  'harcelement',
  'facile',
  5,
  ARRAY[1,2,3],
  '[
    {
      "question": "Avant de poster une photo de quelqu''un, il faut:",
      "answers": [
        "Vérifier si elle est jolie",
        "Demander son accord",
        "Ajouter un filtre",
        "Rien de spécial"
      ],
      "correct_answer": 1,
      "explanation": "On doit TOUJOURS demander l''accord de quelqu''un avant de poster sa photo. C''est une question de respect et de légalité."
    },
    {
      "question": "Une photo intime envoyée à une personne:",
      "answers": [
        "Reste toujours privée",
        "Peut être partagée sans ton contrôle",
        "Disparaît après lecture",
        "Est protégée par l''application"
      ],
      "correct_answer": 1,
      "explanation": "Une fois envoyée, tu perds le contrôle de l''image. Elle peut être capturée et partagée. Ne prends pas ce risque."
    },
    {
      "question": "Si quelqu''un publie une photo de toi sans ton accord:",
      "answers": [
        "C''est normal, on est amis",
        "Tu peux demander à la supprimer et signaler",
        "Tu ne peux rien faire",
        "Tu dois juste accepter"
      ],
      "correct_answer": 1,
      "explanation": "Tu as le droit à l''image. Tu peux demander la suppression et signaler le contenu à la plateforme."
    }
  ]'::jsonb
);

-- Quiz 7: L'estime de soi
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Construire son estime de soi',
  'Découvre comment développer une image positive de toi-même.',
  'estime',
  'moyen',
  6,
  ARRAY[3,4,5],
  '[
    {
      "question": "L''estime de soi se construit:",
      "answers": [
        "En étant meilleur que les autres",
        "En s''acceptant avec ses qualités ET ses défauts",
        "En ayant beaucoup de followers",
        "En étant parfait"
      ],
      "correct_answer": 1,
      "explanation": "L''estime de soi vient de l''acceptation de soi-même, avec ses forces et ses faiblesses."
    },
    {
      "question": "Se comparer constamment aux autres sur les réseaux:",
      "answers": [
        "Aide à s''améliorer",
        "Peut nuire à l''estime de soi",
        "Est sans effet",
        "Est recommandé"
      ],
      "correct_answer": 1,
      "explanation": "Les réseaux montrent une version filtrée de la réalité. Se comparer peut créer un sentiment d''insuffisance."
    },
    {
      "question": "Quand tu fais une erreur, tu devrais:",
      "answers": [
        "Te critiquer durement",
        "Abandonner définitivement",
        "Apprendre de ton erreur et continuer",
        "Cacher ton erreur"
      ],
      "correct_answer": 2,
      "explanation": "Les erreurs font partie de l''apprentissage. L''important est d''en tirer des leçons et de continuer à avancer."
    }
  ]'::jsonb
);

-- Quiz 8: Le post-partum
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Comprendre le post-partum',
  'Apprends ce qu''est le post-partum et comment aider une nouvelle maman.',
  'famille',
  'moyen',
  7,
  ARRAY[3,4,5],
  '[
    {
      "question": "Le post-partum, c''est:",
      "answers": [
        "Une maladie rare",
        "La période après l''accouchement avec ses défis émotionnels",
        "Une mode sur les réseaux sociaux",
        "Quelque chose qui n''existe pas vraiment"
      ],
      "correct_answer": 1,
      "explanation": "Le post-partum désigne la période après l''accouchement, souvent marquée par des changements hormonaux et émotionnels."
    },
    {
      "question": "Le baby blues peut causer:",
      "answers": [
        "De la joie uniquement",
        "Des pleurs, de la fatigue et de l''anxiété",
        "Rien de particulier",
        "Des envies de shopping"
      ],
      "correct_answer": 1,
      "explanation": "Le baby blues se manifeste par des pleurs, une fatigue intense, de l''anxiété et des sautes d''humeur."
    },
    {
      "question": "Face à une nouvelle maman qui semble déprimée:",
      "answers": [
        "Lui dire que c''est normal et que ça passera",
        "L''ignorer, c''est pas nos affaires",
        "L''écouter et l''encourager à consulter",
        "Lui dire qu''elle exagère"
      ],
      "correct_answer": 2,
      "explanation": "Il faut prendre ses émotions au sérieux, l''écouter et l''encourager à consulter un professionnel si ça dure."
    }
  ]'::jsonb
);

-- Quiz 9: Être un bon témoin
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Agir quand on est témoin',
  'Apprends comment réagir quand tu es témoin de harcèlement.',
  'harcelement',
  'moyen',
  6,
  ARRAY[1,2,3],
  '[
    {
      "question": "Si tu vois quelqu''un se faire harceler, tu devrais:",
      "answers": [
        "Rire avec les autres pour ne pas être visé",
        "Filmer la scène",
        "En parler à un adulte de confiance",
        "Faire comme si tu n''avais rien vu"
      ],
      "correct_answer": 2,
      "explanation": "Le meilleur moyen d''aider est de prévenir un adulte qui peut intervenir et mettre fin à la situation."
    },
    {
      "question": "Un témoin qui ne fait rien:",
      "answers": [
        "N''a aucune responsabilité",
        "Contribue indirectement au harcèlement",
        "Fait le bon choix",
        "Protège la victime"
      ],
      "correct_answer": 1,
      "explanation": "Le silence des témoins peut être perçu comme une approbation et renforce le pouvoir des harceleurs."
    },
    {
      "question": "Montrer son soutien à une victime peut se faire en:",
      "answers": [
        "L''ignorant pour ne pas attirer l''attention",
        "Lui envoyant un message de soutien",
        "Rejoignant les moqueurs",
        "Changeant d''école"
      ],
      "correct_answer": 1,
      "explanation": "Un simple message ou geste de soutien peut faire une énorme différence pour quelqu''un qui souffre."
    }
  ]'::jsonb
);

-- Quiz 10: Gestion des émotions
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Comprendre et gérer ses émotions',
  'Apprends à identifier et gérer tes émotions au quotidien.',
  'sante_mentale',
  'facile',
  5,
  ARRAY[2,3,4,5],
  '[
    {
      "question": "Ressentir de la colère ou de la tristesse:",
      "answers": [
        "Est un signe de faiblesse",
        "Est normal et fait partie de la vie",
        "Doit être évité à tout prix",
        "Est réservé aux enfants"
      ],
      "correct_answer": 1,
      "explanation": "Toutes les émotions sont normales et naturelles. L''important est d''apprendre à les exprimer sainement."
    },
    {
      "question": "Quand tu es très en colère, tu peux:",
      "answers": [
        "Frapper quelqu''un pour te défouler",
        "Tout garder pour toi",
        "Respirer profondément et prendre du recul",
        "Casser des objets"
      ],
      "correct_answer": 2,
      "explanation": "La respiration profonde et le recul permettent de calmer la colère avant d''agir de façon regrettable."
    },
    {
      "question": "Parler de ses émotions:",
      "answers": [
        "Est inutile, ça ne change rien",
        "Aide à se sentir mieux et à trouver des solutions",
        "Est réservé aux psys",
        "Rend les choses pires"
      ],
      "correct_answer": 1,
      "explanation": "Exprimer ses émotions à quelqu''un de confiance aide à les comprendre et à se sentir moins seul(e)."
    }
  ]'::jsonb
);

-- Quiz 11: L'automutilation
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Comprendre l''automutilation',
  'Apprends à reconnaître les signes et comment aider.',
  'sante_mentale',
  'difficile',
  8,
  ARRAY[1,2,3],
  '[
    {
      "question": "L''automutilation est:",
      "answers": [
        "Un moyen d''attirer l''attention",
        "Un signe de grande souffrance psychologique",
        "Une mode chez les jeunes",
        "Pas grave si c''est superficiel"
      ],
      "correct_answer": 1,
      "explanation": "L''automutilation est une façon de gérer une douleur émotionnelle intense. C''est un signe d''alarme à prendre au sérieux."
    },
    {
      "question": "Si tu découvres qu''un(e) ami(e) se fait du mal:",
      "answers": [
        "Tu gardes le secret pour respecter sa vie privée",
        "Tu le/la critiques pour qu''il/elle arrête",
        "Tu en parles à un adulte de confiance",
        "Tu ignores car c''est son choix"
      ],
      "correct_answer": 2,
      "explanation": "Il faut TOUJOURS alerter un adulte. L''automutilation peut s''aggraver et ton ami(e) a besoin d''aide professionnelle."
    },
    {
      "question": "L''automutilation se traite:",
      "answers": [
        "En faisant promettre d''arrêter",
        "Par la volonté seule",
        "Avec l''aide d''un professionnel de santé mentale",
        "Elle disparaît toute seule"
      ],
      "correct_answer": 2,
      "explanation": "L''automutilation nécessite un accompagnement professionnel (psychologue, psychiatre) pour traiter les causes profondes."
    }
  ]'::jsonb
);

-- Quiz 12: Le consentement
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Comprendre le consentement',
  'Apprends ce qu''est le consentement et pourquoi c''est important.',
  'harcelement',
  'moyen',
  6,
  ARRAY[1,2,3],
  '[
    {
      "question": "Le consentement, c''est:",
      "answers": [
        "Dire oui une fois et c''est valable pour toujours",
        "Un accord libre, éclairé et révocable à tout moment",
        "Pas nécessaire entre amis",
        "Juste pour les adultes"
      ],
      "correct_answer": 1,
      "explanation": "Le consentement doit être donné librement, de façon éclairée, et peut être retiré à tout moment."
    },
    {
      "question": "Si quelqu''un ne dit pas \"non\", ça veut dire:",
      "answers": [
        "C''est un oui",
        "On peut continuer",
        "Il faut demander clairement si c''est ok",
        "Ça ne compte pas"
      ],
      "correct_answer": 2,
      "explanation": "L''absence de \"non\" n''est PAS un \"oui\". Il faut toujours s''assurer d''avoir un consentement clair et enthousiaste."
    },
    {
      "question": "Partager une photo intime de quelqu''un sans son accord:",
      "answers": [
        "C''est ok si la photo est jolie",
        "Est un délit puni par la loi",
        "N''est pas grave entre amis",
        "Est normal à notre époque"
      ],
      "correct_answer": 1,
      "explanation": "Partager des images intimes sans consentement est un délit (revenge porn) passible de prison et d''amende."
    }
  ]'::jsonb
);

-- Quiz 13: La dépression chez les jeunes
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Reconnaître la dépression',
  'Apprends à identifier les signes de dépression chez toi ou tes amis.',
  'sante_mentale',
  'moyen',
  7,
  ARRAY[2,3,4],
  '[
    {
      "question": "La dépression, c''est:",
      "answers": [
        "Être triste de temps en temps",
        "Une maladie qui affecte l''humeur, l''énergie et le sommeil",
        "Un manque de volonté",
        "Juste du stress"
      ],
      "correct_answer": 1,
      "explanation": "La dépression est une vraie maladie qui affecte le corps et l''esprit. Elle se soigne avec de l''aide professionnelle."
    },
    {
      "question": "Les signes de dépression peuvent inclure:",
      "answers": [
        "Beaucoup d''énergie et d''enthousiasme",
        "Tristesse prolongée, perte d''intérêt, fatigue, isolement",
        "Envie de sortir tout le temps",
        "Appétit normal"
      ],
      "correct_answer": 1,
      "explanation": "La dépression se manifeste par une tristesse durable, un manque d''énergie, des troubles du sommeil et de l''appétit."
    },
    {
      "question": "La dépression chez les jeunes:",
      "answers": [
        "N''existe pas, c''est un truc d''adultes",
        "Passe toute seule avec le temps",
        "Existe et nécessite une prise en charge",
        "N''est pas sérieuse"
      ],
      "correct_answer": 2,
      "explanation": "La dépression peut toucher les jeunes et doit être prise au sérieux. Elle se soigne très bien si elle est traitée."
    }
  ]'::jsonb
);

-- Quiz 14: L'anxiété sociale
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Comprendre l''anxiété sociale',
  'Découvre ce qu''est l''anxiété sociale et comment la gérer.',
  'sante_mentale',
  'moyen',
  6,
  ARRAY[2,3,4],
  '[
    {
      "question": "L''anxiété sociale, c''est:",
      "answers": [
        "Être timide parfois",
        "Une peur intense des situations sociales",
        "Détester tout le monde",
        "Être asocial par choix"
      ],
      "correct_answer": 1,
      "explanation": "L''anxiété sociale est une peur intense et persistante d''être jugé ou humilié dans les situations sociales."
    },
    {
      "question": "L''anxiété sociale peut se manifester par:",
      "answers": [
        "De la joie en société",
        "Rougissements, tremblements, envie de fuir",
        "De l''agressivité",
        "Rien de particulier"
      ],
      "correct_answer": 1,
      "explanation": "L''anxiété sociale provoque des symptômes physiques (rougissements, sueurs, tremblements) et l''envie d''éviter les situations."
    },
    {
      "question": "Pour aider quelqu''un qui a de l''anxiété sociale:",
      "answers": [
        "Le forcer à aller dans des fêtes",
        "Se moquer pour le décoincer",
        "L''encourager doucement et respecter son rythme",
        "L''ignorer car ça passera"
      ],
      "correct_answer": 2,
      "explanation": "Il faut respecter le rythme de la personne et l''encourager gentiment. La forcer ne fait qu''empirer l''anxiété."
    }
  ]'::jsonb
);

-- Quiz 15: Les pensées suicidaires
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Parler des pensées suicidaires',
  'Apprends à réagir si quelqu''un parle de suicide.',
  'sante_mentale',
  'difficile',
  8,
  ARRAY[1,2,3],
  '[
    {
      "question": "Si quelqu''un te dit qu''il pense à se suicider:",
      "answers": [
        "C''est pour attirer l''attention, ignore",
        "Dis-lui que c''est égoïste",
        "Prends-le au sérieux et alerte un adulte",
        "Change de sujet"
      ],
      "correct_answer": 2,
      "explanation": "Il faut TOUJOURS prendre au sérieux quelqu''un qui parle de suicide et alerter immédiatement un adulte."
    },
    {
      "question": "Les pensées suicidaires:",
      "answers": [
        "Sont rares chez les jeunes",
        "Peuvent toucher n''importe qui en souffrance",
        "Ne concernent que les gens déprimés",
        "Sont définitives"
      ],
      "correct_answer": 1,
      "explanation": "Les pensées suicidaires peuvent toucher n''importe qui traversant une période difficile. Avec de l''aide, elles passent."
    },
    {
      "question": "Le numéro national de prévention du suicide en France:",
      "answers": [
        "Le 18",
        "Le 3114",
        "Le 15",
        "Le 112"
      ],
      "correct_answer": 1,
      "explanation": "Le 3114 est le numéro national de prévention du suicide, disponible 24h/24 et 7j/7."
    }
  ]'::jsonb
);

-- Quiz 16: Relations toxiques
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Reconnaître une relation toxique',
  'Apprends à identifier les signes d''une amitié ou relation malsaine.',
  'harcelement',
  'moyen',
  6,
  ARRAY[2,3,4],
  '[
    {
      "question": "Un(e) ami(e) toxique peut:",
      "answers": [
        "Te soutenir dans les moments difficiles",
        "Te rabaisser, te contrôler ou te manipuler",
        "Respecter tes limites",
        "Se réjouir de tes succès"
      ],
      "correct_answer": 1,
      "explanation": "Une personne toxique te rabaisse, te contrôle, te manipule ou te fait te sentir mal dans ta peau."
    },
    {
      "question": "Dans une relation saine:",
      "answers": [
        "On doit toujours être d''accord",
        "Une personne contrôle l''autre",
        "Il y a du respect mutuel et de la communication",
        "On peut insulter l''autre si on s''excuse après"
      ],
      "correct_answer": 2,
      "explanation": "Une relation saine repose sur le respect mutuel, la communication et l''acceptation des différences."
    },
    {
      "question": "Si tu es dans une relation toxique:",
      "answers": [
        "C''est de ta faute",
        "Tu dois changer pour plaire à l''autre",
        "Tu peux chercher de l''aide et t''en éloigner",
        "Tu ne peux rien faire"
      ],
      "correct_answer": 2,
      "explanation": "Ce n''est JAMAIS de ta faute. Tu mérites des relations respectueuses et tu peux demander de l''aide pour t''en sortir."
    }
  ]'::jsonb
);

-- Quiz 17: La confiance en soi
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Développer sa confiance en soi',
  'Découvre comment renforcer ta confiance en toi.',
  'estime',
  'facile',
  5,
  ARRAY[3,4,5],
  '[
    {
      "question": "La confiance en soi:",
      "answers": [
        "Est innée, on l''a ou on ne l''a pas",
        "Se développe et se travaille",
        "C''est être arrogant",
        "N''est pas importante"
      ],
      "correct_answer": 1,
      "explanation": "La confiance en soi se construit progressivement à travers les expériences et le travail sur soi."
    },
    {
      "question": "Pour développer ta confiance en toi, tu peux:",
      "answers": [
        "Te comparer sans cesse aux autres",
        "Te fixer des objectifs atteignables et les célébrer",
        "Éviter tout ce qui est difficile",
        "Ignorer tes réussites"
      ],
      "correct_answer": 1,
      "explanation": "Se fixer des petits objectifs et célébrer ses réussites aide à construire la confiance en soi."
    },
    {
      "question": "Échouer parfois:",
      "answers": [
        "Prouve que tu es nul(le)",
        "Fait partie de l''apprentissage",
        "Doit être caché",
        "N''arrive qu''aux perdants"
      ],
      "correct_answer": 1,
      "explanation": "L''échec fait partie de la vie et de l''apprentissage. Même les personnes qui réussissent ont échoué avant."
    }
  ]'::jsonb
);

-- Quiz 18: Dire non
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Apprendre à dire non',
  'Découvre pourquoi et comment dire non quand c''est nécessaire.',
  'estime',
  'facile',
  5,
  ARRAY[2,3,4],
  '[
    {
      "question": "Dire non à quelqu''un:",
      "answers": [
        "Est méchant et égoïste",
        "Est un droit que tu as",
        "N''est jamais acceptable",
        "Veut dire que tu ne l''aimes pas"
      ],
      "correct_answer": 1,
      "explanation": "Dire non est un droit fondamental. Tu n''as pas à faire quelque chose qui te met mal à l''aise."
    },
    {
      "question": "Si quelqu''un insiste après que tu aies dit non:",
      "answers": [
        "Tu dois céder pour être poli",
        "Tu as le droit de répéter ton non fermement",
        "C''est que tu n''as pas bien expliqué",
        "Tu dois t''excuser"
      ],
      "correct_answer": 1,
      "explanation": "Si quelqu''un ne respecte pas ton \"non\", tu peux le répéter fermement ou t''éloigner. Tu n''as pas à te justifier."
    },
    {
      "question": "Un vrai ami:",
      "answers": [
        "Te force à faire des choses",
        "Respecte quand tu dis non",
        "Se vexe si tu refuses",
        "Insiste jusqu''à ce que tu cèdes"
      ],
      "correct_answer": 1,
      "explanation": "Un vrai ami respecte tes limites et ne te force jamais à faire quelque chose contre ta volonté."
    }
  ]'::jsonb
);

-- Quiz 19: L'isolement social
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Sortir de l''isolement',
  'Comprends les dangers de l''isolement et comment en sortir.',
  'sante_mentale',
  'moyen',
  6,
  ARRAY[2,3,4],
  '[
    {
      "question": "L''isolement prolongé peut:",
      "answers": [
        "Être bénéfique pour la santé mentale",
        "Aggraver la tristesse et l''anxiété",
        "N''avoir aucun effet",
        "Rendre plus populaire"
      ],
      "correct_answer": 1,
      "explanation": "L''isolement prolongé peut aggraver les problèmes de santé mentale comme l''anxiété et la dépression."
    },
    {
      "question": "Si tu te sens isolé(e), tu peux:",
      "answers": [
        "Attendre que ça passe",
        "Rejoindre une activité ou en parler à quelqu''un",
        "T''isoler encore plus",
        "Te dire que c''est normal"
      ],
      "correct_answer": 1,
      "explanation": "Rejoindre une activité (sport, club, bénévolat) ou parler à quelqu''un peut aider à sortir de l''isolement."
    },
    {
      "question": "L''isolement peut être causé par:",
      "answers": [
        "Uniquement la timidité",
        "Le harcèlement, l''anxiété, un déménagement...",
        "Rien de particulier",
        "Le manque de téléphone"
      ],
      "correct_answer": 1,
      "explanation": "L''isolement peut avoir de nombreuses causes: harcèlement, anxiété sociale, déménagement, perte d''amis, etc."
    }
  ]'::jsonb
);

-- Quiz 20: Les numéros d'urgence et ressources
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Connaître les numéros d''aide',
  'Apprends les numéros importants quand tu as besoin d''aide.',
  'sante_mentale',
  'facile',
  5,
  ARRAY[1,2,3,4,5],
  '[
    {
      "question": "Le 3020 est le numéro pour:",
      "answers": [
        "Les urgences médicales",
        "Le harcèlement scolaire",
        "La police",
        "Les pompiers"
      ],
      "correct_answer": 1,
      "explanation": "Le 3020 est le numéro national contre le harcèlement à l''école. Il est gratuit et confidentiel."
    },
    {
      "question": "Le 3018 est dédié à:",
      "answers": [
        "Les violences familiales",
        "Le cyberharcèlement",
        "Les urgences psychiatriques",
        "La prévention routière"
      ],
      "correct_answer": 1,
      "explanation": "Le 3018 est le numéro national contre le cyberharcèlement (Net Écoute)."
    },
    {
      "question": "En cas de danger immédiat, tu appelles:",
      "answers": [
        "Le 3020",
        "Tes parents seulement",
        "Le 15, 17 ou 112",
        "Tu attends"
      ],
      "correct_answer": 2,
      "explanation": "En cas de danger immédiat: 15 (SAMU), 17 (Police), 18 (Pompiers) ou 112 (numéro d''urgence européen)."
    }
  ]'::jsonb
);

SELECT 'Les 20 quiz ont été insérés avec succès !' AS message;

-- =====================================================
-- ARTICLES ADDITIONNELS (15 articles avec liens)
-- =====================================================

-- Article 1: Le harcèlement scolaire
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Tout comprendre sur le harcèlement scolaire',
  E'# Tout comprendre sur le harcèlement scolaire\n\n## Qu''est-ce que le harcèlement scolaire?\n\nLe harcèlement scolaire, c''est quand un élève subit des violences répétées (physiques, verbales ou psychologiques) de la part d''un ou plusieurs autres élèves.\n\n## Les différentes formes\n\n### Harcèlement verbal\n- Insultes\n- Moqueries\n- Surnoms blessants\n- Menaces\n\n### Harcèlement physique\n- Bousculades\n- Coups\n- Vols\n- Dégradation d''affaires\n\n### Harcèlement social\n- Exclusion du groupe\n- Rumeurs\n- Rejet systématique\n\n### Cyberharcèlement\n- Messages haineux\n- Photos partagées sans consentement\n- Moqueries en ligne\n\n## Les signes d''alerte\n\n- Refus d''aller à l''école\n- Chute des résultats scolaires\n- Isolement\n- Troubles du sommeil ou de l''appétit\n- Affaires abîmées ou perdues\n\n## Que faire?\n\n1. **En parler** à un adulte de confiance\n2. **Garder des preuves** (captures d''écran)\n3. **Ne pas répondre** aux provocations\n4. **Appeler le 3020** - numéro gratuit\n\n## Ressources utiles\n\n- Site officiel: https://www.nonauharcelement.education.gouv.fr\n- 3020: Numéro national contre le harcèlement\n- 3018: Net Écoute (cyberharcèlement)',
  'Guide complet pour comprendre le harcèlement scolaire, ses formes et comment agir.',
  'harcelement',
  ARRAY[1,2,3],
  6,
  true
);

-- Article 2: Le cyberharcèlement
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Se protéger du cyberharcèlement',
  E'# Se protéger du cyberharcèlement\n\n## C''est quoi le cyberharcèlement?\n\nC''est du harcèlement qui utilise les outils numériques: réseaux sociaux, SMS, jeux en ligne, forums...\n\n## Exemples de cyberharcèlement\n\n- Recevoir des insultes ou menaces par message\n- Voir des rumeurs sur toi circuler en ligne\n- Des photos de toi partagées sans ton accord\n- Être exclu(e) de groupes en ligne\n- Usurpation d''identité\n\n## Comment te protéger?\n\n### Paramétrer tes comptes\n- Mets tes profils en privé\n- Choisis qui peut te contacter\n- Ne partage pas d''infos personnelles\n\n### En cas de cyberharcèlement\n\n1. **Ne réponds pas** - ça encourage le harceleur\n2. **Fais des captures d''écran** - garde les preuves\n3. **Bloque la personne**\n4. **Signale le contenu** sur la plateforme\n5. **Parle à un adulte**\n\n## C''est illégal!\n\nLe cyberharcèlement est puni par la loi:\n- Jusqu''à 2 ans de prison\n- 30 000€ d''amende\n\nPartager des photos intimes sans consentement (revenge porn) est aussi un délit.\n\n## Numéros utiles\n\n- **3018** - Net Écoute: https://www.e-enfance.org\n- **3020** - Non au harcèlement\n- **Pharos** pour signaler: https://www.internet-signalement.gouv.fr',
  'Guide pratique pour se protéger du cyberharcèlement et connaître ses droits.',
  'harcelement',
  ARRAY[1,2,3],
  5,
  true
);

-- Article 3: L'estime de soi
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Construire et renforcer son estime de soi',
  E'# Construire et renforcer son estime de soi\n\n## C''est quoi l''estime de soi?\n\nL''estime de soi, c''est la valeur que tu t''accordes. C''est t''aimer et te respecter avec tes qualités ET tes défauts.\n\n## Pourquoi c''est important?\n\nUne bonne estime de soi permet de:\n- Mieux gérer les échecs\n- Résister à la pression des autres\n- Oser prendre des initiatives\n- Avoir des relations saines\n\n## Les ennemis de l''estime de soi\n\n### La comparaison\nSe comparer aux autres (surtout sur les réseaux) nuit à l''estime de soi. Rappelle-toi: les gens ne montrent que le meilleur!\n\n### Le perfectionnisme\nVouloir être parfait est épuisant et irréaliste. Personne ne l''est!\n\n### Les critiques destructrices\nCertaines personnes peuvent te rabaisser. Leurs paroles ne définissent pas ta valeur.\n\n## Comment la renforcer?\n\n### 1. Reconnais tes qualités\nFais une liste de 5 choses que tu aimes chez toi.\n\n### 2. Célèbre tes réussites\nMême les petites! Tu as réussi un exercice? Bravo!\n\n### 3. Accepte tes erreurs\nElles font partie de l''apprentissage.\n\n### 4. Entoure-toi bien\nChoisis des personnes qui te valorisent.\n\n### 5. Prends soin de toi\nSport, sommeil, alimentation: ton corps mérite attention.\n\n## Rappelle-toi\n\nTu es unique et tu as de la valeur. Point.\n\n## Pour aller plus loin\n\n- Fil Santé Jeunes: https://www.filsantejeunes.com\n- Psycom: https://www.psycom.org',
  'Conseils pratiques pour développer et renforcer son estime de soi au quotidien.',
  'estime',
  ARRAY[3,4,5],
  5,
  true
);

-- Article 4: Le body shaming
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Stop au body shaming: aimer son corps',
  E'# Stop au body shaming: aimer son corps\n\n## C''est quoi le body shaming?\n\nLe body shaming, c''est critiquer, moquer ou humilier quelqu''un à cause de son apparence physique:\n- Son poids (trop gros, trop maigre)\n- Sa taille\n- Ses cheveux\n- Sa peau\n- N''importe quelle partie de son corps\n\n## Pourquoi ça fait mal?\n\nLes moqueries sur le physique peuvent causer:\n- Perte de confiance en soi\n- Troubles alimentaires\n- Dépression\n- Isolement social\n- Refus d''aller en cours de sport\n\n## Comment réagir?\n\n### Si tu en es victime\n\n1. **Ce n''est PAS de ta faute**\nTon corps est parfait comme il est.\n\n2. **Les critiques parlent de l''autre**\nQuelqu''un qui se moque de ton physique montre ses propres insécurités.\n\n3. **Parle à quelqu''un**\nUn adulte de confiance peut t''aider.\n\n4. **Entoure-toi de personnes bienveillantes**\n\n### Si tu es témoin\n\n- Ne ris pas avec les moqueurs\n- Soutiens la victime\n- Signale à un adulte\n\n## Chaque corps est unique\n\nLa beauté n''a pas qu''une seule forme. Les corps sur Instagram sont souvent retouchés. La vraie vie, c''est la diversité!\n\n## Ressources\n\n- Anorexie Boulimie Info Écoute: 0 810 037 037\n- Fil Santé Jeunes: https://www.filsantejeunes.com',
  'Comprendre le body shaming et apprendre à s''accepter tel qu''on est.',
  'estime',
  ARRAY[2,3,4],
  4,
  false
);

-- Article 5: Le post-partum
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Comprendre le post-partum et le baby blues',
  E'# Comprendre le post-partum et le baby blues\n\n## Qu''est-ce que le post-partum?\n\nLe post-partum, c''est la période qui suit l''accouchement. C''est une période de grands changements pour la nouvelle maman.\n\n## Le baby blues\n\n### C''est quoi?\n\nC''est une période de tristesse et d''émotivité qui touche 50 à 80% des nouvelles mamans dans les jours suivant l''accouchement.\n\n### Les causes\n\n- Chute hormonale brutale\n- Manque de sommeil extrême\n- Adaptation à un nouveau rôle\n- Fatigue physique après l''accouchement\n\n### Les symptômes\n\n- Pleurs fréquents\n- Irritabilité\n- Anxiété\n- Sentiment d''être dépassée\n- Troubles du sommeil\n\n### Durée\n\nLe baby blues dure généralement quelques jours à 2 semaines.\n\n## La dépression post-partum\n\nSi les symptômes persistent au-delà de 2 semaines ou s''aggravent, il peut s''agir d''une dépression post-partum qui nécessite une prise en charge médicale.\n\n### Symptômes d''alerte\n\n- Tristesse profonde persistante\n- Incapacité à s''occuper du bébé\n- Pensées noires\n- Culpabilité intense\n- Perte d''intérêt total\n\n## Comment aider?\n\n- Proposer une aide concrète (ménage, courses, garder le bébé)\n- Écouter sans juger\n- Encourager à consulter si ça dure\n- Ne pas minimiser sa souffrance\n\n## Ressources\n\n- Fil Santé Jeunes: https://www.filsantejeunes.com\n- Maman Blues: https://www.maman-blues.fr\n- SOS Post-partum: 0 800 00 60 60',
  'Tout savoir sur le post-partum, le baby blues et comment aider une nouvelle maman.',
  'famille',
  ARRAY[3,4,5],
  5,
  false
);

-- Article 6: Les numéros d'urgence
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Les numéros d''aide: qui appeler quand ça ne va pas?',
  E'# Les numéros d''aide: qui appeler quand ça ne va pas?\n\n## Urgences vitales\n\n### 15 - SAMU\nPour les urgences médicales.\n\n### 17 - Police/Gendarmerie\nEn cas de danger immédiat.\n\n### 18 - Pompiers\nIncendie, accident, secours.\n\n### 112 - Numéro d''urgence européen\nFonctionne partout en Europe.\n\n## Harcèlement\n\n### 3020 - Non au harcèlement\n- Gratuit et anonyme\n- Du lundi au vendredi de 9h à 20h\n- Samedi de 9h à 18h\n- Site: https://www.nonauharcelement.education.gouv.fr\n\n### 3018 - Net Écoute (cyberharcèlement)\n- Gratuit et anonyme\n- 7j/7 de 9h à 23h\n- Site: https://www.e-enfance.org\n\n## Santé mentale\n\n### 3114 - Numéro national de prévention du suicide\n- Gratuit et confidentiel\n- 24h/24, 7j/7\n- Site: https://www.3114.fr\n\n### Fil Santé Jeunes - 0 800 235 236\n- Gratuit et anonyme\n- Tous les jours de 9h à 23h\n- Site: https://www.filsantejeunes.com\n\n## Enfance en danger\n\n### 119 - Allô Enfance en Danger\n- Gratuit et anonyme\n- 24h/24, 7j/7\n- Site: https://www.allo119.gouv.fr\n\n## Violence\n\n### 3919 - Violences Femmes Info\n- Gratuit et anonyme\n- 24h/24, 7j/7\n\n## Rappel\n\nCes numéros sont là pour t''aider. N''hésite JAMAIS à appeler!',
  'Tous les numéros utiles à connaître quand tu as besoin d''aide.',
  'sante_mentale',
  ARRAY[1,2,3,4,5],
  4,
  true
);

-- Article 7: La discrimination
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Lutter contre les discriminations',
  E'# Lutter contre les discriminations\n\n## C''est quoi une discrimination?\n\nC''est traiter quelqu''un différemment (souvent moins bien) à cause de:\n- Son origine\n- Son apparence physique\n- Son nom de famille\n- Sa religion\n- Son sexe\n- Son orientation sexuelle\n- Un handicap\n- Sa situation sociale\n\n## Exemples au quotidien\n\n- Se moquer de l''accent de quelqu''un\n- Refuser de jouer avec quelqu''un à cause de ses vêtements\n- Exclure quelqu''un à cause de sa couleur de peau\n- Insulter quelqu''un sur son physique\n\n## C''est illégal!\n\nLa discrimination est interdite par la loi et peut être punie:\n- Jusqu''à 3 ans de prison\n- 45 000€ d''amende\n\n## Que faire si tu en es victime?\n\n1. **Parle-en** à un adulte de confiance\n2. **Garde des preuves** si possible\n3. **Signale** au Défenseur des droits\n\n## Et si tu es témoin?\n\n- Ne participe pas\n- Soutiens la victime\n- Signale à un adulte\n\n## La diversité est une richesse\n\nNos différences nous enrichissent. Un monde où tout le monde serait pareil serait bien ennuyeux!\n\n## Ressources\n\n- Défenseur des droits: https://www.defenseurdesdroits.fr\n- SOS Racisme: https://sos-racisme.org\n- 3020 - Harcèlement scolaire',
  'Comprendre les discriminations et savoir comment agir.',
  'harcelement',
  ARRAY[2,3,4],
  4,
  false
);

-- Article 8: La dépression chez les jeunes
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'La dépression: en parler pour s''en sortir',
  E'# La dépression: en parler pour s''en sortir\n\n## C''est quoi la dépression?\n\nLa dépression est une maladie (pas un manque de volonté!) qui affecte:\n- L''humeur\n- L''énergie\n- Le sommeil\n- L''appétit\n- La concentration\n\n## Les signes d''alerte\n\n### Émotionnels\n- Tristesse persistante (plus de 2 semaines)\n- Perte d''intérêt pour ce qu''on aimait\n- Sentiment de vide\n- Culpabilité excessive\n\n### Physiques\n- Fatigue intense\n- Troubles du sommeil\n- Changement d''appétit\n- Douleurs sans cause médicale\n\n### Comportementaux\n- Isolement\n- Baisse des résultats scolaires\n- Négligence de soi\n- Pensées sombres\n\n## Ce n''est PAS...\n\n- De la paresse\n- Un caprice\n- Une faiblesse\n- Quelque chose de honteux\n\n## Comment s''en sortir?\n\n### 1. En parler\nÀ un parent, un prof, l''infirmière scolaire, un ami...\n\n### 2. Consulter\nMédecin, psychologue, psychiatre - ils sont là pour aider!\n\n### 3. Les traitements\n- Thérapie (parler avec un professionnel)\n- Parfois des médicaments\n- Soutien de l''entourage\n\n## La dépression se soigne!\n\nAvec de l''aide, on en sort. Tu n''es pas seul(e).\n\n## Numéros utiles\n\n- 3114 - Prévention du suicide\n- Fil Santé Jeunes: 0 800 235 236\n- Site: https://www.psycom.org',
  'Comprendre la dépression et savoir qu''on peut s''en sortir avec de l''aide.',
  'sante_mentale',
  ARRAY[1,2,3],
  5,
  true
);

-- Article 9: Le consentement
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Tout savoir sur le consentement',
  E'# Tout savoir sur le consentement\n\n## C''est quoi le consentement?\n\nLe consentement, c''est donner son accord de façon libre et éclairée. Ça s''applique à plein de situations!\n\n## Les règles du consentement\n\n### 1. Libre\nPas de pression, de menace ou de manipulation.\n\n### 2. Éclairé\nTu sais exactement à quoi tu dis oui.\n\n### 3. Révocable\nTu peux changer d''avis à TOUT moment.\n\n### 4. Spécifique\nDire oui à une chose ne veut pas dire oui à tout.\n\n## Dans la vie quotidienne\n\n- Prendre quelqu''un en photo → demander son accord\n- Publier une photo de quelqu''un → demander son accord\n- Toucher quelqu''un → demander son accord\n- Emprunter les affaires de quelqu''un → demander son accord\n\n## L''absence de \"non\" n''est PAS un \"oui\"\n\nSi quelqu''un:\n- Ne dit rien\n- Est hésitant(e)\n- Est sous l''influence de l''alcool\n- A peur\n\n→ Ce n''est PAS un consentement!\n\n## Le droit à l''image\n\nTu as le droit de:\n- Refuser qu''on te prenne en photo\n- Demander la suppression d''une photo de toi\n- Signaler un contenu publié sans ton accord\n\n## C''est la loi!\n\nPartager des images intimes sans consentement = jusqu''à 2 ans de prison et 60 000€ d''amende.\n\n## Ressources\n\n- https://www.filsantejeunes.com\n- https://www.e-enfance.org',
  'Comprendre ce qu''est le consentement et pourquoi c''est essentiel.',
  'harcelement',
  ARRAY[1,2,3],
  4,
  false
);

-- Article 10: Gérer ses émotions
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Apprendre à gérer ses émotions',
  E'# Apprendre à gérer ses émotions\n\n## Les émotions, c''est quoi?\n\nLes émotions sont des réactions naturelles à ce qui nous arrive. Il n''y a pas d''émotions \"bonnes\" ou \"mauvaises\" - elles sont toutes utiles!\n\n## Les émotions de base\n\n- **Joie**: quelque chose de positif arrive\n- **Tristesse**: perte, déception\n- **Colère**: sentiment d''injustice\n- **Peur**: face à un danger\n- **Dégoût**: rejet de quelque chose\n- **Surprise**: face à l''inattendu\n\n## Pourquoi c''est difficile parfois?\n\nÀ l''adolescence, les émotions sont souvent plus intenses à cause des changements hormonaux. C''est normal!\n\n## Techniques pour gérer\n\n### 1. Identifier l''émotion\nNomme ce que tu ressens: \"Je suis en colère parce que...\"\n\n### 2. Respirer\nInspire 4 secondes, retiens 4 secondes, expire 4 secondes.\n\n### 3. Prendre du recul\nAttends avant de réagir. Compte jusqu''à 10.\n\n### 4. Exprimer\nParle de ce que tu ressens à quelqu''un de confiance.\n\n### 5. Bouger\nL''activité physique aide à évacuer les émotions fortes.\n\n### 6. Écrire\nUn journal peut aider à mettre des mots sur ce que tu ressens.\n\n## Ce qu''il ne faut PAS faire\n\n- Tout garder pour soi\n- Exploser sur les autres\n- Fuir dans les écrans ou substances\n\n## Rappelle-toi\n\nRessentir des émotions fortes est NORMAL. L''important est d''apprendre à les exprimer sainement.\n\n## Ressources\n\n- Fil Santé Jeunes: https://www.filsantejeunes.com\n- Application Petit Bambou (méditation)',
  'Des techniques simples pour mieux comprendre et gérer ses émotions.',
  'sante_mentale',
  ARRAY[2,3,4,5],
  5,
  false
);

-- Article 11: L'anxiété
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Comprendre et gérer l''anxiété',
  E'# Comprendre et gérer l''anxiété\n\n## C''est quoi l''anxiété?\n\nL''anxiété est une émotion normale face au stress ou à l''incertitude. Elle devient problématique quand elle est trop intense ou trop fréquente.\n\n## Anxiété normale vs trouble anxieux\n\n### Normal\n- Stress avant un examen\n- Nervosité avant une présentation\n- Inquiétude passagère\n\n### Trouble anxieux\n- Anxiété constante sans raison claire\n- Crises de panique\n- Évitement de situations\n- Impact sur la vie quotidienne\n\n## Les symptômes physiques\n\n- Cœur qui bat vite\n- Difficultés à respirer\n- Transpiration\n- Tremblements\n- Maux de ventre\n- Tensions musculaires\n\n## Techniques anti-anxiété\n\n### Respiration 4-7-8\n1. Inspire par le nez pendant 4 secondes\n2. Retiens pendant 7 secondes\n3. Expire par la bouche pendant 8 secondes\n\n### Ancrage 5-4-3-2-1\nIdentifie:\n- 5 choses que tu vois\n- 4 choses que tu touches\n- 3 choses que tu entends\n- 2 choses que tu sens\n- 1 chose que tu goûtes\n\n### Activité physique\nLe sport libère des endorphines qui calment l''anxiété.\n\n## Quand consulter?\n\nSi l''anxiété:\n- T''empêche de vivre normalement\n- Provoque des crises de panique\n- Dure depuis longtemps\n\n→ Parle-en à un médecin ou psychologue.\n\n## Ressources\n\n- Fil Santé Jeunes: 0 800 235 236\n- https://www.psycom.org',
  'Tout comprendre sur l''anxiété et les techniques pour la gérer.',
  'sante_mentale',
  ARRAY[2,3,4],
  5,
  false
);

-- Article 12: Être un bon ami
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Comment être un bon ami et soutenir quelqu''un qui souffre',
  E'# Comment être un bon ami et soutenir quelqu''un qui souffre\n\n## Reconnaître quand un ami ne va pas bien\n\n### Les signes\n- Changement d''humeur\n- Isolement\n- Messages inquiétants\n- Pleurs fréquents\n- Parle de \"disparaître\" ou de \"ne plus être là\"\n\n## Comment l''aider?\n\n### 1. Être présent\nParfois, juste être là suffit. Pas besoin de mots compliqués.\n\n### 2. Écouter sans juger\n- Laisse-le/la parler\n- Ne coupe pas la parole\n- Ne minimise pas (\"c''est pas si grave\")\n- Ne compare pas (\"moi aussi j''ai des problèmes\")\n\n### 3. Poser des questions\n\"Tu veux en parler?\"\n\"Comment je peux t''aider?\"\n\"Est-ce que tu as pensé à te faire du mal?\"\n\n### 4. Ne pas garder un secret dangereux\nSi ton ami parle de suicide ou de se faire du mal:\n→ Tu DOIS en parler à un adulte, même s''il te demande de garder le secret.\n\n### 5. Proposer des ressources\nParle-lui des numéros d''aide (3114, Fil Santé Jeunes...).\n\n## Ce qu''il ne faut PAS faire\n\n- Ignorer les signes\n- Promettre de garder un secret sur des pensées suicidaires\n- Essayer de tout résoudre seul(e)\n- Juger ou critiquer\n\n## Prendre soin de toi aussi\n\nSoutenir quelqu''un qui souffre peut être difficile. N''hésite pas à en parler toi aussi à un adulte.\n\n## Rappelle-toi\n\nTu n''es pas responsable de la souffrance de ton ami. Mais tu peux être une aide précieuse en l''écoutant et en alertant si nécessaire.',
  'Guide pour soutenir un ami qui traverse une période difficile.',
  'sante_mentale',
  ARRAY[2,3,4],
  4,
  false
);

-- Article 13: Les relations toxiques
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Reconnaître et sortir des relations toxiques',
  E'# Reconnaître et sortir des relations toxiques\n\n## C''est quoi une relation toxique?\n\nUne relation (amitié, couple, famille) où une personne te fait du mal régulièrement, que ce soit volontaire ou non.\n\n## Les signes d''alerte\n\n### Contrôle\n- Vérifie ton téléphone\n- Décide de tes fréquentations\n- Critique tes autres amis\n\n### Manipulation\n- Te fait culpabiliser\n- Retourne les situations contre toi\n- Souffle le chaud et le froid\n\n### Dévalorisation\n- Critiques constantes\n- Moqueries \"pour rire\"\n- Te fait douter de toi\n\n### Isolement\n- T''éloigne de tes proches\n- Veut être ta seule source de soutien\n\n## Comment te sens-tu dans cette relation?\n\n- Marcher sur des œufs?\n- Toujours fautif(ve)?\n- Épuisé(e) émotionnellement?\n- Moins confiant(e) qu''avant?\n\n→ Ce sont des signaux d''alarme.\n\n## Comment s''en sortir?\n\n### 1. Reconnaître le problème\nC''est la première étape, et elle est difficile.\n\n### 2. En parler\nÀ quelqu''un de confiance qui peut t''aider à y voir clair.\n\n### 3. Poser des limites\nDis clairement ce qui n''est pas acceptable.\n\n### 4. S''éloigner si nécessaire\nParfois, la seule solution est de couper les ponts.\n\n## Tu mérites mieux\n\nUne vraie relation (amitié ou amour) te fait te sentir bien, pas mal.\n\n## Ressources\n\n- Fil Santé Jeunes: https://www.filsantejeunes.com\n- 3919 - Violences Femmes Info',
  'Apprendre à identifier les relations toxiques et s''en protéger.',
  'harcelement',
  ARRAY[2,3,4],
  5,
  false
);

-- Article 14: Le sommeil et la santé mentale
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Bien dormir pour aller bien',
  E'# Bien dormir pour aller bien\n\n## Pourquoi le sommeil est important?\n\nLe sommeil affecte directement:\n- L''humeur\n- La concentration\n- La mémoire\n- La gestion des émotions\n- La santé physique\n\n## Combien d''heures dormir?\n\n- Ados (14-17 ans): 8-10 heures\n- Jeunes adultes (18-25 ans): 7-9 heures\n\n## Les ennemis du sommeil\n\n### Les écrans\nLa lumière bleue perturbe la production de mélatonine (hormone du sommeil).\n→ Éteins les écrans 1h avant de dormir.\n\n### La caféine\nLe café, thé, sodas peuvent rester dans le corps 6-8 heures.\n→ Évite après 16h.\n\n### Le stress\nL''anxiété empêche de s''endormir.\n→ Techniques de relaxation avant de dormir.\n\n## Conseils pour mieux dormir\n\n### Routine\n- Couche-toi et lève-toi à heures fixes\n- Crée un rituel avant le coucher\n\n### Environnement\n- Chambre fraîche (18-20°C)\n- Obscurité\n- Silence ou bruit blanc\n\n### Relaxation\n- Respiration profonde\n- Méditation\n- Lecture (pas sur écran)\n\n### Éviter\n- Les écrans au lit\n- Les repas trop lourds le soir\n- Le sport intense juste avant\n\n## Quand s''inquiéter?\n\nSi tu as:\n- Des insomnies régulières\n- Des cauchemars fréquents\n- Une fatigue constante malgré le sommeil\n\n→ Parle-en à un médecin.\n\n## Ressources\n\n- Institut National du Sommeil: https://www.institut-sommeil-vigilance.org',
  'L''importance du sommeil pour la santé mentale et comment mieux dormir.',
  'sante_mentale',
  ARRAY[3,4,5],
  4,
  false
);

-- Article 15: Se reconstruire après un harcèlement
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Se reconstruire après avoir été victime de harcèlement',
  E'# Se reconstruire après avoir été victime de harcèlement\n\n## C''est possible\n\nAprès un harcèlement, on peut se sentir brisé(e). Mais la guérison est possible, avec du temps et du soutien.\n\n## Ce que tu peux ressentir\n\n- Honte (à tort - tu n''es pas responsable!)\n- Colère\n- Tristesse\n- Méfiance envers les autres\n- Perte de confiance en soi\n- Anxiété sociale\n\nTous ces sentiments sont NORMAUX après ce que tu as vécu.\n\n## Les étapes de la reconstruction\n\n### 1. Reconnaître ce qui s''est passé\nTu as été victime. Ce n''était pas de ta faute.\n\n### 2. En parler\nÀ un adulte de confiance, un psy, un groupe de parole...\n\n### 3. Prendre soin de toi\n- Activités qui te font du bien\n- Sommeil, alimentation\n- Sport doux (yoga, marche)\n\n### 4. Reconstruire ta confiance\n- Petites victoires quotidiennes\n- Te rappeler tes qualités\n- T''entourer de personnes bienveillantes\n\n### 5. Avancer à ton rythme\nLa guérison n''est pas linéaire. Il y aura des hauts et des bas.\n\n## L''aide professionnelle\n\nUn psychologue ou psychiatre peut t''accompagner avec:\n- Une thérapie adaptée\n- Des techniques pour gérer l''anxiété\n- Un espace pour exprimer tes émotions\n\n## Tu n''es pas seul(e)\n\nBeaucoup de personnes ont vécu ce que tu vis et s''en sont sorties. Tu peux aussi.\n\n## Ressources\n\n- 3020 - Non au harcèlement\n- Fil Santé Jeunes: 0 800 235 236\n- https://www.psycom.org',
  'Guide pour se reconstruire et guérir après avoir subi du harcèlement.',
  'harcelement',
  ARRAY[1,2,3,4],
  6,
  true
);

SELECT 'Les 15 articles ont été insérés avec succès !' AS message;

-- =====================================================
-- CONTENU ADDITIONNEL: STRESS ET FAMILLE
-- =====================================================

-- =====================================================
-- SCENARIOS SUR LE STRESS (6 scénarios)
-- =====================================================

-- Scénario Stress 1: Stress des examens
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'La panique avant l''examen',
  'Tu as un contrôle important demain et tu te sens submergé(e) par le stress.',
  'stress',
  8,
  ARRAY[2,3,4],
  '{
    "start": {
      "text": "C''est la veille d''un contrôle de maths très important. Tu as révisé mais tu sens la panique monter. Ton cœur bat vite, tes mains tremblent. Que fais-tu?",
      "choices": [
        {"text": "Tu continues à réviser toute la nuit", "next": "all_night"},
        {"text": "Tu fais des exercices de respiration pour te calmer", "next": "breathing"},
        {"text": "Tu appelles un ami pour réviser ensemble", "next": "call_friend"},
        {"text": "Tu abandonnes et tu regardes des vidéos", "next": "give_up"}
      ]
    },
    "all_night": {
      "text": "Tu révises jusqu''à 3h du matin. Le lendemain, tu es épuisé(e) et tu as du mal à te concentrer...",
      "feedback": "La fatigue peut nuire à tes performances plus que le manque de révision.",
      "consequences": "Tu fais des erreurs d''inattention à cause du manque de sommeil.",
      "best_practice": "💡 Le sommeil est crucial pour la mémoire. Mieux vaut dormir suffisamment que réviser toute la nuit.",
      "choices": []
    },
    "breathing": {
      "text": "Tu fais des exercices de respiration: inspire 4 secondes, retiens 4 secondes, expire 4 secondes. Peu à peu, tu te calmes.",
      "feedback": "Excellent réflexe ! 🌟",
      "consequences": "Tu arrives à te détendre et tu passes une meilleure nuit. Tu es plus concentré(e) le lendemain.",
      "best_practice": "✅ La respiration est un outil puissant contre le stress. Utilise-le aussi avant l''examen !",
      "choices": []
    },
    "call_friend": {
      "text": "Tu appelles ton ami(e) et vous révisez les points difficiles ensemble au téléphone.",
      "feedback": "Bonne idée de ne pas rester seul(e) ! 💙",
      "consequences": "Vous vous encouragez mutuellement et tu te sens plus confiant(e).",
      "best_practice": "✅ S''entraider réduit le stress et renforce la compréhension.",
      "choices": []
    },
    "give_up": {
      "text": "Tu regardes des vidéos pendant 2 heures, mais la culpabilité augmente ton stress...",
      "feedback": "L''évitement aggrave souvent l''anxiété.",
      "consequences": "Tu te couches stressé(e) et tu dors mal.",
      "best_practice": "💡 Si tu as besoin d''une pause, choisis une activité relaxante courte, puis reviens à tes révisions.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario Stress 2: Surcharge d'activités
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Trop d''activités, plus de temps',
  'Entre l''école, le sport et les devoirs, tu n''arrives plus à suivre.',
  'stress',
  7,
  ARRAY[2,3,4],
  '{
    "start": {
      "text": "Tu as l''école, le foot le mercredi et samedi, la musique le vendredi, et beaucoup de devoirs. Tu te sens épuisé(e) et tu n''arrives plus à tout faire. Que fais-tu?",
      "choices": [
        {"text": "Tu continues à tout faire, même si tu es épuisé(e)", "next": "keep_going"},
        {"text": "Tu en parles à tes parents pour alléger ton emploi du temps", "next": "talk_parents"},
        {"text": "Tu arrêtes une activité sans en parler", "next": "quit_silently"},
        {"text": "Tu organises mieux ton temps avec un planning", "next": "make_plan"}
      ]
    },
    "keep_going": {
      "text": "Tu continues à courir partout. Mais après quelques semaines, tu tombes malade...",
      "feedback": "Ton corps t''envoie un signal d''alarme.",
      "consequences": "L''épuisement finit par te rattraper. Tu dois te reposer.",
      "best_practice": "💡 Écouter son corps est essentiel. Le surmenage peut avoir des conséquences sur ta santé.",
      "choices": []
    },
    "talk_parents": {
      "text": "Tu expliques à tes parents que tu te sens débordé(e). Ensemble, vous décidez d''alléger ton planning.",
      "feedback": "Excellente décision ! 🌟",
      "consequences": "Tu te sens soulagé(e) et tu retrouves du temps pour toi.",
      "best_practice": "✅ Communiquer sur ses limites est une force, pas une faiblesse.",
      "choices": []
    },
    "quit_silently": {
      "text": "Tu arrêtes d''aller au foot sans prévenir personne. Mais tes parents finissent par le découvrir...",
      "feedback": "L''évitement crée souvent plus de problèmes.",
      "consequences": "La situation devient conflictuelle avec tes parents.",
      "best_practice": "💡 Mieux vaut discuter ouvertement de tes difficultés que de fuir.",
      "choices": []
    },
    "make_plan": {
      "text": "Tu crées un planning avec des créneaux pour chaque activité et des moments de repos.",
      "feedback": "Bonne organisation ! 👏",
      "consequences": "Tu gères mieux ton temps et tu te sens moins stressé(e).",
      "best_practice": "✅ L''organisation aide à réduire le stress. N''oublie pas aussi de prévoir du temps libre !",
      "choices": []
    }
  }'::jsonb
);

-- Scénario Stress 3: Pression des résultats
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'La pression des notes',
  'Tes parents attendent de très bons résultats et tu as peur de les décevoir.',
  'stress',
  8,
  ARRAY[2,3,4],
  '{
    "start": {
      "text": "Tu viens d''avoir 12/20 à un contrôle. C''est une note correcte, mais tes parents s''attendent à ce que tu aies au moins 16. Tu as peur de leur montrer. Que fais-tu?",
      "choices": [
        {"text": "Tu caches la note et espères qu''ils ne la verront pas", "next": "hide_grade"},
        {"text": "Tu leur montres et leur expliques que tu as fait de ton mieux", "next": "be_honest"},
        {"text": "Tu leur demandes de l''aide pour progresser", "next": "ask_help"},
        {"text": "Tu te mets une pression énorme pour le prochain contrôle", "next": "pressure_self"}
      ]
    },
    "hide_grade": {
      "text": "Tu caches la note, mais l''école envoie un relevé aux parents...",
      "feedback": "Le secret finit souvent par être découvert.",
      "consequences": "Tes parents sont déçus par la note ET par le fait que tu l''aies cachée.",
      "best_practice": "💡 L''honnêteté, même difficile, construit la confiance avec tes parents.",
      "choices": []
    },
    "be_honest": {
      "text": "Tu montres ta note et tu expliques calmement ce qui a été difficile pour toi.",
      "feedback": "Courage et honnêteté ! 🌟",
      "consequences": "Tes parents comprennent et vous discutez ensemble de solutions.",
      "best_practice": "✅ La communication ouverte permet de trouver des solutions ensemble.",
      "choices": []
    },
    "ask_help": {
      "text": "Tu demandes à tes parents ou à un prof de t''aider à progresser dans cette matière.",
      "feedback": "Excellente démarche ! 💙",
      "consequences": "Tu reçois du soutien et tu progresses pour les prochains contrôles.",
      "best_practice": "✅ Demander de l''aide est un signe de maturité, pas de faiblesse.",
      "choices": []
    },
    "pressure_self": {
      "text": "Tu te mets une pression énorme, tu révises jour et nuit, et tu deviens anxieux(se)...",
      "feedback": "Trop de pression peut être contre-productif.",
      "consequences": "Tu es stressé(e) en permanence et tu as du mal à dormir.",
      "best_practice": "💡 Faire de son mieux ne veut pas dire se détruire. Parle de cette pression à quelqu''un.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario Stress 4: Conflit avec un ami
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Une dispute qui me stresse',
  'Tu t''es disputé(e) avec ton meilleur ami et ça te ronge.',
  'stress',
  7,
  ARRAY[2,3,4],
  '{
    "start": {
      "text": "Tu t''es disputé(e) avec ton/ta meilleur(e) ami(e) il y a 3 jours. Depuis, vous ne vous parlez plus et ça te stresse énormément. Tu y penses tout le temps. Que fais-tu?",
      "choices": [
        {"text": "Tu attends qu''il/elle fasse le premier pas", "next": "wait"},
        {"text": "Tu lui envoies un message pour discuter", "next": "reach_out"},
        {"text": "Tu en parles à quelqu''un de confiance", "next": "talk_someone"},
        {"text": "Tu essaies de l''ignorer et de passer à autre chose", "next": "ignore"}
      ]
    },
    "wait": {
      "text": "Les jours passent et aucun de vous deux ne fait le premier pas. Le malaise s''installe...",
      "feedback": "L''attente peut prolonger la souffrance.",
      "consequences": "La distance grandit et la réconciliation devient plus difficile.",
      "best_practice": "💡 Parfois, faire le premier pas demande du courage mais peut débloquer la situation.",
      "choices": []
    },
    "reach_out": {
      "text": "Tu lui envoies un message pour proposer de discuter calmement. Il/elle accepte.",
      "feedback": "Bravo pour ton courage ! 🌟",
      "consequences": "Vous vous expliquez et vous vous réconciliez.",
      "best_practice": "✅ La communication est la clé pour résoudre les conflits.",
      "choices": []
    },
    "talk_someone": {
      "text": "Tu en parles à un autre ami ou à un adulte qui t''aide à y voir plus clair.",
      "feedback": "Sage décision ! 💙",
      "consequences": "Tu comprends mieux la situation et tu te sens moins seul(e).",
      "best_practice": "✅ Avoir un regard extérieur aide souvent à prendre du recul.",
      "choices": []
    },
    "ignore": {
      "text": "Tu essaies de ne plus y penser, mais le stress reste présent...",
      "feedback": "Ignorer un problème ne le fait pas disparaître.",
      "consequences": "L''amitié se dégrade et tu restes stressé(e).",
      "best_practice": "💡 Les conflits non résolus créent du stress. Mieux vaut les affronter.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario Stress 5: Peur de parler en public
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'L''exposé devant la classe',
  'Tu dois faire un exposé oral et tu as très peur de parler devant tout le monde.',
  'stress',
  8,
  ARRAY[2,3,4],
  '{
    "start": {
      "text": "Dans 2 jours, tu dois présenter un exposé devant toute la classe. Rien que d''y penser, tu as des sueurs froides et l''estomac noué. Que fais-tu?",
      "choices": [
        {"text": "Tu te prépares à fond et tu répètes seul(e)", "next": "prepare_alone"},
        {"text": "Tu répètes devant ta famille ou un ami", "next": "practice_others"},
        {"text": "Tu demandes au prof si tu peux être dispensé(e)", "next": "ask_excuse"},
        {"text": "Tu te dis que tu improviseras le jour J", "next": "improvise"}
      ]
    },
    "prepare_alone": {
      "text": "Tu répètes ton exposé plusieurs fois dans ta chambre. Tu connais bien ton sujet.",
      "feedback": "La préparation réduit le stress ! 👏",
      "consequences": "Tu te sens plus confiant(e), même si le trac reste présent.",
      "best_practice": "✅ Bien préparer son contenu est la base. Essaie aussi de t''entraîner devant quelqu''un !",
      "choices": []
    },
    "practice_others": {
      "text": "Tu fais ton exposé devant ta famille. Ils te donnent des conseils et t''encouragent.",
      "feedback": "Excellente méthode ! 🌟",
      "consequences": "Tu t''habitues à parler devant d''autres et tu gagnes en confiance.",
      "best_practice": "✅ S''entraîner devant un public bienveillant est la meilleure préparation.",
      "choices": []
    },
    "ask_excuse": {
      "text": "Tu demandes au prof d''être dispensé(e), mais il refuse...",
      "feedback": "L''évitement n''est pas toujours possible.",
      "consequences": "Tu dois quand même faire l''exposé, mais sans préparation mentale.",
      "best_practice": "💡 Affronter ses peurs les fait diminuer avec le temps. Chaque exposé sera plus facile.",
      "choices": []
    },
    "improvise": {
      "text": "Le jour J, tu improvises mais tu perds tes mots et tu paniques...",
      "feedback": "Le manque de préparation augmente le stress.",
      "consequences": "L''exposé se passe mal et ta confiance en prend un coup.",
      "best_practice": "💡 La préparation est le meilleur remède contre le trac. Ne sous-estime pas son importance.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario Stress 6: Changement d'école
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Une nouvelle école',
  'Tu changes d''école et tu appréhendes cette nouvelle rentrée.',
  'stress',
  7,
  ARRAY[2,3,4],
  '{
    "start": {
      "text": "Ta famille a déménagé et tu dois changer d''école. C''est la rentrée demain et tu es mort(e) de stress à l''idée de ne connaître personne. Que fais-tu?",
      "choices": [
        {"text": "Tu te dis que ça va être nul et tu restes dans ton coin", "next": "stay_alone"},
        {"text": "Tu décides d''être ouvert(e) et de sourire aux autres", "next": "be_open"},
        {"text": "Tu en parles à tes parents de ton stress", "next": "talk_parents"},
        {"text": "Tu essaies de te connecter avec des élèves sur les réseaux avant la rentrée", "next": "connect_online"}
      ]
    },
    "stay_alone": {
      "text": "Tu restes dans ton coin et tu évites le contact. Les autres pensent que tu ne veux pas leur parler...",
      "feedback": "La peur peut nous isoler.",
      "consequences": "Tu as du mal à te faire des amis les premières semaines.",
      "best_practice": "💡 Même si c''est difficile, un petit sourire peut ouvrir des portes.",
      "choices": []
    },
    "be_open": {
      "text": "Tu fais l''effort de sourire et de te présenter. Quelqu''un vient te parler dès le premier jour !",
      "feedback": "Bravo pour ton courage ! 🌟",
      "consequences": "Tu commences à te faire des amis et la nouvelle école devient moins effrayante.",
      "best_practice": "✅ L''ouverture aux autres est la clé pour s''intégrer. Chaque petit pas compte.",
      "choices": []
    },
    "talk_parents": {
      "text": "Tu parles de ton stress à tes parents. Ils te rassurent et te donnent des conseils.",
      "feedback": "Bien de partager tes inquiétudes ! 💙",
      "consequences": "Tu te sens soutenu(e) et moins seul(e) face à ce changement.",
      "best_practice": "✅ Exprimer ses peurs aide à les diminuer. Tes parents peuvent t''aider.",
      "choices": []
    },
    "connect_online": {
      "text": "Tu trouves le compte Instagram de ta future classe et tu envoies un message. Quelqu''un te répond !",
      "feedback": "Initiative originale ! 👏",
      "consequences": "Tu as déjà un contact pour le premier jour, ce qui te rassure.",
      "best_practice": "✅ Préparer le terrain peut réduire l''anxiété. Attention à rester prudent(e) en ligne.",
      "choices": []
    }
  }'::jsonb
);

-- =====================================================
-- SCENARIOS SUR LA FAMILLE (6 scénarios)
-- =====================================================

-- Scénario Famille 1: Parents qui se disputent
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Quand mes parents se disputent',
  'Tes parents se disputent souvent et ça te fait de la peine.',
  'famille',
  8,
  ARRAY[2,3,4],
  '{
    "start": {
      "text": "Tes parents se disputent de plus en plus fort dans le salon. Tu es dans ta chambre et tu entends tout. Tu te sens triste et impuissant(e). Que fais-tu?",
      "choices": [
        {"text": "Tu essaies d''intervenir pour les calmer", "next": "intervene"},
        {"text": "Tu mets de la musique ou des écouteurs", "next": "headphones"},
        {"text": "Tu en parles à un adulte de confiance", "next": "talk_adult"},
        {"text": "Tu te sens responsable et tu penses que c''est de ta faute", "next": "blame_self"}
      ]
    },
    "intervene": {
      "text": "Tu descends et tu essaies de les calmer, mais ils te demandent de retourner dans ta chambre...",
      "feedback": "C''est courageux, mais ce n''est pas ton rôle de gérer leurs conflits.",
      "consequences": "Tu te sens encore plus impuissant(e).",
      "best_practice": "💡 Les conflits entre adultes ne sont pas ta responsabilité. Protège-toi d''abord.",
      "choices": []
    },
    "headphones": {
      "text": "Tu mets de la musique pour ne plus entendre. Ça t''aide à te calmer un peu.",
      "feedback": "C''est normal de vouloir te protéger ! 💙",
      "consequences": "Tu te sens un peu mieux sur le moment.",
      "best_practice": "✅ Se protéger est une réaction saine. Mais pense aussi à en parler à quelqu''un si ça dure.",
      "choices": []
    },
    "talk_adult": {
      "text": "Tu décides d''en parler à ta tante/ton oncle ou à l''infirmière scolaire.",
      "feedback": "Excellente idée ! 🌟",
      "consequences": "Tu te sens écouté(e) et moins seul(e) face à cette situation.",
      "best_practice": "✅ Parler à un adulte de confiance t''aide à ne pas porter ce poids seul(e).",
      "choices": []
    },
    "blame_self": {
      "text": "Tu penses que c''est peut-être de ta faute s''ils se disputent...",
      "feedback": "Ce n''est JAMAIS ta faute !",
      "consequences": "Tu te sens coupable pour quelque chose dont tu n''es pas responsable.",
      "best_practice": "💡 Les problèmes des adultes ne sont pas causés par les enfants. Tu n''y es pour rien.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario Famille 2: Divorce des parents
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Mes parents divorcent',
  'Tes parents t''annoncent qu''ils vont se séparer.',
  'famille',
  9,
  ARRAY[1,2,3],
  '{
    "start": {
      "text": "Tes parents viennent de t''annoncer qu''ils vont divorcer. Tu es sous le choc, tu ressens de la tristesse et de la colère mélangées. Que fais-tu?",
      "choices": [
        {"text": "Tu t''enfermes dans ta chambre et tu refuses de leur parler", "next": "isolate"},
        {"text": "Tu leur poses des questions sur ce qui va changer", "next": "ask_questions"},
        {"text": "Tu pleures et tu leur dis ce que tu ressens", "next": "express_feelings"},
        {"text": "Tu essaies de les convaincre de rester ensemble", "next": "convince"}
      ]
    },
    "isolate": {
      "text": "Tu t''enfermes et tu refuses de parler. La colère et la tristesse s''accumulent...",
      "feedback": "C''est normal d''avoir besoin de temps, mais ne reste pas seul(e) trop longtemps.",
      "consequences": "Tu te sens de plus en plus mal sans pouvoir l''exprimer.",
      "best_practice": "💡 Prendre du temps pour soi est OK, mais exprimer ses émotions aide à aller mieux.",
      "choices": []
    },
    "ask_questions": {
      "text": "Tu leur demandes comment ça va se passer: où tu vas vivre, l''école, etc.",
      "feedback": "Questions importantes ! 👏",
      "consequences": "Tu comprends mieux la situation et tu te sens un peu moins perdu(e).",
      "best_practice": "✅ Poser des questions aide à réduire l''anxiété de l''inconnu.",
      "choices": []
    },
    "express_feelings": {
      "text": "Tu pleures et tu leur dis que tu es triste et en colère. Ils t''écoutent et te prennent dans leurs bras.",
      "feedback": "Exprimer ses émotions est courageux ! 🌟",
      "consequences": "Tu te sens un peu soulagé(e) d''avoir pu dire ce que tu ressentais.",
      "best_practice": "✅ Toutes tes émotions sont valides. Les exprimer t''aide à les traverser.",
      "choices": []
    },
    "convince": {
      "text": "Tu essaies de les convaincre de rester ensemble, mais leur décision est prise...",
      "feedback": "C''est normal de vouloir garder ta famille unie.",
      "consequences": "Tu réalises que tu ne peux pas changer leur décision.",
      "best_practice": "💡 Le divorce est une décision d''adultes. Ce n''est pas quelque chose que tu peux ou dois contrôler.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario Famille 3: Jalousie envers un frère/soeur
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Mon frère/ma soeur a toute l''attention',
  'Tu as l''impression que tes parents préfèrent ton frère ou ta soeur.',
  'famille',
  7,
  ARRAY[2,3,4],
  '{
    "start": {
      "text": "Ton petit frère vient de réussir son spectacle de fin d''année. Tes parents sont super fiers et ne parlent que de lui. Toi, tu as eu 15/20 à ton contrôle et personne n''en a parlé. Tu te sens invisible. Que fais-tu?",
      "choices": [
        {"text": "Tu fais une remarque méchante à ton frère", "next": "mean_comment"},
        {"text": "Tu en parles calmement à tes parents", "next": "talk_parents"},
        {"text": "Tu gardes ta frustration pour toi", "next": "keep_inside"},
        {"text": "Tu te dis que tu dois faire encore mieux pour être remarqué(e)", "next": "do_better"}
      ]
    },
    "mean_comment": {
      "text": "Tu fais une remarque blessante à ton frère. Il pleure et tes parents te grondent...",
      "feedback": "La jalousie peut nous faire dire des choses qu''on regrette.",
      "consequences": "L''ambiance est tendue et tu te sens encore plus mal.",
      "best_practice": "💡 Ton frère n''est pas responsable. C''est avec tes parents qu''il faut communiquer.",
      "choices": []
    },
    "talk_parents": {
      "text": "Tu dis calmement à tes parents que tu aimerais aussi qu''ils remarquent tes efforts.",
      "feedback": "Excellente communication ! 🌟",
      "consequences": "Tes parents réalisent et te félicitent pour ta note. Ils promettent de faire plus attention.",
      "best_practice": "✅ Exprimer ses besoins de façon calme est la meilleure approche.",
      "choices": []
    },
    "keep_inside": {
      "text": "Tu ne dis rien et tu gardes ta frustration. Mais elle s''accumule...",
      "feedback": "Garder ses émotions peut faire mal à long terme.",
      "consequences": "Tu deviens de plus en plus irritable sans que personne ne comprenne pourquoi.",
      "best_practice": "💡 Les émotions non exprimées finissent par ressortir d''une façon ou d''une autre.",
      "choices": []
    },
    "do_better": {
      "text": "Tu te mets une pression énorme pour exceller dans tout...",
      "feedback": "Tu n''as pas à prouver ta valeur pour être aimé(e).",
      "consequences": "Tu t''épuises à chercher une reconnaissance qui ne vient pas comme tu l''espères.",
      "best_practice": "💡 L''amour de tes parents ne devrait pas dépendre de tes performances. Parle-leur de ce que tu ressens.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario Famille 4: Parent malade
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Mon parent est malade',
  'Un de tes parents est malade et tu t''inquiètes beaucoup.',
  'famille',
  8,
  ARRAY[1,2,3],
  '{
    "start": {
      "text": "Ta mère/ton père est malade depuis plusieurs semaines. Tu vois qu''il/elle est fatigué(e) et tu t''inquiètes beaucoup. Ça t''empêche de te concentrer à l''école. Que fais-tu?",
      "choices": [
        {"text": "Tu ne poses pas de questions pour ne pas l''inquiéter", "next": "stay_silent"},
        {"text": "Tu lui demandes comment il/elle va vraiment", "next": "ask_how"},
        {"text": "Tu en parles à l''infirmière scolaire", "next": "talk_nurse"},
        {"text": "Tu essaies de tout faire à la maison pour l''aider", "next": "help_everything"}
      ]
    },
    "stay_silent": {
      "text": "Tu ne poses pas de questions, mais ton imagination te fait penser au pire...",
      "feedback": "Le silence peut augmenter l''anxiété.",
      "consequences": "Tu t''inquiètes de plus en plus sans avoir de vraies informations.",
      "best_practice": "💡 Poser des questions adaptées à ton âge peut t''aider à moins t''inquiéter.",
      "choices": []
    },
    "ask_how": {
      "text": "Tu demandes à ton parent comment il/elle va. Il/elle te rassure et t''explique la situation.",
      "feedback": "Bonne démarche ! 💙",
      "consequences": "Tu comprends mieux et tu te sens un peu rassuré(e).",
      "best_practice": "✅ Savoir ce qui se passe vraiment aide souvent à moins s''inquiéter.",
      "choices": []
    },
    "talk_nurse": {
      "text": "Tu en parles à l''infirmière scolaire qui t''écoute et te donne des conseils.",
      "feedback": "Excellente idée ! 🌟",
      "consequences": "Tu te sens soutenu(e) et moins seul(e) avec ton inquiétude.",
      "best_practice": "✅ Les adultes de l''école peuvent t''aider quand ça ne va pas à la maison.",
      "choices": []
    },
    "help_everything": {
      "text": "Tu essaies de tout faire: ménage, courses, devoirs... Tu t''épuises.",
      "feedback": "C''est généreux, mais attention à toi !",
      "consequences": "Tu t''épuises et tu négliges ta propre vie.",
      "best_practice": "💡 Aider c''est bien, mais tu restes un enfant/ado. Ce n''est pas ton rôle de tout porter.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario Famille 5: Nouvelle famille recomposée
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Le nouveau compagnon de maman/papa',
  'Ton parent s''est remis en couple et tu as du mal à accepter cette nouvelle personne.',
  'famille',
  8,
  ARRAY[2,3,4],
  '{
    "start": {
      "text": "Ta mère/ton père te présente son nouveau compagnon/sa nouvelle compagne. Cette personne va venir vivre avec vous. Tu ressens de la colère et de la tristesse. Que fais-tu?",
      "choices": [
        {"text": "Tu refuses de lui parler et tu l''ignores", "next": "ignore"},
        {"text": "Tu dis à ton parent que tu n''es pas prêt(e)", "next": "not_ready"},
        {"text": "Tu fais un effort pour apprendre à le/la connaître", "next": "make_effort"},
        {"text": "Tu espères que cette relation ne durera pas", "next": "hope_breakup"}
      ]
    },
    "ignore": {
      "text": "Tu ignores cette personne. L''atmosphère à la maison devient tendue...",
      "feedback": "Ta réaction est compréhensible, mais elle crée des tensions.",
      "consequences": "Tout le monde se sent mal à l''aise et la situation ne s''améliore pas.",
      "best_practice": "💡 Exprimer ce que tu ressens est plus constructif que l''ignorance.",
      "choices": []
    },
    "not_ready": {
      "text": "Tu dis à ton parent que tu as besoin de temps pour accepter ce changement.",
      "feedback": "Excellente communication ! 🌟",
      "consequences": "Ton parent comprend et vous trouvez un rythme qui te convient mieux.",
      "best_practice": "✅ Exprimer ses besoins permet de trouver des solutions ensemble.",
      "choices": []
    },
    "make_effort": {
      "text": "Tu fais un effort pour discuter avec cette personne et découvrir qui elle est.",
      "feedback": "C''est courageux et mature ! 💙",
      "consequences": "Petit à petit, tu découvres des points communs et la relation s''améliore.",
      "best_practice": "✅ Donner une chance à quelqu''un ne veut pas dire trahir ton autre parent.",
      "choices": []
    },
    "hope_breakup": {
      "text": "Tu espères secrètement qu''ils vont se séparer...",
      "feedback": "Ce sentiment est normal, mais ça ne t''aide pas à aller mieux.",
      "consequences": "Tu restes dans l''attente au lieu de t''adapter à la nouvelle situation.",
      "best_practice": "💡 Accepter le changement prend du temps. Parle de ce que tu ressens à quelqu''un.",
      "choices": []
    }
  }'::jsonb
);

-- Scénario Famille 6: Communication difficile avec les parents
INSERT INTO scenarios (id, title, description, theme, duration_minutes, mood_tags, steps) VALUES
(
  uuid_generate_v4(),
  'Mes parents ne me comprennent pas',
  'Tu as l''impression que tes parents ne comprennent rien à ta vie.',
  'famille',
  7,
  ARRAY[2,3,4],
  '{
    "start": {
      "text": "Tu veux aller à une fête chez un ami ce week-end, mais tes parents refusent. Tu trouves ça injuste et tu as l''impression qu''ils ne comprennent rien à ta vie. Que fais-tu?",
      "choices": [
        {"text": "Tu cries et tu claques la porte de ta chambre", "next": "slam_door"},
        {"text": "Tu leur demandes calmement pourquoi ils refusent", "next": "ask_why"},
        {"text": "Tu proposes un compromis", "next": "compromise"},
        {"text": "Tu décides d''y aller quand même en cachette", "next": "sneak_out"}
      ]
    },
    "slam_door": {
      "text": "Tu claques la porte. Tes parents sont encore plus fermés à la discussion...",
      "feedback": "La colère ne fait pas avancer les choses.",
      "consequences": "La punition risque d''être encore plus stricte.",
      "best_practice": "💡 Quand tu es en colère, prends quelques minutes pour te calmer avant de discuter.",
      "choices": []
    },
    "ask_why": {
      "text": "Tu leur demandes calmement leurs raisons. Ils t''expliquent leurs inquiétudes.",
      "feedback": "Bonne approche ! 💙",
      "consequences": "Tu comprends mieux leur point de vue, même si tu n''es pas d''accord.",
      "best_practice": "✅ Comprendre les raisons de l''autre est la première étape pour négocier.",
      "choices": []
    },
    "compromise": {
      "text": "Tu proposes de rentrer plus tôt ou que tes parents viennent te chercher.",
      "feedback": "Excellente négociation ! 🌟",
      "consequences": "Tes parents acceptent le compromis et tu peux aller à la fête.",
      "best_practice": "✅ Le compromis montre ta maturité et aide à gagner la confiance de tes parents.",
      "choices": []
    },
    "sneak_out": {
      "text": "Tu y vas en cachette, mais tes parents découvrent la vérité...",
      "feedback": "Le mensonge détruit la confiance.",
      "consequences": "Tu es puni(e) plus sévèrement et tes parents ont encore moins confiance en toi.",
      "best_practice": "💡 La confiance se construit lentement mais se détruit vite. Le jeu n''en vaut pas la chandelle.",
      "choices": []
    }
  }'::jsonb
);

SELECT 'Les 12 scénarios stress et famille ont été insérés avec succès !' AS message;

-- =====================================================
-- QUIZZES SUR LE STRESS (6 quizzes)
-- =====================================================

-- Quiz Stress 1: Comprendre le stress
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Qu''est-ce que le stress?',
  'Apprends à reconnaître et comprendre le stress.',
  'stress',
  'facile',
  5,
  ARRAY[2,3,4],
  '[
    {
      "question": "Le stress est:",
      "answers": [
        "Toujours mauvais pour la santé",
        "Une réaction normale du corps face à un défi",
        "Une maladie contagieuse",
        "Quelque chose qui n''existe pas vraiment"
      ],
      "correct_answer": 1,
      "explanation": "Le stress est une réaction naturelle du corps. Un peu de stress peut même être motivant, mais trop de stress peut être néfaste."
    },
    {
      "question": "Parmi ces symptômes, lequel N''EST PAS un signe de stress?",
      "answers": [
        "Maux de tête",
        "Difficultés à dormir",
        "Cheveux qui poussent plus vite",
        "Maux de ventre"
      ],
      "correct_answer": 2,
      "explanation": "Les cheveux qui poussent plus vite n''est pas un signe de stress. Par contre, les maux de tête, troubles du sommeil et maux de ventre sont des symptômes courants."
    },
    {
      "question": "Quelle technique aide à réduire le stress rapidement?",
      "answers": [
        "Regarder son téléphone sans arrêt",
        "Boire beaucoup de café",
        "Faire des exercices de respiration",
        "Ignorer le problème"
      ],
      "correct_answer": 2,
      "explanation": "Les exercices de respiration activent le système parasympathique et aident à calmer le corps rapidement."
    }
  ]'::jsonb
);

-- Quiz Stress 2: Gérer le stress des examens
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Le stress des examens',
  'Comment gérer la pression des examens et contrôles.',
  'stress',
  'moyen',
  6,
  ARRAY[2,3,4],
  '[
    {
      "question": "La meilleure façon de se préparer pour un examen est:",
      "answers": [
        "Réviser toute la nuit avant l''examen",
        "Réviser régulièrement et dormir suffisamment",
        "Ne pas réviser pour éviter le stress",
        "Copier sur son voisin"
      ],
      "correct_answer": 1,
      "explanation": "Des révisions régulières et un bon sommeil sont la clé. Le cerveau a besoin de repos pour consolider les apprentissages."
    },
    {
      "question": "Pendant un examen, si tu sens la panique monter, tu devrais:",
      "answers": [
        "Rendre ta copie immédiatement",
        "Regarder la copie du voisin",
        "Prendre quelques respirations profondes",
        "Te lever et partir"
      ],
      "correct_answer": 2,
      "explanation": "Quelques respirations profondes peuvent calmer le système nerveux et t''aider à retrouver ta concentration."
    },
    {
      "question": "Le trac avant un examen:",
      "answers": [
        "Signifie que tu vas échouer",
        "Est anormal et inquiétant",
        "Est normal et peut même améliorer ta concentration",
        "Doit être combattu avec des médicaments"
      ],
      "correct_answer": 2,
      "explanation": "Un peu de trac est normal et peut même t''aider à être plus alerte. C''est quand il devient paralysant qu''il faut agir."
    }
  ]'::jsonb
);

-- Quiz Stress 3: Les techniques anti-stress
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Techniques anti-stress',
  'Découvre des méthodes efficaces pour gérer ton stress au quotidien.',
  'stress',
  'moyen',
  6,
  ARRAY[2,3,4],
  '[
    {
      "question": "La technique de respiration 4-7-8 consiste à:",
      "answers": [
        "Inspirer 4 fois, expirer 7 fois, retenir 8 fois",
        "Inspirer 4 secondes, retenir 7 secondes, expirer 8 secondes",
        "Respirer 4 minutes, 7 fois par jour, 8 jours de suite",
        "Courir 4 km en 7 minutes 8 secondes"
      ],
      "correct_answer": 1,
      "explanation": "La technique 4-7-8: inspire 4 secondes, retiens 7 secondes, expire 8 secondes. Elle active le système parasympathique."
    },
    {
      "question": "L''activité physique aide à réduire le stress parce que:",
      "answers": [
        "Elle fatigue tellement qu''on oublie ses problèmes",
        "Elle libère des endorphines, les hormones du bien-être",
        "Elle n''aide pas vraiment contre le stress",
        "Elle empêche de penser"
      ],
      "correct_answer": 1,
      "explanation": "Le sport libère des endorphines qui procurent une sensation de bien-être et réduisent le cortisol (hormone du stress)."
    },
    {
      "question": "Écrire dans un journal peut aider contre le stress car:",
      "answers": [
        "Ça fait perdre du temps",
        "Ça permet d''extérioriser ses pensées et émotions",
        "Ça n''a aucun effet prouvé",
        "Ça fatigue la main"
      ],
      "correct_answer": 1,
      "explanation": "Écrire aide à clarifier ses pensées, prendre du recul et libérer les émotions négatives."
    }
  ]'::jsonb
);

-- Quiz Stress 4: Le stress et le corps
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Le stress et ton corps',
  'Comprends comment le stress affecte ton corps.',
  'stress',
  'moyen',
  6,
  ARRAY[2,3,4],
  '[
    {
      "question": "Quand tu es stressé(e), ton corps produit:",
      "answers": [
        "Du sucre",
        "Du cortisol et de l''adrénaline",
        "De la mélatonine",
        "Des vitamines"
      ],
      "correct_answer": 1,
      "explanation": "Le stress déclenche la production de cortisol et d''adrénaline, des hormones qui préparent le corps à réagir."
    },
    {
      "question": "Le stress chronique peut causer:",
      "answers": [
        "Une meilleure mémoire",
        "Des problèmes de sommeil, maux de tête, problèmes digestifs",
        "Une croissance plus rapide",
        "Rien du tout"
      ],
      "correct_answer": 1,
      "explanation": "Le stress prolongé peut affecter le sommeil, causer des maux de tête, des problèmes digestifs et affaiblir le système immunitaire."
    },
    {
      "question": "Quand tu es stressé(e), ton cœur bat plus vite parce que:",
      "answers": [
        "Tu as mangé trop de sucre",
        "Ton corps se prépare à fuir ou combattre",
        "C''est un signe de maladie cardiaque",
        "C''est ton imagination"
      ],
      "correct_answer": 1,
      "explanation": "C''est la réaction \"fight or flight\" (combattre ou fuir): le corps se prépare à réagir face à un danger perçu."
    }
  ]'::jsonb
);

-- Quiz Stress 5: Stress et sommeil
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Stress et sommeil',
  'Comprends le lien entre stress et qualité du sommeil.',
  'stress',
  'moyen',
  5,
  ARRAY[2,3,4],
  '[
    {
      "question": "Le manque de sommeil:",
      "answers": [
        "N''a aucun effet sur le stress",
        "Réduit le stress",
        "Augmente la sensibilité au stress",
        "Est bon pour la concentration"
      ],
      "correct_answer": 2,
      "explanation": "Le manque de sommeil diminue notre capacité à gérer le stress et augmente l''irritabilité."
    },
    {
      "question": "Pour bien dormir quand on est stressé, il vaut mieux:",
      "answers": [
        "Regarder son téléphone au lit",
        "Boire du café le soir",
        "Créer une routine de coucher relaxante",
        "Réviser jusqu''à minuit"
      ],
      "correct_answer": 2,
      "explanation": "Une routine relaxante (pas d''écrans, lecture, respiration) aide le cerveau à se préparer au sommeil."
    },
    {
      "question": "Combien d''heures de sommeil un ado devrait-il avoir?",
      "answers": [
        "5-6 heures",
        "8-10 heures",
        "12-14 heures",
        "Le sommeil n''est pas important"
      ],
      "correct_answer": 1,
      "explanation": "Les adolescents ont besoin de 8 à 10 heures de sommeil pour être en forme et bien gérer le stress."
    }
  ]'::jsonb
);

-- Quiz Stress 6: Identifier ses sources de stress
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'D''où vient ton stress?',
  'Apprends à identifier les sources de ton stress.',
  'stress',
  'facile',
  5,
  ARRAY[2,3,4],
  '[
    {
      "question": "Quelle est la première étape pour gérer son stress?",
      "answers": [
        "Prendre des médicaments",
        "Identifier ce qui nous stresse",
        "Ignorer le problème",
        "En parler sur les réseaux sociaux"
      ],
      "correct_answer": 1,
      "explanation": "Pour gérer efficacement son stress, il faut d''abord identifier ce qui le cause."
    },
    {
      "question": "Parmi ces situations, laquelle est une source de stress courante chez les ados?",
      "answers": [
        "Seulement les examens",
        "Les examens, relations sociales, changements corporels, pression familiale",
        "Rien ne stresse vraiment les ados",
        "Uniquement les problèmes d''argent"
      ],
      "correct_answer": 1,
      "explanation": "Les ados peuvent être stressés par de nombreuses sources: école, amis, famille, corps qui change, avenir..."
    },
    {
      "question": "Face à une source de stress que tu ne peux pas changer, tu devrais:",
      "answers": [
        "Paniquer",
        "Apprendre à l''accepter et te concentrer sur ce que tu peux contrôler",
        "Te mettre en colère",
        "Abandonner tout effort"
      ],
      "correct_answer": 1,
      "explanation": "Certaines choses ne peuvent pas être changées. Se concentrer sur ce qu''on peut contrôler aide à réduire le stress."
    }
  ]'::jsonb
);

SELECT 'Les 6 quizzes stress ont été insérés avec succès !' AS message;

-- =====================================================
-- QUIZZES SUR LA FAMILLE (6 quizzes)
-- =====================================================

-- Quiz Famille 1: Les conflits familiaux
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Les conflits en famille',
  'Comprendre et gérer les disputes familiales.',
  'famille',
  'moyen',
  6,
  ARRAY[2,3,4],
  '[
    {
      "question": "Quand tes parents se disputent, tu devrais:",
      "answers": [
        "Intervenir pour les séparer",
        "Te sentir responsable et coupable",
        "Comprendre que ce n''est pas ta faute et te protéger",
        "Prendre le parti de l''un contre l''autre"
      ],
      "correct_answer": 2,
      "explanation": "Les conflits entre adultes ne sont pas de ta responsabilité. Tu peux te retirer et en parler à un adulte de confiance."
    },
    {
      "question": "La meilleure façon de régler un désaccord avec tes parents est:",
      "answers": [
        "Crier plus fort qu''eux",
        "Claquer la porte et bouder",
        "Discuter calmement quand tout le monde s''est calmé",
        "Ne plus leur parler pendant une semaine"
      ],
      "correct_answer": 2,
      "explanation": "Une discussion calme, après que les émotions se sont apaisées, est plus productive."
    },
    {
      "question": "Si tu te sens injustement traité(e) par rapport à ton frère/ta soeur:",
      "answers": [
        "Tu te venges sur lui/elle",
        "Tu en parles calmement à tes parents",
        "Tu gardes ta rancœur pour toujours",
        "Tu fugues de la maison"
      ],
      "correct_answer": 1,
      "explanation": "Exprimer calmement ce que tu ressens à tes parents permet de résoudre les malentendus."
    }
  ]'::jsonb
);

-- Quiz Famille 2: Le divorce des parents
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Quand les parents se séparent',
  'Comprendre et traverser le divorce de ses parents.',
  'famille',
  'moyen',
  7,
  ARRAY[1,2,3],
  '[
    {
      "question": "Le divorce des parents est:",
      "answers": [
        "Toujours de la faute des enfants",
        "Une décision d''adultes qui ne dépend pas des enfants",
        "Quelque chose que les enfants peuvent empêcher",
        "Une punition pour les enfants"
      ],
      "correct_answer": 1,
      "explanation": "Le divorce est une décision entre adultes. Les enfants n''en sont JAMAIS responsables."
    },
    {
      "question": "Après un divorce, il est normal de ressentir:",
      "answers": [
        "Uniquement de la joie",
        "Rien du tout",
        "De la tristesse, de la colère, de la confusion - plusieurs émotions",
        "De la honte"
      ],
      "correct_answer": 2,
      "explanation": "Toutes les émotions sont normales face à un divorce: tristesse, colère, soulagement parfois, confusion..."
    },
    {
      "question": "Face au divorce de tes parents, tu peux:",
      "answers": [
        "Choisir ton parent préféré et ignorer l''autre",
        "Servir de messager entre tes parents",
        "Continuer à aimer tes deux parents et exprimer tes émotions",
        "Résoudre leurs problèmes"
      ],
      "correct_answer": 2,
      "explanation": "Tu as le droit d''aimer tes deux parents. Et exprimer ce que tu ressens t''aidera à traverser cette période."
    }
  ]'::jsonb
);

-- Quiz Famille 3: La famille recomposée
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Vivre en famille recomposée',
  'S''adapter à une nouvelle configuration familiale.',
  'famille',
  'moyen',
  6,
  ARRAY[2,3,4],
  '[
    {
      "question": "Dans une famille recomposée, le beau-parent:",
      "answers": [
        "Remplace ton vrai parent",
        "Est une personne supplémentaire qui peut t''apporter du positif",
        "Doit être détesté par principe",
        "A tous les droits sur toi"
      ],
      "correct_answer": 1,
      "explanation": "Le beau-parent ne remplace pas ton parent. C''est une personne en plus dans ta vie, et la relation se construit avec le temps."
    },
    {
      "question": "Si tu as du mal à accepter le nouveau compagnon/la nouvelle compagne de ton parent:",
      "answers": [
        "C''est anormal, tu devrais l''aimer tout de suite",
        "C''est normal, l''adaptation prend du temps",
        "Tu dois faire semblant de l''aimer",
        "Tu dois le/la faire partir"
      ],
      "correct_answer": 1,
      "explanation": "Il est normal d''avoir besoin de temps pour s''adapter. Les sentiments ne se commandent pas."
    },
    {
      "question": "Accepter le nouveau partenaire de ton parent signifie:",
      "answers": [
        "Trahir ton autre parent",
        "Oublier ton autre parent",
        "Simplement accepter que ton parent refait sa vie",
        "Que tu n''aimes plus ton autre parent"
      ],
      "correct_answer": 2,
      "explanation": "Accepter que ton parent refait sa vie n''est pas une trahison. Tu peux aimer tes deux parents et leur souhaiter d''être heureux."
    }
  ]'::jsonb
);

-- Quiz Famille 4: Communication avec les parents
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Mieux communiquer avec ses parents',
  'Des astuces pour améliorer le dialogue avec ta famille.',
  'famille',
  'facile',
  5,
  ARRAY[2,3,4],
  '[
    {
      "question": "Pour qu''une discussion avec tes parents soit constructive:",
      "answers": [
        "Crie plus fort pour te faire entendre",
        "Choisis un bon moment et reste calme",
        "Menace de fuguer",
        "Refuse de les écouter"
      ],
      "correct_answer": 1,
      "explanation": "Le timing et le calme sont essentiels pour une discussion productive."
    },
    {
      "question": "Quand tes parents disent \"non\", tu devrais:",
      "answers": [
        "Faire une crise de colère",
        "Leur demander calmement les raisons et éventuellement proposer un compromis",
        "Ne plus jamais leur parler",
        "Désobéir systématiquement"
      ],
      "correct_answer": 1,
      "explanation": "Comprendre leurs raisons et proposer des alternatives montre ta maturité et peut parfois faire changer d''avis."
    },
    {
      "question": "L''expression \"Moi, je ressens...\" est efficace car:",
      "answers": [
        "Elle accuse l''autre personne",
        "Elle permet d''exprimer ses émotions sans attaquer",
        "Elle n''a aucun effet",
        "Elle permet de gagner toutes les disputes"
      ],
      "correct_answer": 1,
      "explanation": "Parler de ses propres ressentis (\"Je me sens triste quand...\") est moins agressif que d''accuser (\"Tu me fais toujours...\")."
    }
  ]'::jsonb
);

-- Quiz Famille 5: Les responsabilités à la maison
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Participer à la vie de famille',
  'Comprendre l''importance de contribuer à la maison.',
  'famille',
  'facile',
  5,
  ARRAY[3,4,5],
  '[
    {
      "question": "Aider à la maison est:",
      "answers": [
        "Une punition",
        "Uniquement le travail des parents",
        "Une façon normale de contribuer à la vie de famille",
        "Quelque chose à éviter à tout prix"
      ],
      "correct_answer": 2,
      "explanation": "Chaque membre de la famille peut contribuer selon ses capacités. C''est aussi une façon d''apprendre l''autonomie."
    },
    {
      "question": "Si tu trouves que tu as trop de tâches à faire:",
      "answers": [
        "Tu refuses de tout faire",
        "Tu en parles calmement pour trouver un équilibre",
        "Tu fais semblant de mal faire pour qu''on ne te demande plus",
        "Tu te plains sur les réseaux sociaux"
      ],
      "correct_answer": 1,
      "explanation": "Discuter permet de trouver une répartition plus équitable des tâches."
    },
    {
      "question": "Prendre des responsabilités à la maison t''aide à:",
      "answers": [
        "Rien du tout",
        "Développer ton autonomie pour ta vie future",
        "Perdre du temps",
        "Être puni"
      ],
      "correct_answer": 1,
      "explanation": "Les compétences acquises à la maison (cuisine, ménage, organisation) te serviront toute ta vie."
    }
  ]'::jsonb
);

-- Quiz Famille 6: Frères et soeurs
INSERT INTO quizzes (id, title, description, theme, difficulty, duration_minutes, mood_tags, questions) VALUES
(
  uuid_generate_v4(),
  'Vivre avec ses frères et soeurs',
  'Gérer les relations avec ta fratrie.',
  'famille',
  'facile',
  5,
  ARRAY[2,3,4],
  '[
    {
      "question": "Les disputes entre frères et soeurs sont:",
      "answers": [
        "Anormales et inquiétantes",
        "Normales, mais doivent rester respectueuses",
        "Une raison pour que les parents interviennent toujours",
        "Impossibles à résoudre"
      ],
      "correct_answer": 1,
      "explanation": "Les disputes sont normales dans une fratrie. L''important est de les résoudre sans violence ni méchanceté."
    },
    {
      "question": "Si tu ressens de la jalousie envers ton frère/ta soeur:",
      "answers": [
        "C''est anormal et honteux",
        "C''est un sentiment courant qu''on peut apprendre à gérer",
        "Tu dois le/la détester",
        "Tes parents ne t''aiment pas"
      ],
      "correct_answer": 1,
      "explanation": "La jalousie entre frères et soeurs est très courante. En parler aide à se sentir mieux."
    },
    {
      "question": "Une bonne relation avec ta fratrie se construit par:",
      "answers": [
        "La compétition permanente",
        "Le partage, la communication et le respect mutuel",
        "L''ignorance totale",
        "Les disputes quotidiennes"
      ],
      "correct_answer": 1,
      "explanation": "Le respect, le partage et la communication créent des liens forts qui durent toute la vie."
    }
  ]'::jsonb
);

SELECT 'Les 6 quizzes famille ont été insérés avec succès !' AS message;

-- =====================================================
-- ARTICLES SUR LE STRESS (6 articles)
-- =====================================================

-- Article Stress 1: Comprendre le stress
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Le stress: ton allié ou ton ennemi?',
  E'# Le stress: ton allié ou ton ennemi?\n\n## C''est quoi le stress?\n\nLe stress est une réaction naturelle de ton corps face à un défi ou une menace. C''est un mécanisme de survie hérité de nos ancêtres!\n\n## Le bon stress vs le mauvais stress\n\n### Le bon stress (eustress)\n\n- Te motive avant un examen\n- Te donne de l''énergie pour un match\n- T''aide à te dépasser\n\n### Le mauvais stress (distress)\n\n- Dure trop longtemps\n- Te paralyse\n- Affecte ta santé\n\n## Comment ton corps réagit au stress\n\nQuand tu es stressé(e), ton corps:\n1. Libère de l''adrénaline et du cortisol\n2. Ton cœur bat plus vite\n3. Ta respiration s''accélère\n4. Tes muscles se tendent\n\nC''est la réaction \"fight or flight\" (combattre ou fuir)!\n\n## Les signes que tu es trop stressé(e)\n\n### Physiques\n- Maux de tête\n- Maux de ventre\n- Fatigue\n- Difficultés à dormir\n\n### Émotionnels\n- Irritabilité\n- Anxiété\n- Tristesse\n- Difficulté à se concentrer\n\n## Ce qui stresse souvent les ados\n\n- Les examens et la pression scolaire\n- Les relations avec les amis\n- Les réseaux sociaux\n- Les changements corporels\n- L''avenir et l''orientation\n- Les problèmes familiaux\n\n## Rappel important\n\nLe stress est NORMAL. Ce qui compte, c''est d''apprendre à le gérer!\n\n## Ressources\n\n- Fil Santé Jeunes: 0 800 235 236\n- https://www.filsantejeunes.com',
  'Comprends ce qu''est le stress et apprends à faire la différence entre bon et mauvais stress.',
  'stress',
  ARRAY[2,3,4],
  5,
  true
);

-- Article Stress 2: Techniques anti-stress
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  '10 techniques anti-stress qui marchent vraiment',
  E'# 10 techniques anti-stress qui marchent vraiment\n\n## 1. La respiration carrée\n\n- Inspire 4 secondes\n- Retiens 4 secondes\n- Expire 4 secondes\n- Retiens 4 secondes\n- Répète 4 fois\n\n## 2. La technique 5-4-3-2-1\n\nIdentifie:\n- 5 choses que tu vois\n- 4 choses que tu touches\n- 3 choses que tu entends\n- 2 choses que tu sens\n- 1 chose que tu goûtes\n\nCette technique t''ancre dans le présent!\n\n## 3. L''activité physique\n\nLe sport libère des endorphines (hormones du bonheur) et réduit le cortisol (hormone du stress).\n\n## 4. La musique\n\nÉcouter de la musique que tu aimes peut réduire le stress en quelques minutes.\n\n## 5. Écrire\n\nTenir un journal aide à:\n- Extérioriser tes pensées\n- Prendre du recul\n- Identifier tes déclencheurs de stress\n\n## 6. La visualisation positive\n\nFerme les yeux et imagine un lieu où tu te sens bien et en sécurité. Reste-y quelques minutes.\n\n## 7. Le rire\n\nRegarder une vidéo drôle ou passer du temps avec des amis qui te font rire est un excellent anti-stress!\n\n## 8. La nature\n\nUne simple promenade en extérieur, même 15 minutes, peut réduire significativement le stress.\n\n## 9. La déconnexion\n\nFais des pauses régulières loin des écrans et des réseaux sociaux.\n\n## 10. Parler à quelqu''un\n\nPartager ce qui te stresse avec un ami ou un adulte de confiance allège le poids.\n\n## Trouve CE QUI MARCHE POUR TOI\n\nChacun est différent. Essaie ces techniques et garde celles qui te conviennent le mieux!',
  'Découvre 10 techniques simples et efficaces pour gérer ton stress au quotidien.',
  'stress',
  ARRAY[2,3,4],
  6,
  true
);

-- Article Stress 3: Stress des examens
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Gérer le stress des examens comme un pro',
  E'# Gérer le stress des examens comme un pro\n\n## Pourquoi les examens stressent?\n\n- Peur de l''échec\n- Pression des parents\n- Comparaison avec les autres\n- Enjeux pour l''avenir\n\n## AVANT l''examen\n\n### Révise intelligemment\n\n- Fais un planning de révision\n- Révise régulièrement (pas tout la veille!)\n- Alterne les matières\n- Fais des pauses toutes les 45 minutes\n\n### Prends soin de toi\n\n- Dors suffisamment (8-10h pour un ado)\n- Mange équilibré\n- Fais de l''exercice\n- Limite les écrans avant de dormir\n\n### La veille de l''examen\n\n- Arrête de réviser en début de soirée\n- Prépare tes affaires\n- Fais une activité relaxante\n- Couche-toi tôt!\n\n## PENDANT l''examen\n\n### Si tu sens la panique monter\n\n1. Pose ton stylo\n2. Ferme les yeux\n3. Prends 3 grandes respirations\n4. Dis-toi \"Je suis préparé(e), je vais y arriver\"\n5. Reprends calmement\n\n### Conseils pratiques\n\n- Lis toutes les questions d''abord\n- Commence par ce que tu sais\n- Gère bien ton temps\n- Relis avant de rendre\n\n## APRÈS l''examen\n\n- Évite de comparer tes réponses avec les autres\n- Accorde-toi une récompense\n- Passe à autre chose\n\n## Rappel important\n\nUn examen ne définit pas ta valeur. Même si ça se passe mal, tu peux toujours rebondir!\n\n## Ressources\n\n- https://www.filsantejeunes.com',
  'Tous les conseils pour réussir tes examens sans te laisser submerger par le stress.',
  'stress',
  ARRAY[2,3,4],
  6,
  false
);

-- Article Stress 4: Stress et sommeil
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Stress et sommeil: le cercle vicieux et comment en sortir',
  E'# Stress et sommeil: le cercle vicieux\n\n## Le problème\n\n- Le stress empêche de bien dormir\n- Le manque de sommeil augmente le stress\n- Et ça recommence...\n\n## Pourquoi le stress affecte ton sommeil?\n\n- Le cortisol (hormone du stress) te maintient en alerte\n- Les pensées tournent en boucle dans ta tête\n- Ton corps reste tendu\n\n## Les conséquences du manque de sommeil\n\n- Difficulté à se concentrer\n- Irritabilité\n- Moins bonne gestion des émotions\n- Système immunitaire affaibli\n- Moins bonnes performances scolaires\n\n## Comment briser le cercle?\n\n### Crée une routine du soir\n\n1. Arrête les écrans 1h avant de dormir\n2. Prends une douche tiède\n3. Lis ou écoute de la musique douce\n4. Couche-toi à heure fixe\n\n### Prépare ta chambre\n\n- Température fraîche (18-19°C)\n- Obscurité\n- Pas de téléphone près du lit\n- Un environnement calme\n\n### Si les pensées tournent...\n\nEssaie la technique du \"vidage de cerveau\":\n1. Prends un papier\n2. Écris tout ce qui te tracasse\n3. Pose le papier loin de ton lit\n4. Dis-toi: \"Je m''en occuperai demain\"\n\n### Techniques de relaxation au lit\n\n- Respiration profonde\n- Relaxation musculaire progressive\n- Visualisation d''un lieu paisible\n\n## Attention aux \"faux amis\"\n\n- Caféine après 14h\n- Écrans avant de dormir\n- Siestes trop longues\n- Activité physique intense le soir\n\n## Combien de sommeil te faut-il?\n\nÀ l''adolescence: 8 à 10 heures par nuit\n\n## Ressources\n\n- https://www.filsantejeunes.com\n- Application Petit Bambou (méditation)',
  'Comprends le lien entre stress et sommeil et apprends à retrouver des nuits paisibles.',
  'stress',
  ARRAY[2,3,4],
  5,
  false
);

-- Article Stress 5: Stress et réseaux sociaux
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Réseaux sociaux et stress: trouver l''équilibre',
  E'# Réseaux sociaux et stress: trouver l''équilibre\n\n## Pourquoi les réseaux peuvent stresser?\n\n### La comparaison constante\n\n- Les autres semblent avoir une vie parfaite\n- On compare nos \"coulisses\" à leurs \"highlights\"\n- FOMO (Fear Of Missing Out): peur de rater quelque chose\n\n### La pression sociale\n\n- Nombre de likes et followers\n- Commentaires négatifs possibles\n- Besoin de montrer une image parfaite\n\n### La disponibilité permanente\n\n- Messages à toute heure\n- Notifications incessantes\n- Impossibilité de \"déconnecter\"\n\n## Les signes que les réseaux te stressent trop\n\n- Tu vérifies ton téléphone toutes les 5 minutes\n- Tu te sens mal après avoir scrollé\n- Tu compares constamment ta vie aux autres\n- Tu as du mal à dormir à cause du téléphone\n- Tu es anxieux(se) si tu n''as pas de likes\n\n## Comment reprendre le contrôle\n\n### Fais le tri\n\n- Désabonne-toi des comptes qui te font te sentir mal\n- Suis des comptes qui t''inspirent positivement\n- Limite le nombre de personnes que tu suis\n\n### Fixe des limites\n\n- Désactive les notifications\n- Fixe-toi des plages horaires pour consulter\n- Pas de téléphone avant de dormir ni au réveil\n- Utilise les outils de limitation de temps des apps\n\n### Rappelle-toi\n\n- Les gens ne montrent que le meilleur\n- Les photos sont retouchées\n- Les likes ne définissent pas ta valeur\n- La vraie vie se passe hors écran\n\n## Le défi digital detox\n\nEssaie de passer:\n- 1 soirée sans téléphone\n- 1 journée le week-end\n- 1 semaine pendant les vacances\n\nTu verras, ce n''est pas si difficile!\n\n## Ressources\n\n- https://www.internetsanscrainte.fr\n- https://www.e-enfance.org',
  'Apprends à utiliser les réseaux sociaux sans qu''ils deviennent une source de stress.',
  'stress',
  ARRAY[2,3,4],
  5,
  false
);

-- Article Stress 6: Quand demander de l'aide
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Stress: quand et comment demander de l''aide',
  E'# Stress: quand et comment demander de l''aide\n\n## Le stress devient problématique quand...\n\n- Il dure depuis plusieurs semaines\n- Il t''empêche de vivre normalement\n- Il affecte ton sommeil, ton appétit\n- Il provoque des crises de panique\n- Tu as des pensées noires\n- Tu t''isoles de tes proches\n\n## Demander de l''aide, c''est fort!\n\nContrairement à ce qu''on pourrait penser:\n- Demander de l''aide n''est PAS une faiblesse\n- C''est un signe de maturité\n- Les professionnels sont là pour ça\n- Tu n''as pas à tout gérer seul(e)\n\n## À qui en parler?\n\n### Dans ton entourage\n\n- Un parent ou membre de la famille\n- Un ami de confiance\n- Un professeur que tu apprécies\n- L''infirmière scolaire\n- Le/la CPE\n- Un coach sportif\n\n### Les professionnels\n\n- Ton médecin traitant\n- Un psychologue\n- Un psychiatre (si nécessaire)\n\n### Les lignes d''écoute\n\n- **Fil Santé Jeunes**: 0 800 235 236 (gratuit)\n- **3114**: Prévention du suicide (24h/24)\n- **E-enfance**: 3018 (cyberharcèlement)\n\n## Comment aborder le sujet?\n\nTu peux dire simplement:\n- \"J''ai besoin de parler de quelque chose\"\n- \"Je me sens stressé(e) en ce moment\"\n- \"J''ai du mal à gérer, tu peux m''aider?\"\n- \"Je ne me sens pas bien depuis un moment\"\n\n## Ce que peut apporter l''aide professionnelle\n\n- Des techniques concrètes\n- Un espace pour parler sans jugement\n- Une compréhension de ce qui se passe\n- Un suivi adapté à ta situation\n\n## Rappel\n\nTu mérites d''aller bien. N''attends pas d''être au fond du trou pour demander de l''aide!\n\n## Ressources\n\n- Fil Santé Jeunes: https://www.filsantejeunes.com\n- Psycom: https://www.psycom.org\n- 3114: https://www.3114.fr',
  'Sache reconnaître quand le stress devient trop lourd et apprends à demander de l''aide.',
  'stress',
  ARRAY[1,2,3],
  5,
  true
);

SELECT 'Les 6 articles stress ont été insérés avec succès !' AS message;

-- =====================================================
-- ARTICLES SUR LA FAMILLE (6 articles)
-- =====================================================

-- Article Famille 1: Les conflits familiaux
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Survivre aux conflits familiaux',
  E'# Survivre aux conflits familiaux\n\n## C''est normal de se disputer\n\nToutes les familles ont des conflits. C''est une partie normale de la vie ensemble!\n\n## Les causes fréquentes de disputes\n\n- Les règles et les limites\n- Les tâches ménagères\n- Le temps d''écran\n- L''argent de poche\n- Les résultats scolaires\n- Les sorties avec les amis\n\n## Quand tes parents se disputent\n\n### Ce que tu peux ressentir\n\n- De la peur\n- De la tristesse\n- De la colère\n- De l''impuissance\n- L''envie d''intervenir\n\n### Ce qu''il faut savoir\n\n- Ce n''est PAS ta faute\n- Ce n''est pas ton rôle de les réconcilier\n- Tu as le droit de te protéger\n\n### Ce que tu peux faire\n\n- Te retirer dans ta chambre\n- Mettre de la musique ou des écouteurs\n- En parler à un adulte de confiance\n- Écrire ce que tu ressens\n\n## Quand TU es en conflit avec tes parents\n\n### Avant de réagir\n\n1. Prends quelques respirations\n2. Compte jusqu''à 10\n3. Choisis le bon moment pour discuter\n\n### Pendant la discussion\n\n- Reste calme (même si c''est dur!)\n- Utilise le \"je\" (\"Je me sens...\" plutôt que \"Tu fais toujours...\")\n- Écoute leur point de vue\n- Propose des compromis\n\n### Si ça dégénère\n\n- Propose de faire une pause\n- Reprends la discussion plus tard\n- N''hésite pas à demander l''aide d''un tiers\n\n## Rappel\n\nLes conflits font partie de la vie. Ce qui compte, c''est comment on les résout!\n\n## Ressources\n\n- Fil Santé Jeunes: 0 800 235 236',
  'Des conseils pour gérer les disputes en famille et préserver des relations saines.',
  'famille',
  ARRAY[2,3,4],
  5,
  true
);

-- Article Famille 2: Le divorce des parents
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Quand les parents se séparent: guide de survie',
  E'# Quand les parents se séparent: guide de survie\n\n## D''abord, quelques vérités\n\n- C''est N''EST PAS ta faute\n- Tu ne peux pas les réconcilier\n- Ils t''aiment toujours autant\n- Beaucoup de familles traversent ça\n\n## Les émotions que tu peux ressentir\n\nToutes ces émotions sont NORMALES:\n\n- **Tristesse**: ta famille change\n- **Colère**: contre tes parents ou la situation\n- **Soulagement**: parfois, si les disputes étaient fréquentes\n- **Confusion**: \"pourquoi?\"\n- **Culpabilité**: (mais rappelle-toi, ce n''est pas ta faute!)\n- **Peur**: de l''inconnu, des changements\n\n## Ce qui va changer\n\n- Où tu vas vivre\n- Voir tes parents différemment\n- Peut-être changer d''école\n- Les fêtes et vacances\n\n## Tes droits\n\n- Poser des questions\n- Exprimer ce que tu ressens\n- Aimer tes deux parents également\n- Ne pas être pris(e) entre les deux\n- Ne pas servir de messager\n\n## Ce que tu ne devrais PAS avoir à faire\n\n- Choisir entre tes parents\n- Porter des messages de l''un à l''autre\n- Prendre parti\n- Garder des secrets pour l''un d''eux\n- Te sentir responsable de leur bonheur\n\n## Comment traverser cette période\n\n### Parle de ce que tu ressens\n\nÀ tes parents, un autre adulte, un ami, un psy...\n\n### Garde tes repères\n\n- Continue tes activités\n- Vois tes amis\n- Maintiens tes routines\n\n### Sois patient(e)\n\nL''adaptation prend du temps. Ça ira mieux!\n\n## Ressources\n\n- Fil Santé Jeunes: 0 800 235 236\n- https://www.filsantejeunes.com',
  'Tout ce qu''il faut savoir pour traverser la séparation de tes parents.',
  'famille',
  ARRAY[1,2,3],
  6,
  true
);

-- Article Famille 3: La famille recomposée
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Vivre en famille recomposée',
  E'# Vivre en famille recomposée\n\n## C''est quoi une famille recomposée?\n\nC''est une famille où au moins un des adultes a des enfants d''une relation précédente.\n\n## Les défis à relever\n\n### Accepter le nouveau partenaire\n\n- C''est normal d''avoir des réserves\n- Ça ne veut pas dire trahir ton autre parent\n- La relation se construit avec le temps\n\n### S''adapter aux \"quasi-frères/soeurs\"\n\n- Partager l''espace\n- Apprendre à se connaître\n- Gérer les jalousies\n\n### Naviguer entre deux maisons\n\n- Avoir ses affaires dans deux endroits\n- S''adapter à des règles différentes\n- Gérer les transitions\n\n## Ce qui peut aider\n\n### Communique!\n\n- Dis ce que tu ressens\n- Pose des questions\n- Exprime tes besoins\n\n### Laisse du temps au temps\n\n- Les relations se construisent lentement\n- Sois patient(e) avec toi-même et les autres\n- Chaque famille recomposée est unique\n\n### Trouve ton espace\n\n- Un coin à toi dans chaque maison\n- Des moments seul(e) avec chaque parent\n- Tes propres routines\n\n## Le beau-parent: quelle place?\n\n### Ce qu''il/elle N''EST PAS\n\n- Un remplacement de ton parent\n- Quelqu''un qui a tous les droits sur toi\n- Obligé(e) d''être ton ami(e) tout de suite\n\n### Ce qu''il/elle PEUT être\n\n- Un adulte de plus qui peut t''aider\n- Une relation à construire à ton rythme\n- Une personne que tu apprends à connaître\n\n## Rappel\n\nAimer ou accepter un beau-parent ne trahit pas ton autre parent!\n\n## Ressources\n\n- Fil Santé Jeunes: 0 800 235 236',
  'Comment s''adapter et s''épanouir dans une famille recomposée.',
  'famille',
  ARRAY[2,3,4],
  5,
  false
);

-- Article Famille 4: Relations avec les frères et soeurs
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Frères et soeurs: du conflit à la complicité',
  E'# Frères et soeurs: du conflit à la complicité\n\n## Les disputes, c''est normal!\n\nToutes les fratries se disputent. C''est même une façon d''apprendre à gérer les conflits!\n\n## Les causes classiques de disputes\n\n- Le partage (chambre, affaires, télé...)\n- La jalousie\n- Les comparaisons\n- Les taquineries qui vont trop loin\n- Le sentiment d''injustice\n\n## La jalousie fraternelle\n\n### Pourquoi elle existe?\n\n- L''attention des parents n''est pas infinie\n- Chacun veut se sentir spécial\n- Les comparaisons font mal\n\n### Comment la gérer?\n\n- Reconnaître ce que tu ressens (c''est OK!)\n- En parler à tes parents\n- Te concentrer sur tes propres forces\n- Comprendre que chacun a ses qualités\n\n## Vers une meilleure entente\n\n### Règles de base\n\n- Respecter l''espace de l''autre\n- Demander avant d''emprunter\n- Pas de violence, ni physique ni verbale\n- S''excuser quand on a dépassé les bornes\n\n### Créer des moments positifs\n\n- Faire une activité ensemble\n- S''entraider pour les devoirs\n- Regarder un film ensemble\n- Avoir des souvenirs communs\n\n## Quand un conflit éclate\n\n1. Prends du recul\n2. Explique ton point de vue calmement\n3. Écoute le sien\n4. Cherchez une solution ensemble\n5. Si besoin, demandez l''aide d''un parent\n\n## Le bon côté des frères et soeurs\n\n- Un soutien pour toute la vie\n- Quelqu''un qui te comprend vraiment\n- Des souvenirs d''enfance partagés\n- Un allié face aux difficultés\n\n## Ressources\n\n- Fil Santé Jeunes: 0 800 235 236',
  'Comment transformer les conflits avec ta fratrie en relation complice.',
  'famille',
  ARRAY[2,3,4],
  5,
  false
);

-- Article Famille 5: Communiquer avec ses parents
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'L''art de communiquer avec ses parents',
  E'# L''art de communiquer avec ses parents\n\n## Pourquoi c''est parfois difficile?\n\n- Générations différentes\n- Besoin d''indépendance vs besoin de protection\n- Sujets tabous\n- Peur d''être jugé(e)\n- Manque de temps\n\n## Les bases d''une bonne communication\n\n### 1. Choisis le bon moment\n\n- Pas quand ils sont stressés ou fatigués\n- Pas au milieu d''une dispute\n- Trouve un moment calme\n\n### 2. Utilise le \"je\"\n\n❌ \"Tu ne me comprends jamais!\"\n✅ \"Je me sens incompris(e) quand...\"\n\n❌ \"Tu es toujours sur mon dos!\"\n✅ \"J''ai besoin de plus d''espace pour...\"\n\n### 3. Écoute aussi\n\nLa communication va dans les deux sens!\n\n### 4. Reste calme\n\nMême si c''est dur. Si tu sens la colère monter, fais une pause.\n\n## Comment aborder un sujet difficile\n\n### Prépare-toi\n\n- Réfléchis à ce que tu veux dire\n- Note les points importants\n- Anticipe leurs réactions\n\n### Commence doucement\n\n- \"J''aimerais te parler de quelque chose d''important\"\n- \"J''ai besoin de ton avis sur...\"\n- \"Il y a quelque chose qui me tracasse\"\n\n## Et si tes parents ne comprennent pas?\n\n- Reformule différemment\n- Écris-leur une lettre\n- Propose une médiation (autre adulte)\n- Donne-leur du temps\n\n## Les sujets qu''on a du mal à aborder\n\n- Les relations amoureuses\n- La santé mentale\n- Les problèmes à l''école\n- Les erreurs qu''on a faites\n\n→ Ces sujets font peur, mais en parler peut vraiment aider!\n\n## Rappel\n\nTes parents ont été ados aussi. Même s''ils semblent avoir oublié, ils peuvent comprendre plus que tu ne le penses.\n\n## Ressources\n\n- Fil Santé Jeunes: 0 800 235 236',
  'Des techniques pour améliorer le dialogue avec tes parents et te faire comprendre.',
  'famille',
  ARRAY[2,3,4],
  6,
  false
);

-- Article Famille 6: Quand ça ne va pas à la maison
INSERT INTO articles (id, title, content, summary, theme, mood_tags, reading_time_minutes, is_featured) VALUES
(
  uuid_generate_v4(),
  'Quand ça ne va pas à la maison: que faire?',
  E'# Quand ça ne va pas à la maison: que faire?\n\n## Ce qui n''est PAS normal\n\nCertaines situations ne sont pas acceptables, même si un adulte te dit le contraire:\n\n- Violence physique (coups, gifles...)\n- Violence verbale constante (insultes, humiliations)\n- Négligence (pas de nourriture, pas de soins)\n- Abus sexuel\n- Être témoin de violence conjugale\n\n## Tes droits\n\n- Tu as le droit d''être en sécurité\n- Tu as le droit d''être traité(e) avec respect\n- Tu as le droit de demander de l''aide\n- Tu as le droit d''être écouté(e)\n\n## À qui en parler?\n\n### Dans ton entourage\n\n- Un autre membre de la famille\n- Un professeur\n- L''infirmière scolaire\n- Le/la CPE\n- Un ami de la famille\n\n### Les professionnels\n\n- **119 - Allo Enfance en Danger**\n  - Gratuit et anonyme\n  - 24h/24, 7j/7\n  - Ils peuvent t''écouter et t''aider\n\n- **Police/Gendarmerie: 17**\n  - En cas de danger immédiat\n\n- **Fil Santé Jeunes: 0 800 235 236**\n  - Pour parler de tout\n\n## Ce n''est PAS ta faute\n\nQuoi qu''il se passe chez toi:\n- Tu n''es pas responsable du comportement des adultes\n- Tu mérites d''être en sécurité\n- Ce n''est pas normal de vivre dans la peur\n\n## Tu as le droit de demander de l''aide\n\nParler n''est pas trahir ta famille. C''est te protéger, et parfois c''est aussi aider ta famille à recevoir le soutien dont elle a besoin.\n\n## Ressources\n\n- **119**: Enfance en Danger (24h/24)\n- **17**: Police/Urgence\n- **3114**: Prévention du suicide\n- https://www.allo119.gouv.fr',
  'Si tu ne te sens pas en sécurité chez toi, sache que tu as le droit de demander de l''aide.',
  'famille',
  ARRAY[1,2,3],
  5,
  true
);

SELECT 'Les 6 articles famille ont été insérés avec succès !' AS message;

-- Message final de confirmation
SELECT 'Contenu additionnel inséré avec succès: 32 scénarios, 32 quiz, 27 articles !' AS final_message;
