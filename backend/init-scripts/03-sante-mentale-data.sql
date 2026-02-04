-- Ajout de contenus sur le thème "santé mentale"

-- ========================================
-- QUIZ : Comprendre la santé mentale
-- ========================================
INSERT INTO quizzes (
    id,
    title,
    description,
    theme,
    age_target_min,
    age_target_max,
    questions,
    difficulty,
    duration_minutes,
    mood_tags
) VALUES (
    uuid_generate_v4(),
    'Comprendre la santé mentale',
    'Teste tes connaissances sur la santé mentale et apprends à en prendre soin.',
    'sante_mentale',
    13,
    25,
    '[
        {
            "question": "Qu''est-ce que la santé mentale ?",
            "answers": [
                "L''absence de maladie mentale",
                "Un état de bien-être où on peut réaliser son potentiel",
                "Ne jamais avoir de problèmes",
                "Être toujours heureux"
            ],
            "correct_answer": 1,
            "explanation": "La santé mentale, c''est un état de bien-être qui permet de gérer le stress normal de la vie, de travailler de façon productive et de contribuer à sa communauté. Ce n''est pas juste l''absence de maladie !"
        },
        {
            "question": "Parler de ses problèmes avec un ami de confiance, c''est...",
            "answers": [
                "Un signe de faiblesse",
                "Embêter les autres avec ses soucis",
                "Une façon saine de prendre soin de soi",
                "Montrer qu''on est fragile"
            ],
            "correct_answer": 2,
            "explanation": "Parler de ce qu''on ressent à quelqu''un de confiance est une stratégie très saine ! Cela aide à organiser ses pensées, à se sentir moins seul et parfois à trouver des solutions."
        },
        {
            "question": "Quand on se sent dépassé, que peut-on faire ?",
            "answers": [
                "Faire comme si de rien n''était",
                "S''isoler complètement",
                "Pratiquer une activité qui nous fait du bien (sport, art, musique...)",
                "Attendre que ça passe sans rien faire"
            ],
            "correct_answer": 2,
            "explanation": "Les activités qui nous plaisent libèrent des endorphines (hormones du bien-être) et nous permettent de nous recentrer. C''est une excellente stratégie d''auto-soin !"
        }
    ]'::jsonb,
    'facile',
    5,
    ARRAY[3, 4, 5, 6]
);

-- ========================================
-- ARTICLE : C'est quoi la santé mentale ?
-- ========================================
INSERT INTO articles (
    id,
    title,
    summary,
    content,
    theme,
    mood_tags,
    age_target_min,
    age_target_max,
    reading_time_minutes,
    is_featured
) VALUES (
    uuid_generate_v4(),
    'C''est quoi la santé mentale ?',
    'Comprendre ce qu''est vraiment la santé mentale et pourquoi c''est important d''en prendre soin.',
    '# C''est quoi la santé mentale ?

La santé mentale, c''est comme la santé physique : on en a tous une et il faut en prendre soin !

## 💭 Définition simple

La santé mentale, ce n''est **pas** juste "ne pas être malade". C''est :
- Se sentir capable de gérer les hauts et les bas de la vie
- Pouvoir exprimer ses émotions
- Avoir des relations positives avec les autres
- Se sentir globalement bien dans sa tête

## 🌈 Les signes d''une bonne santé mentale

- Tu te sens capable d''affronter les défis
- Tu arrives à gérer tes émotions
- Tu as des relations saines avec ton entourage
- Tu peux demander de l''aide quand tu en as besoin
- Tu as des activités qui te font du bien

## 🚨 Quand s''inquiéter ?

Il est **normal** d''avoir des moments difficiles. Mais si tu remarques ces signes pendant plusieurs semaines :
- Tristesse ou anxiété constante
- Isolement social
- Perte d''intérêt pour tout
- Changements importants dans le sommeil ou l''appétit
- Pensées noires

➡️ **C''est le moment de parler à quelqu''un de confiance** : parent, ami, prof, infirmier scolaire, psychologue...

## 💪 Comment prendre soin de sa santé mentale ?

**1. Parle de ce que tu ressens**
Garde tes émotions pour toi, c''est comme laisser une blessure sans soin.

**2. Bouge ton corps**
Le sport libère des hormones du bonheur (endorphines).

**3. Dors suffisamment**
Le sommeil répare ton cerveau (7-9h par nuit pour les ados).

**4. Fais des choses qui te plaisent**
Musique, dessin, jeux vidéo, lecture... tout ce qui te détend !

**5. Reste connecté**
Les relations sociales sont essentielles au bien-être.

## ❤️ Message important

Demander de l''aide, ce n''est **pas** être faible. C''est être **courageux** et intelligent !

Prendre soin de ta santé mentale, c''est prendre soin de toi. Et tu le mérites. 💚',
    'sante_mentale',
    ARRAY[3, 4, 5, 6],
    6,
    25,
    6,
    true
);

