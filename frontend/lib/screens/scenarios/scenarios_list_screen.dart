import 'package:flutter/material.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/models/scenario_model.dart';
import 'package:sakinah_app/screens/scenarios/scenario_details_screen.dart';
import 'package:sakinah_app/services/api_service.dart';
import 'package:sakinah_app/services/progress_service.dart';

class ScenarioListScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  const ScenarioListScreen({super.key, this.onBackPressed});

  @override
  State<ScenarioListScreen> createState() => _ScenarioListScreenState();
}

class _ScenarioListScreenState extends State<ScenarioListScreen> {
  final ApiService _apiService = ApiService();
  List<Scenario> _scenarios = [];
  List<Scenario> _filteredScenarios = [];
  bool _isLoading = true;
  String? _selectedTheme;
  List<String> _themes = [];
  Set<String> _completedScenarioIds = {};

  @override
  void initState() {
    super.initState();
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _apiService.getScenarios(),
        ProgressService.getCompletedScenarioIds(),
      ]);

      final data = results[0] as Map<String, dynamic>;
      final completedIds = results[1] as Set<String>;

      final scenarios = (data['scenarios'] as List)
          .map((json) => Scenario.fromJson(json))
          .toList();

      final themes = scenarios.map((s) => s.theme).toSet().toList();
      themes.sort();

      setState(() {
        _scenarios = scenarios;
        _filteredScenarios = scenarios;
        _themes = themes;
        _completedScenarioIds = completedIds;
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

  void _filterByTheme(String? theme) {
    setState(() {
      _selectedTheme = theme;
      if (theme == null) {
        _filteredScenarios = _scenarios;
      } else {
        _filteredScenarios = _scenarios.where((s) => s.theme == theme).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_themes.isNotEmpty) _buildThemeFilter(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildScenarioList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.theater_comedy_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mises en situation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Pratique et apprends',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildThemeChip('Tous', null),
          ..._themes.map(
            (theme) => _buildThemeChip(_getThemeLabel(theme), theme),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeChip(String label, String? theme) {
    final isSelected = _selectedTheme == theme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, textAlign: TextAlign.center),
        selected: isSelected,
        onSelected: (selected) {
          _filterByTheme(selected ? theme : null);
        },
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        showCheckmark: false,
      ),
    );
  }

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'stress':
        return 'Stress 😰';
      case 'estime':
        return 'Estime de soi 💪';
      case 'harcelement':
        return 'Harcèlement 🛡️';
      case 'famille':
        return 'Famille 🏠';
      case 'emotions':
        return 'Émotions 💭';
      case 'sommeil':
        return 'Sommeil 😴';
      case 'sante_mentale':
        return 'Santé Mentale 🧠';
      case 'conflit':
        return 'Conflit 🤝';
      default:
        return theme;
    }
  }

  Widget _buildScenarioList() {
    if (_filteredScenarios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.theater_comedy_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun scénario trouvé',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadScenarios,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        itemCount: _filteredScenarios.length,
        itemBuilder: (context, index) {
          return _buildScenarioCard(_filteredScenarios[index]);
        },
      ),
    );
  }

  Widget _buildScenarioCard(Scenario scenario) {
    final isDone = _completedScenarioIds.contains(scenario.id);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScenarioDetailScreen(scenarioId: scenario.id),
          ),
        );
        final ids = await ProgressService.getCompletedScenarioIds();
        if (mounted) setState(() => _completedScenarioIds = ids);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFFF0FFF4) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isDone
              ? Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.4),
                  width: 1.5,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec gradient
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: _getThemeGradient(scenario.theme),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      scenario.themeEmoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                  if (isDone)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, color: Colors.white, size: 12),
                            SizedBox(width: 3),
                            Text(
                              'Fait',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Contenu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scenario.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        scenario.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getThemeGradient(String theme) {
    switch (theme) {
      case 'stress':
        return const LinearGradient(
          colors: [Color(0xFFFFB75E), Color(0xFFED8F03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'estime':
        return const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'harcelement':
        return const LinearGradient(
          colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'famille':
        return const LinearGradient(
          colors: [
            Color.fromARGB(255, 161, 219, 52),
            Color.fromARGB(255, 161, 219, 52),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'emotions':
        return const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'sommeil':
        return const LinearGradient(
          colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppTheme.primaryGradient;
    }
  }
}
