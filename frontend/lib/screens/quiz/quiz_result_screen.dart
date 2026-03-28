import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/models/quiz_model.dart';

class QuizResultScreen extends StatefulWidget {
  final QuizResult result;
  final String quizTitle;

  const QuizResultScreen({
    super.key,
    required this.result,
    required this.quizTitle,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  late ConfettiController _confettiController;
  bool _showDetails = false;
  final _scrollController = ScrollController();
  final _detailsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    if (widget.result.score >= 60) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _confettiController.play();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        _buildScoreCard(),
                        const SizedBox(height: 20),
                        _buildStatsCards(),
                        const SizedBox(height: 20),
                        _buildDetailsButton(),
                        if (_showDetails) ...[
                          const SizedBox(height: 16),
                          _buildDetailedResults(),
                        ],
                      ],
                    ),
                  ),
                ),
                _buildActionButtons(),
              ],
            ),
          ),

          // Confettis
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppTheme.primaryColor,
                AppTheme.secondaryColor,
                AppTheme.accentColor,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    final score = widget.result.score;
    Color scoreColor;
    if (score >= 80) {
      scoreColor = AppTheme.successColor;
    } else if (score >= 60) {
      scoreColor = AppTheme.primaryColor;
    } else if (score >= 40) {
      scoreColor = AppTheme.accentColor;
    } else {
      scoreColor = AppTheme.errorColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scoreColor, scoreColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(widget.result.emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 8),
          const Text(
            'Score',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.result.score}%',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.result.message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            Icons.check_circle_rounded,
            'Correctes',
            '${widget.result.correctAnswers}',
            AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.cancel_rounded,
            'Incorrectes',
            '${widget.result.totalQuestions - widget.result.correctAnswers}',
            AppTheme.errorColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsButton() {
    return OutlinedButton.icon(
      onPressed: () {
        final wasShowing = _showDetails;
        setState(() {
          _showDetails = !_showDetails;
        });
        // Scroll vers les détails dès qu'ils apparaissent
        if (!wasShowing) {
          Future.delayed(const Duration(milliseconds: 150), () {
            if (_detailsKey.currentContext != null) {
              Scrollable.ensureVisible(
                _detailsKey.currentContext!,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          });
        }
      },
      icon: Icon(_showDetails ? Icons.expand_less : Icons.expand_more),
      label: Text(_showDetails ? 'Masquer les détails' : 'Voir les détails'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  Widget _buildDetailedResults() {
    return Column(
      key: _detailsKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Détails des réponses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.result.details.map((detail) => _buildQuestionDetail(detail)),
      ],
    );
  }

  Widget _buildQuestionDetail(QuestionResult detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: detail.isCorrect
              ? AppTheme.successColor.withValues(alpha: 0.3)
              : AppTheme.errorColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numéro et statut
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: detail.isCorrect
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${detail.questionIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                detail.isCorrect ? Icons.check_circle : Icons.cancel,
                color: detail.isCorrect
                    ? AppTheme.successColor
                    : AppTheme.errorColor,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                detail.isCorrect ? 'Bonne réponse' : 'Mauvaise réponse',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: detail.isCorrect
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Question
          Text(
            detail.question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),

          if (!detail.isCorrect) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 14,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'La bonne réponse était : ${String.fromCharCode(65 + detail.correctAnswer)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (detail.explanation != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 14,
                    color: AppTheme.infoColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      detail.explanation!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Refaire le quiz'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Accueil'),
            ),
          ),
        ],
      ),
    );
  }
}