-- ========================================
-- ARTICLE : 10 signes que tu dois parler à quelqu'un
-- ========================================
INSERT INTO articles (
    id,
    title,
    summary,
    content,
    theme,
    mood_tags,
    age_target_min,
    age_target_max,
    reading_time_minutes,
    is_featured
) VALUES (
    uuid_generate_v4(),
    '10 signes que tu devrais parler à quelqu''un',
    'Comment reconnaître quand on a besoin d''aide ? Voici les signes à ne pas ignorer.',
    '# 10 signes que tu devrais parler à quelqu''un

Il est parfois difficile de savoir quand demander de l''aide. Voici des signaux d''alerte :

## 🔴 Signes physiques

**1. Troubles du sommeil persistants**
Tu dors trop ou pas assez depuis plusieurs semaines.

**2. Changements d''appétit**
Tu manges beaucoup plus ou beaucoup moins que d''habitude.

**3. Fatigue constante**
Tu es épuisé même après avoir dormi.

## 🔴 Signes émotionnels

**4. Tristesse qui ne part pas**
Tu te sens triste, vide ou désespéré la plupart du temps.

**5. Anxiété envahissante**
L''inquiétude t''empêche de profiter de la vie.

**6. Colère ou irritabilité**
Tu t''énerves facilement pour des petites choses.

## 🔴 Signes comportementaux

**7. Isolement social**
Tu évites tes amis et ta famille.

**8. Perte d''intérêt**
Les choses que tu aimais ne t''intéressent plus.

**9. Difficultés de concentration**
Tu n''arrives plus à te concentrer à l''école ou au travail.

**10. Pensées inquiétantes**
Tu as des pensées de te faire du mal ou que la vie ne vaut pas la peine.

## 🆘 Que faire si tu reconnais ces signes ?

### Parle à quelqu''un de confiance
- Un parent
- Un ami proche
- Un prof
- L''infirmier scolaire
- Ton médecin

### Appelle un numéro d''aide
- **3114** : Numéro national de prévention du suicide (gratuit, 24h/24)
- **Fil Santé Jeunes** : 0 800 235 236 (gratuit, anonyme)

### Consulte un professionnel
Psychologue, psychiatre, conseiller... Ils sont là pour t''aider !

## 💚 Message important

**Demander de l''aide n''est PAS un signe de faiblesse.**

C''est la preuve que tu es assez fort pour reconnaître que tu as besoin de soutien. Et c''est exactement ce qu''il faut faire !

Tu n''es pas seul. Tu mérites d''aller mieux. 🌟',
    'sante_mentale',
    ARRAY[1, 2, 3],
    13,
    25,
    5,
    true
);

