import 'package:flutter/material.dart';
import 'package:sakinah_app/widgets/custom_wigdet.dart';
import '../../constants/app_theme.dart';
import '../../services/api_service.dart';

/// Écran de vérification d'email
/// Affiché après l'inscription
class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;
  String? _message;
  bool _isSuccess = false;

  Future<void> _resendVerification() async {
    setState(() {
      _isResending = true;
      _message = null;
    });

    try {
      final result = await ApiService.resendVerification(widget.email);

      if (!mounted) return;

      setState(() {
        _message = result['success']
            ? 'Email renvoyé ! Vérifie ta boîte mail.'
            : result['error'];
        _isSuccess = result['success'];
      });
    } catch (e) {
      setState(() {
        _message = 'Erreur lors de l\'envoi. Réessaie plus tard.';
        _isSuccess = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: AppTheme.softShadow,
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // Titre
              const Text(
                'Vérifie ton email 📧',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'Un email de vérification a été envoyé à :',
                style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Email
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Instructions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.infoLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.info.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.info,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Que faire ?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStep('1', 'Ouvre ton application mail'),
                    _buildStep('2', 'Clique sur le lien de vérification'),
                    _buildStep('3', 'Reviens ici pour te connecter'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Message de feedback
              if (_message != null) ...[
                _isSuccess
                    ? SuccessMessage(message: _message!)
                    : ErrorMessage(message: _message!),
                const SizedBox(height: 16),
              ],

              // Bouton renvoyer
              SecondaryButton(
                text: 'Renvoyer l\'email',
                onPressed: _isResending ? null : _resendVerification,
                icon: Icons.refresh,
              ),

              const SizedBox(height: 16),

              // Texte d'aide
              Text(
                'Tu n\'as pas reçu l\'email ? Vérifie tes spams.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Bouton vers connexion
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: const Text('J\'ai vérifié mon email, me connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.info,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
