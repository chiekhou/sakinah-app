import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/providers/auth_provider.dart';
import 'package:sakinah_app/services/testimonial_service.dart';

class CreateTestimonyScreen extends StatefulWidget {
  const CreateTestimonyScreen({super.key});

  @override
  State<CreateTestimonyScreen> createState() => _CreateTestimonyScreenState();
}

class _CreateTestimonyScreenState extends State<CreateTestimonyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  int? _selectedMoodLevel;
  bool _isAnonymous = true;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _moodLevels = [
    {'level': 1, 'emoji': '😢', 'label': 'Très mal', 'color': Colors.red},
    {'level': 2, 'emoji': '😕', 'label': 'Mal', 'color': Colors.deepOrange},
    {
      'level': 3,
      'emoji': '😐',
      'label': 'Pas terrible',
      'color': Colors.orange,
    },
    {'level': 4, 'emoji': '🙂', 'label': 'Correct', 'color': Colors.amber},
    {'level': 5, 'emoji': '😊', 'label': 'Bien', 'color': Colors.lightGreen},
    {
      'level': 6,
      'emoji': '😄',
      'label': 'Très bien',
      'color': AppTheme.primaryColor,
    },
    {
      'level': 7,
      'emoji': '😁',
      'label': 'Excellent',
      'color': Colors.green[700]!,
    },
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _showValidationPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Compris', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTestimony() async {
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      _showValidationPopup(
        'Témoignage vide',
        'Écris quelque chose pour partager ton témoignage avant de publier.',
      );
      return;
    }

    if (content.length < 10) {
      _showValidationPopup(
        'Témoignage trop court',
        'Ton témoignage doit contenir au moins 10 caractères.\n\nActuellement : ${content.length} caractère${content.length > 1 ? 's' : ''}.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await TestimonialService.createTestimonial(
        token: authProvider.token!,
        content: _contentController.text.trim(),
        moodLevel: _selectedMoodLevel,
        isAnonymous: _isAnonymous,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Témoignage envoyé ! Il sera visible après modération 💚',
            ),
            backgroundColor: AppTheme.primaryColor,
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.pop(context, true); // Retourner true pour recharger la liste
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Partager mon témoignage',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ton témoignage sera modéré avant publication pour garantir un espace bienveillant 💚',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contenu du témoignage
            Text(
              'Ton témoignage *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contentController,
              maxLines: 8,
              maxLength: 5000,
              decoration: InputDecoration(
                hintText:
                    'Partage ton expérience, tes ressentis, ce qui t\'aide au quotidien...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                counterStyle: TextStyle(color: Colors.grey[600]),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Écris quelque chose pour partager ton témoignage';
                }
                if (value.trim().length < 10) {
                  return 'Ton témoignage doit contenir au moins 10 caractères';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Humeur (optionnel)
            Text(
              'Comment te sens-tu ? (optionnel)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _moodLevels.map((mood) {
                final isSelected = _selectedMoodLevel == mood['level'];
                return _buildMoodChip(
                  level: mood['level'],
                  emoji: mood['emoji'],
                  label: mood['label'],
                  color: mood['color'],
                  isSelected: isSelected,
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Anonymat
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confidentialité',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _isAnonymous,
                    onChanged: (value) {
                      setState(() => _isAnonymous = value);
                    },
                    title: const Text('Publier en anonyme'),
                    subtitle: Text(
                      _isAnonymous
                          ? 'Ton pseudo ne sera pas visible'
                          : 'Ton pseudo sera affiché',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    activeThumbColor: AppTheme.primaryColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Bouton Publier
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitTestimony,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Publier mon témoignage',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Note de bas de page
            Text(
              'En publiant, tu acceptes que ton témoignage soit visible par la communauté Sakinah après modération.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodChip({
    required int level,
    required String emoji,
    required String label,
    required Color color,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMoodLevel = isSelected ? null : level;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
