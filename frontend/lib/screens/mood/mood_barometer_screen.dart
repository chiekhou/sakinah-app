import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sakinah_app/providers/mood_provider.dart';

class MoodBarometerScreen extends StatefulWidget {
  final Function(int)? onMoodSelected;

  const MoodBarometerScreen({super.key, this.onMoodSelected});

  @override
  State<MoodBarometerScreen> createState() => _MoodBarometerScreenState();
}

class _MoodBarometerScreenState extends State<MoodBarometerScreen>
    with TickerProviderStateMixin {
  int? selectedMood;
  final TextEditingController _noteController = TextEditingController();
  late AnimationController _scaleController;
  late AnimationController _slideController;

  final List<Map<String, dynamic>> _moodData = [
    {
      'level': 1,
      'label': 'Très mal',
      'emoji': '😢',
      'color': const Color(0xFFE74C3C),
      'gradient': [const Color(0xFFE74C3C), const Color(0xFFC0392B)],
      'description': 'Je traverse une période difficile',
    },
    {
      'level': 2,
      'label': 'Mal',
      'emoji': '😕',
      'color': const Color(0xFFE67E22),
      'gradient': [const Color(0xFFE67E22), const Color(0xFFD35400)],
      'description': 'Je ne me sens pas bien',
    },
    {
      'level': 3,
      'label': 'Pas terrible',
      'emoji': '😐',
      'color': const Color(0xFFF39C12),
      'gradient': [const Color(0xFFF39C12), const Color(0xFFE67E22)],
      'description': 'J\'ai connu mieux',
    },
    {
      'level': 4,
      'label': 'Correct',
      'emoji': '🙂',
      'color': const Color(0xFFF1C40F),
      'gradient': [const Color(0xFFF1C40F), const Color(0xFFF39C12)],
      'description': 'Ça va, je gère',
    },
    {
      'level': 5,
      'label': 'Bien',
      'emoji': '😊',
      'color': const Color(0xFF52C41A),
      'gradient': [const Color(0xFF52C41A), const Color(0xFF389E0D)],
      'description': 'Je me sens bien',
    },
    {
      'level': 6,
      'label': 'Très bien',
      'emoji': '😄',
      'color': const Color(0xFF2ECC71),
      'gradient': [const Color(0xFF2ECC71), const Color(0xFF27AE60)],
      'description': 'Je suis de bonne humeur',
    },
    {
      'level': 7,
      'label': 'Excellent',
      'emoji': '😁',
      'color': const Color(0xFF1ABC9C),
      'gradient': [const Color(0xFF1ABC9C), const Color(0xFF16A085)],
      'description': 'Je me sens au top !',
    },
  ];

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
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

    if (widget.onMoodSelected != null) {
      widget.onMoodSelected!(selectedMood!);
    }
  }

  Color _getBackgroundColor() {
    if (selectedMood == null) return Colors.grey[50]!;
    return _moodData[selectedMood! - 1]['gradient'][0].withOpacity(0.05);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_getBackgroundColor(), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Titre animé
              SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, -1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _slideController,
                        curve: Curves.easeOut,
                      ),
                    ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        'Comment te sens-tu ?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey[800],
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choisis l\'humeur qui te correspond 💚',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Sélecteur d'humeur (prend 60% de l'écran)
              Expanded(child: _buildMoodSelector()),

              // Zone note et bouton
              if (selectedMood != null) _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _moodData.length,
      itemBuilder: (context, index) {
        final mood = _moodData[index];
        final isSelected = selectedMood == mood['level'];

        return _buildMoodCard(mood, isSelected, index);
      },
    );
  }

  Widget _buildMoodCard(Map<String, dynamic> mood, bool isSelected, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMood = mood['level'];
        });
        _scaleController.forward(from: 0);

        // Vibration légère
        // HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        height: isSelected ? 120 : 80,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: mood['gradient'],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[200]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? mood['color'].withOpacity(0.4)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Illustration manga (grand emoji stylisé)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 60 : 50,
                height: isSelected ? 60 : 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey[100],
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    mood['emoji'],
                    style: TextStyle(fontSize: isSelected ? 32 : 28),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mood['label'],
                      style: TextStyle(
                        fontSize: isSelected ? 18 : 16,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : Colors.grey[800],
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 4),
                      Text(
                        mood['description'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Icône check si sélectionné
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: mood['color'], size: 24),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Note optionnelle (compacte)
          TextField(
            controller: _noteController,
            maxLines: 2,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Ajoute une note (optionnel)...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
              counterText: '',
            ),
          ),

          const SizedBox(height: 16),

          // Bouton continuer
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submitMood,
              style: ElevatedButton.styleFrom(
                backgroundColor: _moodData[selectedMood! - 1]['color'],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
