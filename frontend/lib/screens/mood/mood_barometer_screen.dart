import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/providers/mood_provider.dart';

class MoodBarometerScreen extends StatefulWidget {
  final Function(int)? onMoodSelected;

  const MoodBarometerScreen({super.key, this.onMoodSelected});

  @override
  State<MoodBarometerScreen> createState() => _MoodBarometerScreenState();
}

class _MoodBarometerScreenState extends State<MoodBarometerScreen> {
  int? selectedMood;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitMood() {
    if (selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionne d\'abord ton humeur 😊'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final moodProvider = context.read<MoodProvider>();
    moodProvider.saveMood(
      moodLevel: selectedMood!,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    // Appeler le callback si fourni
    if (widget.onMoodSelected != null) {
      widget.onMoodSelected!(selectedMood!);
    } else {
      // Navigation par défaut si pas de callback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Humeur enregistrée ! ${AppTheme.getMoodEmoji(selectedMood!)}',
          ),
          backgroundColor: AppTheme.getMoodColor(selectedMood!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Titre
              Text(
                'Comment te sens-tu\naujourd\'hui ?',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Ton ressenti m\'aide à te proposer le meilleur contenu',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 40),

              // Sélecteur d'humeur
              _buildMoodSelector(),

              const SizedBox(height: 32),

              // Note optionnelle
              if (selectedMood != null) ...[
                Text(
                  'Veux-tu en dire plus ? (optionnel)',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    hintText: 'Ex: Je me sens stressé à cause d\'un examen...',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Bouton de validation
              if (selectedMood != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitMood,
                    child: const Text('Continuer'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      children: [
        // Échelle visuelle
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculer la taille dynamique en fonction de l'espace disponible
            final availableWidth = constraints.maxWidth;
            final spacing = 4.0; // Espacement entre les cercles
            final totalSpacing = spacing * 6; // 6 espacements pour 7 cercles
            final circleSize = (availableWidth - totalSpacing) / 7;
            final selectedSize =
                circleSize * 1.15; // 15% plus grand quand sélectionné

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final moodLevel = index + 1;
                final isSelected = selectedMood == moodLevel;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMood = moodLevel;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? selectedSize : circleSize,
                    height: isSelected ? selectedSize : circleSize,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.getMoodColor(moodLevel)
                          : Colors.grey[200],
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.getMoodColor(
                                  moodLevel,
                                ).withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        AppTheme.getMoodEmoji(moodLevel),
                        style: TextStyle(
                          fontSize: isSelected
                              ? (selectedSize * 0.5).clamp(20, 32)
                              : (circleSize * 0.5).clamp(16, 24),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),

        const SizedBox(height: 16),

        // Labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Très mal',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textLight),
              ),
              Text(
                'Excellent',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textLight),
              ),
            ],
          ),
        ),

        // Label de l'humeur sélectionnée
        if (selectedMood != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.getMoodColor(selectedMood!).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppTheme.getMoodEmoji(selectedMood!),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Flexible(
                  // Ajouté Flexible pour éviter le débordement du texte
                  child: Text(
                    'Tu te sens ${AppTheme.getMoodLabel(selectedMood!).toLowerCase()}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