-- ========================================
-- SCÉNARIO : Reconnaître les signes de détresse chez un ami
-- ========================================
INSERT INTO scenarios (
    id,
    title,
    description,
    theme,
    steps,
    age_target_min,
    age_target_max,
    duration_minutes,
    mood_tags
) VALUES (
    uuid_generate_v4(),
    'Un ami en détresse',
    'Ton meilleur ami se comporte bizarrement ces dernières semaines. Comment réagir ?',
    'sante_mentale',
    '{
        "start": {
            "text": "Depuis quelques semaines, tu remarques que ton meilleur ami Alex a changé. Il ne vient plus aux pauses, répond à peine aux messages, et a l''air toujours fatigué. Aujourd''hui à la cantine, tu le vois assis seul dans un coin. Que fais-tu ?",
            "choices": [
                {
                    "text": "Je vais m''asseoir à côté de lui et je lui demande comment il va",
                    "next": "approche_directe"
                },
                {
                    "text": "Je l''observe de loin, je ne veux pas le déranger",
                    "next": "observation"
                },
                {
                    "text": "Je fais comme si de rien n''était, ça va sûrement passer",
                    "next": "ignorer"
                },
                {
                    "text": "J''en parle d''abord à un adulte de confiance",
                    "next": "adulte"
                }
            ]
        },
        "approche_directe": {
            "text": "Tu t''assois près de lui : \"Hey Alex, je t''ai vu un peu absent ces derniers temps. Tout va bien ?\" Il hésite, puis te dit : \"Franchement... non. Je ne me sens pas bien du tout.\"",
            "feedback": "Excellente initiative ! Tu as montré que tu te souciais de lui.",
            "choices": [
                {
                    "text": "\"Tu veux en parler ? Je suis là pour t''écouter\"",
                    "next": "ecoute_active"
                },
                {
                    "text": "\"Oh allez, c''est pas si grave, pense à autre chose !\"",
                    "next": "minimiser"
                }
            ]
        },
        "ecoute_active": {
            "text": "Alex se confie : \"Je dors mal, j''ai l''impression que rien n''a de sens, et je me sens seul même entouré...\" Il a les larmes aux yeux.",
            "feedback": "Ton écoute bienveillante lui permet de s''ouvrir. C''est important.",
            "best_practice": "Écouter sans juger est un des plus beaux cadeaux qu''on peut faire à quelqu''un en détresse.",
            "choices": [
                {
                    "text": "\"Merci de me faire confiance. As-tu pensé à en parler à un adulte qui pourrait t''aider ?\"",
                    "next": "proposition_aide"
                },
                {
                    "text": "\"Je comprends. Moi aussi parfois je me sens comme ça\"",
                    "next": "comparaison"
                }
            ]
        },
        "proposition_aide": {
            "text": "Alex : \"J''ai peur qu''on me prenne pour un fou...\" Tu lui réponds : \"Pas du tout ! Demander de l''aide c''est être courageux. Je peux t''accompagner voir l''infirmier si tu veux ?\"",
            "feedback": "Parfait ! Tu l''encourages à chercher de l''aide professionnelle tout en le soutenant.",
            "consequences": "Alex accepte. Grâce à toi, il va consulter un psychologue qui l''aidera à aller mieux. Ton soutien et ton encouragement ont fait toute la différence.",
            "best_practice": "Encourager quelqu''un à consulter un professionnel est la meilleure chose à faire. Tu n''as pas à résoudre ses problèmes seul - et c''est normal !",
            "next_action": "Continue à être présent pour ton ami, mais rappelle-toi : sa guérison ne dépend pas de toi. Tu as fait ce qu''il fallait en l''orientant vers de l''aide professionnelle."
        },
        "minimiser": {
            "text": "Alex baisse la tête : \"Ouais, tu as raison...\" Il se referme complètement et part sans finir son repas.",
            "feedback": "Minimiser les émotions de quelqu''un peut le faire sentir incompris et seul.",
            "consequences": "Alex s''isole encore plus. Il pense que personne ne peut comprendre ce qu''il vit.",
            "best_practice": "Quand quelqu''un se confie, même si ça te semble \"pas si grave\", pour lui c''est important. Écoute sans minimiser.",
            "second_chance": "Tu réalises ton erreur. Le lendemain, tu lui envoies un message : \"Désolé pour hier. Je suis vraiment là si tu veux parler.\" Il te répond positivement. Cette fois, tu l''écoutes vraiment.",
            "next_action": "Retente une approche plus empathique et propose-lui d''aller voir ensemble un adulte de confiance."
        },
        "observation": {
            "text": "Tu continues à observer de loin. Alex finit par quitter la cantine sans avoir mangé. Il a l''air encore plus triste.",
            "feedback": "Observer c''est bien, mais agir c''est mieux. Ton ami a besoin de sentir qu''on se soucie de lui.",
            "consequences": "Alex se sent invisible et de plus en plus isolé.",
            "best_practice": "Quand on remarque qu''un ami ne va pas bien, l''approcher avec bienveillance montre qu''on tient à lui.",
            "second_chance": "Tu te dis que tu ne peux pas rester sans rien faire. Tu décides d''aller lui parler après les cours.",
            "next_action": "Va vers lui et montre-lui que tu es là pour lui."
        },
        "ignorer": {
            "text": "Les jours passent. Alex s''absente de plus en plus souvent. Un jour, vous apprenez qu''il a été hospitalisé pour épuisement et dépression.",
            "feedback": "Ignorer les signes de détresse peut avoir des conséquences graves.",
            "consequences": "Alex aurait peut-être eu besoin d''aide plus tôt. Les adultes interviennent, mais tu regrettes de ne pas avoir agi.",
            "best_practice": "Les signes de détresse ne doivent jamais être ignorés. Mieux vaut se tromper en proposant son aide que de ne rien faire.",
            "next_action": "Apprends de cette situation. Si tu remarques des signes de détresse chez quelqu''un, n''hésite jamais à en parler à un adulte responsable."
        },
        "adulte": {
            "text": "Tu vas voir le CPE et lui expliques tes inquiétudes pour Alex. Il te remercie et te dit qu''il va s''en occuper avec délicatesse.",
            "feedback": "Excellent choix ! Alerter un adulte responsable quand on s''inquiète pour quelqu''un est toujours une bonne décision.",
            "consequences": "Le CPE contacte les parents d''Alex et l''infirmière scolaire. Alex commence un suivi psychologique. Il te remercie plus tard d''avoir osé en parler.",
            "best_practice": "Tu n''es pas obligé de tout gérer seul. Les adultes de confiance sont là pour aider dans ces situations.",
            "next_action": "Continue à être un bon ami pour Alex : écoute-le, inclus-le dans tes activités, mais laisse les professionnels gérer son suivi."
        },
        "comparaison": {
            "text": "Alex semble un peu soulagé mais ajoute : \"Oui mais toi tu vas mieux après. Moi ça ne passe jamais...\"",
            "feedback": "Comparer n''est pas toujours aidant. Chacun vit ses difficultés différemment.",
            "choices": [
                {
                    "text": "\"Tu as raison, c''est différent pour toi. Tu devrais peut-être en parler à quelqu''un qui peut vraiment t''aider ?\"",
                    "next": "proposition_aide"
                },
                {
                    "text": "\"T''as essayé le sport ? Moi ça m''aide\"",
                    "next": "conseil_non_sollicite"
                }
            ]
        },
        "conseil_non_sollicite": {
            "text": "Alex soupire : \"C''est pas aussi simple...\" Il change de sujet.",
            "feedback": "Donner des conseils non sollicités peut faire sentir à l''autre qu''on ne comprend pas.",
            "best_practice": "Parfois, la personne a juste besoin d''être écoutée, pas d''avoir des solutions.",
            "next_action": "Propose plutôt : \"Je suis là si tu veux parler\" et encourage-le à voir un professionnel."
        }
    }'::jsonb,
    13,
    25,
    12,
    ARRAY[1, 2, 3, 4]
);

-- Message de confirmation
SELECT 'Contenus sur la santé mentale ajoutés avec succès !' AS message;
SELECT 'Thèmes disponibles : stress, estime, harcelement, emotions, sommeil, sante_mentale' AS themes;