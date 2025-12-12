import 'package:flutter/material.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/services/api_service.dart';
import 'package:sakinah_app/models/scenario_model.dart';

class ScenarioDetailScreen extends StatefulWidget {
  final String scenarioId;

  const ScenarioDetailScreen({super.key, required this.scenarioId});

  @override
  State<ScenarioDetailScreen> createState() => _ScenarioDetailScreenState();
}

class _ScenarioDetailScreenState extends State<ScenarioDetailScreen> {
  final ApiService _apiService = ApiService();
  ScenarioDetail? _scenario;
  bool _isLoading = true;
  String _currentStepKey = 'start';
  final List<String> _stepHistory = [];
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _loadScenario();
  }

  Future<void> _loadScenario() async {
    try {
      final data = await _apiService.getScenario(widget.scenarioId);
      setState(() {
        _scenario = ScenarioDetail.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  void _selectChoice(String nextStepKey) {
    setState(() {
      _stepHistory.add(_currentStepKey);
      _currentStepKey = nextStepKey;
    });
  }

  void _goBack() {
    if (_stepHistory.isNotEmpty) {
      setState(() {
        _currentStepKey = _stepHistory.removeLast();
      });
    }
  }

  void _restart() {
    setState(() {
      _currentStepKey = 'start';
      _stepHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_scenario == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scénario')),
        body: const Center(child: Text('Scénario non trouvé')),
      );
    }

    if (!_hasStarted) {
      return _buildIntroScreen();
    }

    return _buildScenarioScreen();
  }

  Widget _buildIntroScreen() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: _getThemeGradient(_scenario!.theme),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Bouton retour
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      themeEmoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _scenario!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    if (_scenario!.description.isNotEmpty) ...[
                      Text(
                        _scenario!.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Info durée
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.access_time_rounded,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Durée estimée',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                'Environ ${_scenario!.durationMinutes} minutes',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Conseils
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.successColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.psychology_rounded,
                                color: AppTheme.successColor,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Comment ça marche ?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '• Tu vas vivre une situation réaliste\n'
                            '• À chaque étape, tu fais un choix\n'
                            '• Chaque choix a des conséquences\n'
                            '• Tu recevras des conseils à la fin\n'
                            '• Il n\'y a pas de "mauvaise" réponse !',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bouton commencer
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasStarted = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Commencer le scénario',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioScreen() {
    final currentStep = _scenario!.getStep(_currentStepKey);

    if (currentStep == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scénario')),
        body: const Center(child: Text('Étape non trouvée')),
      );
    }

    final isEndStep = currentStep.isEndStep;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_scenario!.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Quitter le scénario ?'),
                content: const Text('Ta progression ne sera pas sauvegardée.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continuer'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Quitter'),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          if (_stepHistory.isNotEmpty && !isEndStep)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Retour',
              onPressed: _goBack,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Situation
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: _getThemeGradient(_scenario!.theme),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.theater_comedy_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Situation',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentStep.text,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Feedback et conséquences (pour les étapes finales)
            if (isEndStep) ...[
              if (currentStep.feedback != null) ...[
                _buildInfoBox(
                  Icons.feedback_rounded,
                  'Feedback',
                  currentStep.feedback!,
                  AppTheme.infoColor,
                ),
                const SizedBox(height: 16),
              ],
              if (currentStep.consequences != null) ...[
                _buildInfoBox(
                  Icons.info_outline_rounded,
                  'Ce qui s\'est passé',
                  currentStep.consequences!,
                  AppTheme.secondaryColor,
                ),
                const SizedBox(height: 16),
              ],
              if (currentStep.bestPractice != null) ...[
                _buildInfoBox(
                  Icons.lightbulb_outline_rounded,
                  'À retenir',
                  currentStep.bestPractice!,
                  AppTheme.successColor,
                ),
                const SizedBox(height: 16),
              ],
              if (currentStep.nextAction != null) ...[
                _buildInfoBox(
                  Icons.arrow_forward_rounded,
                  'Et après ?',
                  currentStep.nextAction!,
                  AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
              ],
              if (currentStep.secondChance != null) ...[
                _buildInfoBox(
                  Icons.refresh_rounded,
                  'Seconde chance',
                  currentStep.secondChance!,
                  AppTheme.accentColor,
                ),
                const SizedBox(height: 16),
              ],
            ],

            // Choix disponibles
            if (!isEndStep && currentStep.choices.isNotEmpty) ...[
              const Text(
                'Que fais-tu ?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ...currentStep.choices.map((choice) {
                final index = currentStep.choices.indexOf(choice);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildChoiceButton(choice, index),
                );
              }),
            ],

            // Boutons de fin
            if (isEndStep) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _restart,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Recommencer'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home),
                  label: const Text('Retour aux scénarios'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(
    IconData icon,
    String title,
    String content,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(ScenarioChoice choice, int index) {
    return InkWell(
      onTap: () => _selectChoice(choice.next),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                choice.text,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  String get themeEmoji {
    switch (_scenario!.theme) {
      case 'harcelement':
        return '🛡️';
      case 'stress':
        return '😰';
      case 'conflit':
        return '🤝';
      default:
        return '🎭';
    }
  }

  LinearGradient _getThemeGradient(String theme) {
    switch (theme) {
      case 'harcelement':
        return const LinearGradient(
          colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'stress':
        return const LinearGradient(
          colors: [Color(0xFFFFB75E), Color(0xFFED8F03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'conflit':
        return const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppTheme.primaryGradient;
    }
  }
}
