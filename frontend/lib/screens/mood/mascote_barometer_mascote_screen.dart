import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/providers/mood_provider.dart';

/// Version avec Mascotte Sakinah - Personnage chibi/kawaii original
class MoodBarometerMascotScreen extends StatefulWidget {
  final Function(int)? onMoodSelected;

  const MoodBarometerMascotScreen({super.key, this.onMoodSelected});

  @override
  State<MoodBarometerMascotScreen> createState() =>
      _MoodBarometerMascotScreenState();
}

class _MoodBarometerMascotScreenState extends State<MoodBarometerMascotScreen>
    with TickerProviderStateMixin {
  int? selectedMood;
  final TextEditingController _noteController = TextEditingController();
  late AnimationController _bounceController;
  late AnimationController _fadeController;

  // Données des humeurs avec la mascotte Sakinah
  final List<Map<String, dynamic>> _moodData = [
    {
      'level': 1,
      'label': 'Très mal',
      'color': const Color(0xFFE74C3C),
      'gradient': [const Color(0xFFE74C3C), const Color(0xFFC0392B)],
      'mascot': '😢', // En attendant les assets, on utilise des emojis
      'message': 'Je suis là pour toi 💙',
      'encouragement': 'Les moments difficiles passent. Tu es courageux(se) !',
    },
    {
      'level': 2,
      'label': 'Mal',
      'color': const Color(0xFFE67E22),
      'gradient': [const Color(0xFFE67E22), const Color(0xFFD35400)],
      'mascot': '😕',
      'message': 'On va y arriver ensemble 🤝',
      'encouragement': 'Prends ton temps, chaque petit pas compte.',
    },
    {
      'level': 3,
      'label': 'Pas terrible',
      'color': const Color(0xFFF39C12),
      'gradient': [const Color(0xFFF39C12), const Color(0xFFE67E22)],
      'mascot': '😐',
      'message': 'Demain sera meilleur ✨',
      'encouragement': 'C\'est normal d\'avoir des hauts et des bas.',
    },
    {
      'level': 4,
      'label': 'Correct',
      'color': const Color(0xFFF1C40F),
      'gradient': [const Color(0xFFF1C40F), const Color(0xFFF39C12)],
      'mascot': '🙂',
      'message': 'Tu tiens le bon cap 🧭',
      'encouragement': 'Continue comme ça, tu fais de ton mieux !',
    },
    {
      'level': 5,
      'label': 'Bien',
      'color': const Color(0xFF52C41A),
      'gradient': [const Color(0xFF52C41A), const Color(0xFF389E0D)],
      'mascot': '😊',
      'message': 'Super ! Continue 🌟',
      'encouragement': 'Tu rayonnes de bonne énergie !',
    },
    {
      'level': 6,
      'label': 'Très bien',
      'color': const Color(0xFF2ECC71),
      'gradient': [const Color(0xFF2ECC71), const Color(0xFF27AE60)],
      'mascot': '😄',
      'message': 'Tu es au top ! 🚀',
      'encouragement': 'C\'est génial de te voir si heureux(se) !',
    },
    {
      'level': 7,
      'label': 'Excellent',
      'color': const Color(0xFF1ABC9C),
      'gradient': [const Color(0xFF1ABC9C), const Color(0xFF16A085)],
      'mascot': '😁',
      'message': 'INCROYABLE ! 🎉',
      'encouragement': 'Ton bonheur illumine tout autour de toi !',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _bounceController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _submitMood() {
    if (selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choisis d\'abord comment tu te sens 😊'),
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

  @override
  Widget build(BuildContext context) {
    final selectedData = selectedMood != null
        ? _moodData[selectedMood! - 1]
        : null;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selectedData != null
                ? [
                    selectedData['gradient'][0].withOpacity(0.1),
                    selectedData['gradient'][1].withOpacity(0.05),
                    Colors.white,
                  ]
                : [
                    const Color(0xFF2ECC71).withOpacity(0.05),
                    Colors.white,
                    Colors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Header avec mascotte
              _buildHeader(selectedData),

              const SizedBox(height: 30),

              // Grande mascotte centrale (occupe 40% de l'écran)
              Expanded(flex: 4, child: _buildMascotDisplay(selectedData)),

              // Sélecteur d'humeur
              Expanded(flex: 3, child: _buildMoodSelector()),

              // Bottom section
              if (selectedMood != null) _buildBottomSection(selectedData!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic>? selectedData) {
    return FadeTransition(
      opacity: _fadeController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // Logo/Nom de la mascotte
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🌱', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    'Sakinah',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              selectedData != null
                  ? selectedData['message']
                  : 'Comment te sens-tu aujourd\'hui ?',
              style: TextStyle(
                fontSize: selectedData != null ? 24 : 28,
                fontWeight: FontWeight.w900,
                color: selectedData != null
                    ? selectedData['color']
                    : Colors.grey[800],
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMascotDisplay(Map<String, dynamic>? selectedData) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: selectedData != null
          ? _buildSelectedMascot(selectedData)
          : _buildDefaultMascot(),
    );
  }

  Widget _buildDefaultMascot() {
    return Center(
      key: const ValueKey('default'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mascotte neutre (grand)
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.2),
                  AppTheme.primaryColor.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text('🌱', style: const TextStyle(fontSize: 120)),
            ),
          ),

          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              'Choisis une humeur ci-dessous 👇',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedMascot(Map<String, dynamic> data) {
    return Center(
      key: ValueKey(data['level']),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Grande mascotte avec l'humeur
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: data['gradient'],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: data['color'].withOpacity(0.4),
                  blurRadius: 50,
                  spreadRadius: 15,
                ),
              ],
            ),
            child: Center(
              child: Text(
                data['mascot'],
                style: const TextStyle(fontSize: 140),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Bulle de dialogue
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: data['color'].withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  data['label'].toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: data['color'],
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['encouragement'],
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _moodData.map((mood) {
          final isSelected = selectedMood == mood['level'];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedMood = mood['level'];
              });
              _bounceController.forward(from: 0);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              width: isSelected ? 90 : 70,
              height: isSelected ? 90 : 70,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: mood['gradient'],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey[300]!,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? mood['color'].withOpacity(0.5)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: isSelected ? 20 : 10,
                    spreadRadius: isSelected ? 2 : 0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  mood['mascot'],
                  style: TextStyle(fontSize: isSelected ? 45 : 35),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomSection(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Note optionnelle
          TextField(
            controller: _noteController,
            maxLines: 2,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Raconte-moi ce que tu ressens... (optionnel)',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: data['color'].withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
              counterText: '',
            ),
          ),

          const SizedBox(height: 16),

          // Bouton avec mascotte
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _submitMood,
              style: ElevatedButton.styleFrom(
                backgroundColor: data['color'],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
                shadowColor: data['color'].withOpacity(0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(data['mascot'], style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: 12),
                  const Text(
                    'C\'est parti !',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
