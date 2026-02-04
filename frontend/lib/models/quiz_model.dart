class Quiz {
  final String id;
  final String title;
  final String description;
  final String theme;
  final String difficulty;
  final int durationMinutes;
  final int questionCount;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.theme,
    required this.difficulty,
    required this.durationMinutes,
    required this.questionCount,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      theme: json['theme'],
      difficulty: json['difficulty'] ?? 'moyen',
      durationMinutes: json['duration_minutes'] ?? 5,
      questionCount: json['question_count'] ?? 0,
    );
  }

  String get difficultyEmoji {
    switch (difficulty) {
      case 'facile':
        return '⭐';
      case 'moyen':
        return '⭐⭐';
      case 'difficile':
        return '⭐⭐⭐';
      default:
        return '⭐⭐';
    }
  }

  String get themeEmoji {
    switch (theme) {
      case 'stress':
        return '😰';
      case 'estime':
        return '💪';
      case 'harcelement':
        return '🛡️';
      case 'emotions':
        return '💭';
      case 'sommeil':
        return '😴';
      default:
        return '📚';
    }
  }
}

class QuizQuestion {
  final String question;
  final List<String> answers;
  final int correctAnswer;
  final String? explanation;

  QuizQuestion({
    required this.question,
    required this.answers,
    required this.correctAnswer,
    this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'],
      answers: List<String>.from(json['answers']),
      correctAnswer: json['correct_answer'],
      explanation: json['explanation'],
    );
  }
}

class QuizDetail {
  final String id;
  final String title;
  final String description;
  final String theme;
  final String difficulty;
  final int durationMinutes;
  final List<QuizQuestion> questions;

  QuizDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.theme,
    required this.difficulty,
    required this.durationMinutes,
    required this.questions,
  });

  factory QuizDetail.fromJson(Map<String, dynamic> json) {
    return QuizDetail(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      theme: json['theme'],
      difficulty: json['difficulty'] ?? 'moyen',
      durationMinutes: json['duration_minutes'] ?? 5,
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList(),
    );
  }
}

class QuizResult {
  final String resultId;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final String message;
  final List<QuestionResult> details;

  QuizResult({
    required this.resultId,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.message,
    required this.details,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      resultId: json['result_id'],
      score: json['score'],
      correctAnswers: json['correct_answers'],
      totalQuestions: json['total_questions'],
      message: json['message'],
      details: (json['details'] as List)
          .map((d) => QuestionResult.fromJson(d))
          .toList(),
    );
  }

  double get percentage => (score / 100) * 100;

  String get emoji {
    if (score >= 80) return '🎉';
    if (score >= 60) return '👍';
    if (score >= 40) return '💪';
    return '📚';
  }
}

class QuestionResult {
  final int questionIndex;
  final String question;
  final int userAnswer;
  final int correctAnswer;
  final bool isCorrect;
  final String? explanation;

  QuestionResult({
    required this.questionIndex,
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    this.explanation,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      questionIndex: json['question_index'],
      question: json['question'],
      userAnswer: json['user_answer'],
      correctAnswer: json['correct_answer'],
      isCorrect: json['is_correct'],
      explanation: json['explanation'],
    );
  }
}
