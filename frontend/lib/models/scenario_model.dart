class Scenario {
  final String id;
  final String title;
  final String description;
  final String theme;
  final int durationMinutes;

  Scenario({
    required this.id,
    required this.title,
    required this.description,
    required this.theme,
    required this.durationMinutes,
  });

  factory Scenario.fromJson(Map<String, dynamic> json) {
    return Scenario(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      theme: json['theme'],
      durationMinutes: json['duration_minutes'] ?? 10,
    );
  }

  String get themeEmoji {
    switch (theme) {
      case 'stress':
        return '😰';
      case 'estime':
        return '💪';
      case 'harcelement':
        return '🛡️';
      case 'famille':
        return '🏠';
      case 'emotions':
        return '💭';
      case 'sommeil':
        return '😴';
      case 'sante_mentale':
        return '🧠';
      case 'conflit':
        return '🤝';
      default:
        return '🎭';
    }
  }
}

class ScenarioDetail {
  final String id;
  final String title;
  final String description;
  final String theme;
  final int durationMinutes;
  final Map<String, ScenarioStep> steps;

  ScenarioDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.theme,
    required this.durationMinutes,
    required this.steps,
  });

  factory ScenarioDetail.fromJson(Map<String, dynamic> json) {
    final stepsJson = json['steps'] as Map<String, dynamic>;
    final steps = <String, ScenarioStep>{};

    stepsJson.forEach((key, value) {
      steps[key] = ScenarioStep.fromJson(value as Map<String, dynamic>);
    });

    return ScenarioDetail(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      theme: json['theme'],
      durationMinutes: json['duration_minutes'] ?? 10,
      steps: steps,
    );
  }

  ScenarioStep? getStep(String stepKey) {
    return steps[stepKey];
  }
}

class ScenarioStep {
  final String text;
  final List<ScenarioChoice> choices;
  final String? feedback;
  final String? consequences;
  final String? bestPractice;
  final String? nextAction;
  final String? secondChance;

  ScenarioStep({
    required this.text,
    required this.choices,
    this.feedback,
    this.consequences,
    this.bestPractice,
    this.nextAction,
    this.secondChance,
  });

  factory ScenarioStep.fromJson(Map<String, dynamic> json) {
    final choicesJson = json['choices'] as List<dynamic>? ?? [];

    return ScenarioStep(
      text: json['text'],
      choices: choicesJson
          .map((c) => ScenarioChoice.fromJson(c as Map<String, dynamic>))
          .toList(),
      feedback: json['feedback'],
      consequences: json['consequences'],
      bestPractice: json['best_practice'],
      nextAction: json['next_action'],
      secondChance: json['second_chance'],
    );
  }

  bool get isEndStep => choices.isEmpty;
}

class ScenarioChoice {
  final String text;
  final String next;

  ScenarioChoice({required this.text, required this.next});

  factory ScenarioChoice.fromJson(Map<String, dynamic> json) {
    return ScenarioChoice(text: json['text'], next: json['next']);
  }
}
