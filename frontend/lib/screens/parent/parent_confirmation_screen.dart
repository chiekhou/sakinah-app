import 'package:flutter/material.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/services/parent_api_service.dart';
import 'package:sakinah_app/widgets/custom_wigdet.dart';

/// Page de confirmation du consentement parental
/// Accessible via deep link : /confirm-parental-consent/:token
class ParentConfirmationScreen extends StatefulWidget {
  final String token;

  const ParentConfirmationScreen({super.key, required this.token});

  @override
  State<ParentConfirmationScreen> createState() =>
      _ParentConfirmationScreenState();
}

class _ParentConfirmationScreenState extends State<ParentConfirmationScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Map<String, dynamic>? _consentInfo;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConsentInfo();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadConsentInfo() async {
    try {
      final result = await ParentApiService.getConsentInfo(widget.token)
          .timeout(const Duration(seconds: 15));
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (result['success'] == true) {
            _consentInfo = result;
          } else {
            _error = result['error'] ?? 'Lien invalide ou expiré';
          }
        });
      }
    } catch (e) {
      debugPrint('❌ ParentConfirmationScreen erreur: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Impossible de contacter le serveur. Vérifiez votre connexion.';
        });
      }
    }
  }

  Future<void> _handleConfirm() async {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (password.length < 8) {
      _showDialog('Mot de passe trop court',
          'Votre mot de passe doit contenir au moins 8 caractères.');
      return;
    }
    if (password != confirm) {
      _showDialog(
          'Mots de passe différents', 'Les deux mots de passe ne correspondent pas.');
      return;
    }

    setState(() => _isSubmitting = true);

    final result =
        await ParentApiService.confirmConsent(widget.token, password);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      await _showDialog(
        '🎉 Compte créé avec succès !',
        'Votre compte parent a bien été créé. Vous pouvez maintenant vous connecter avec votre email et votre mot de passe.',
        isSuccess: true,
      );
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } else {
      _showDialog('Erreur', result['error'] ?? 'Une erreur est survenue.');
    }
  }

  Future<void> _showDialog(String title, String message,
      {bool isSuccess = false}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(
          isSuccess ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
          color: isSuccess ? AppTheme.successColor : Colors.orange,
          size: 48,
        ),
        title: Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700], height: 1.5)),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSuccess ? AppTheme.primaryColor : Colors.orange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Compris',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? Center(child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(ParentApiService.baseUrl, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ))
            : _error != null
                ? _buildErrorState()
                : _buildConfirmationForm(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.link_off_rounded, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              _error ?? 'Lien invalide',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              'Ce lien est peut-être expiré ou déjà utilisé.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationForm() {
    final childUsername = _consentInfo?['child']?['username'] ?? '';
    final childAge = _consentInfo?['child']?['age_range'] ?? '';
    final parentEmail = _consentInfo?['parent_email'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // Header
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
              ),
              child: const Icon(Icons.family_restroom_rounded,
                  size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Espace Parent 💚',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Confirmez votre consentement et créez votre compte pour suivre l\'activité de votre enfant.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
          ),

          const SizedBox(height: 24),

          // Infos enfant
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FFF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.child_care_rounded,
                        color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Informations du compte',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _infoRow('Enfant', childUsername),
                _infoRow('Tranche d\'âge', '$childAge ans'),
                _infoRow('Votre email', parentEmail),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Mot de passe
          const Text(
            'Créez votre mot de passe',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Ce mot de passe vous permettra de vous connecter à votre espace parent.',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _passwordController,
            labelText: 'Mot de passe',
            hintText: 'Au moins 8 caractères',
            prefixIcon: Icons.lock_outlined,
            obscureText: _obscurePassword,
            suffixIcon: _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            onSuffixIconTap: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),

          const SizedBox(height: 16),

          CustomTextField(
            controller: _confirmPasswordController,
            labelText: 'Confirmer le mot de passe',
            hintText: '••••••••',
            prefixIcon: Icons.lock_outlined,
            obscureText: _obscureConfirm,
            suffixIcon: _obscureConfirm
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            onSuffixIconTap: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
          ),

          const SizedBox(height: 32),

          PrimaryButton(
            text: '✅ Confirmer et accéder à mon espace',
            onPressed: _isSubmitting ? null : _handleConfirm,
            isLoading: _isSubmitting,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label : ',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          Expanded(
            child: Text(value,
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }
}
