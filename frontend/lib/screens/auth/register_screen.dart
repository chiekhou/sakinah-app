import 'package:flutter/material.dart';
import 'package:sakinah_app/widgets/custom_wigdet.dart';
import '../../constants/app_theme.dart';
import '../../services/api_service.dart';

/// Écran d'inscription
/// Permet de choisir son rôle (Utilisateur ou Professionnel)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _professionalTitleController = TextEditingController();
  final _parentEmailController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Rôle sélectionné
  String _selectedRole = 'USER';

  // Tranche d'âge sélectionnée
  String _selectedAgeRange = '18-25';

  // Consentement parental
  bool _parentalConsentGiven = false;
  bool _showParentalConsent = false;

  // Acceptation des conditions
  bool _termsAccepted = false;

  final List<Map<String, dynamic>> _roles = [
    {
      'value': 'USER',
      'title': 'Utilisateur',
      'subtitle': 'Je recherche du soutien',
      'icon': Icons.person,
      'color': AppTheme.primary,
      'disabled': false,
    },
    {
      'value': 'PSYCHOLOGUE',
      'title': 'Psychologue',
      'subtitle': 'Je veux aider les jeunes',
      'icon': Icons.psychology,
      'color': AppTheme.info,
      'disabled': true,
      'disabledMessage':
          'Le rôle Psychologue sera disponible prochainement selon l\'évolution du projet. Restez connecté !',
    },
    {
      'value': 'EDUCATEUR',
      'title': 'Éducateur',
      'subtitle': 'Je suis éducateur spécialisé',
      'icon': Icons.school,
      'color': AppTheme.moodCalm,
      'disabled': true,
      'disabledMessage':
          'Le rôle Éducateur sera disponible prochainement selon l\'évolution du projet. Restez connecté !',
    },
    {
      'value': 'INTERVENANT',
      'title': 'Intervenant',
      'subtitle': 'J\'interviens auprès des jeunes',
      'icon': Icons.work,
      'color': AppTheme.warning,
      'disabled': true,
      'disabledMessage':
          'Le rôle Intervenant sera disponible prochainement selon l\'évolution du projet. Restez connecté !',
    },
  ];

  final List<String> _ageRanges = ['6-12', '13-17', '18-25', '25+'];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _professionalTitleController.dispose();
    _parentEmailController.dispose();
    super.dispose();
  }

  bool get _isProfessional => _selectedRole != 'USER';

  bool get _isMinor => ['6-12', '13-17'].contains(_selectedAgeRange);

  void _showValidationPopup(String title, String message, {IconData icon = Icons.warning_amber_rounded, Color iconColor = Colors.orange}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(icon, color: iconColor, size: 48),
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
                backgroundColor: AppTheme.primary,
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

  void _showEmailAlreadyUsedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.email_outlined, color: Colors.orange, size: 48),
        title: const Text(
          'Email déjà utilisé',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Cette adresse email est déjà associée à un compte Sakinah. C\'est tout à fait normal si tu t\'es déjà inscrit !\n\nTu peux te connecter directement ou réinitialiser ton mot de passe si tu l\'as oublié.',
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
          textAlign: TextAlign.center,
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Se connecter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Utiliser un autre email', style: TextStyle(color: Colors.grey[600])),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validations manuelles avec popups
    if (username.isEmpty) {
      _showValidationPopup('Pseudo manquant', 'Entre ton nom d\'utilisateur.');
      return;
    }
    if (username.length < 3) {
      _showValidationPopup('Pseudo trop court', 'Ton nom d\'utilisateur doit contenir au moins 3 caractères.');
      return;
    }
    if (email.isEmpty) {
      _showValidationPopup('Email manquant', 'Entre ton adresse email.');
      return;
    }
    if (!email.contains('@')) {
      _showValidationPopup('Email invalide', 'L\'adresse email que tu as entrée n\'est pas valide.');
      return;
    }
    if (_isProfessional && _professionalTitleController.text.trim().isEmpty) {
      _showValidationPopup('Titre manquant', 'Entre ton titre professionnel.');
      return;
    }
    if (_isMinor && _parentEmailController.text.trim().isEmpty) {
      _showValidationPopup('Email parent manquant', 'L\'email du parent ou tuteur est requis pour les mineurs.');
      return;
    }
    if (_isMinor && !_parentEmailController.text.trim().contains('@')) {
      _showValidationPopup('Email parent invalide', 'L\'adresse email du parent n\'est pas valide.');
      return;
    }
    if (password.isEmpty) {
      _showValidationPopup('Mot de passe manquant', 'Entre un mot de passe.');
      return;
    }
    if (password.length < 8) {
      _showValidationPopup('Mot de passe trop court', 'Ton mot de passe doit contenir au moins 8 caractères.\n\nActuellement : ${password.length} caractères.');
      return;
    }
    if (confirmPassword.isEmpty) {
      _showValidationPopup('Confirmation manquante', 'Confirme ton mot de passe.');
      return;
    }
    if (confirmPassword != password) {
      _showValidationPopup('Mots de passe différents', 'Les deux mots de passe ne correspondent pas.');
      return;
    }
    if (!_termsAccepted) {
      _showValidationPopup('Conditions non acceptées', 'Tu dois accepter les conditions d\'utilisation et la politique de confidentialité.');
      return;
    }
    if (_isMinor && !_parentalConsentGiven) {
      _showValidationPopup('Consentement parental requis', 'Le consentement d\'un parent ou tuteur est obligatoire pour les moins de 18 ans.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.register(
        username: username,
        email: email,
        password: password,
        ageRange: _selectedAgeRange,
        role: _selectedRole,
        professionalTitle: _isProfessional
            ? _professionalTitleController.text.trim()
            : null,
        parentEmail: _isMinor ? _parentEmailController.text.trim() : null,
      );

      if (!mounted) return;

      if (result['success']) {
        _showValidationPopup(
          'Compte créé !',
          result['message'] ?? 'Vérifie ta boîte email pour activer ton compte.',
          icon: Icons.check_circle_rounded,
          iconColor: Colors.green,
        );

        // Attendre 2 secondes puis naviguer vers l'écran de vérification email
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;

        Navigator.of(context).pushReplacementNamed(
          '/email-verification',
          arguments: email,
        );
      } else {
        final errorMsg = (result['error'] ?? '') as String;
        if (errorMsg.toLowerCase().contains('email') &&
            (errorMsg.toLowerCase().contains('déjà') ||
                errorMsg.toLowerCase().contains('already'))) {
          _showEmailAlreadyUsedDialog();
        } else {
          _showValidationPopup(
            'Inscription impossible',
            errorMsg.isEmpty ? 'Une erreur est survenue.' : errorMsg,
            icon: Icons.error_outline_rounded,
            iconColor: Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showValidationPopup(
          'Erreur',
          'Une erreur est survenue. Réessaie plus tard.',
          icon: Icons.error_outline_rounded,
          iconColor: Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Titre
                const Text(
                  'Rejoins Sakinah 🌱',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Un espace bienveillant pour ton bien-être',
                  style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Sélection du rôle
                Text(
                  'Je suis...',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                ...(_roles.map((role) => _buildRoleCard(role)).toList()),

                const SizedBox(height: 24),

                // Nom d'utilisateur
                CustomTextField(
                  controller: _usernameController,
                  labelText: 'Nom d\'utilisateur',
                  hintText: 'Pseudo',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Entre ton nom d\'utilisateur';
                    }
                    if (value.length < 3) {
                      return 'Minimum 3 caractères';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Email
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'ton-email@exemple.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Entre ton email';
                    }
                    if (!value.contains('@')) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Tranche d'âge
                Text(
                  'Tranche d\'âge',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _ageRanges.map((range) {
                    final isSelected = _selectedAgeRange == range;
                    return ChoiceChip(
                      label: Text(range),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedAgeRange = range;
                          // Afficher le consentement parental si mineur
                          _showParentalConsent = _isMinor;
                          if (!_isMinor) {
                            _parentalConsentGiven = false;
                            _parentEmailController.clear();
                          }
                        });
                      },
                      selectedColor: AppTheme.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Consentement parental (si mineur)
                if (_showParentalConsent) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.warningLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.family_restroom,
                              color: AppTheme.warning,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Consentement parental requis',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Pour les moins de 18 ans, un parent ou tuteur légal doit donner son consentement.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _parentEmailController,
                          labelText: 'Email du parent/tuteur',
                          hintText: 'parent@exemple.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (_isMinor && (value == null || value.isEmpty)) {
                              return 'Email du parent requis';
                            }
                            if (_isMinor && !value!.contains('@')) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          value: _parentalConsentGiven,
                          onChanged: (value) {
                            setState(() {
                              _parentalConsentGiven = value ?? false;
                            });
                          },
                          title: Text(
                            'En tant que parent/tuteur, j\'autorise mon enfant à utiliser Sakinah',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppTheme.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Titre professionnel (si professionnel)
                if (_isProfessional) ...[
                  CustomTextField(
                    controller: _professionalTitleController,
                    labelText: 'Titre professionnel',
                    hintText: 'Ex: Psychologue clinicien',
                    prefixIcon: Icons.work_outline,
                    validator: (value) {
                      if (_isProfessional && (value == null || value.isEmpty)) {
                        return 'Entre ton titre professionnel';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Mot de passe
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Mot de passe',
                  hintText: '••••••••',
                  prefixIcon: Icons.lock_outlined,
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixIconTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Entre ton mot de passe';
                    }
                    if (value.length < 8) {
                      return 'Minimum 8 caractères';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Confirmation mot de passe
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirme ton mot de passe',
                  hintText: '••••••••',
                  prefixIcon: Icons.lock_outlined,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixIconTap: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirme ton mot de passe';
                    }
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Acceptation des conditions
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _termsAccepted
                        ? AppTheme.primary.withValues(alpha: 0.05)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _termsAccepted
                          ? AppTheme.primary.withValues(alpha: 0.3)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _termsAccepted,
                          onChanged: (value) {
                            setState(() {
                              _termsAccepted = value ?? false;
                            });
                          },
                          activeColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'J\'accepte les conditions',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, '/terms-of-service');
                                  },
                                  child: Text(
                                    'Conditions d\'utilisation',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                Text(
                                  ' et ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, '/privacy-policy');
                                  },
                                  child: Text(
                                    'Politique de confidentialité',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton d'inscription
                PrimaryButton(
                  text: 'Créer mon compte',
                  onPressed: _isLoading ? null : _handleRegister,
                  isLoading: _isLoading,
                  icon: Icons.check,
                ),

                const SizedBox(height: 24),

                // Lien vers connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Déjà un compte ? ',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Text('Se connecter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDisabledRoleDialog(Map<String, dynamic> role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.schedule, color: AppTheme.warning, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Bientôt disponible',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: role['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(role['icon'], color: role['color'], size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      role['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: role['color'],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              role['disabledMessage'] ??
                  'Ce rôle sera disponible prochainement.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'J\'ai compris',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(Map<String, dynamic> role) {
    final isSelected = _selectedRole == role['value'];
    final isDisabled = role['disabled'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isDisabled) {
              _showDisabledRoleDialog(role);
            } else {
              setState(() {
                _selectedRole = role['value'];
              });
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Opacity(
            opacity: isDisabled ? 0.6 : 1.0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDisabled
                    ? Colors.grey.shade100
                    : (isSelected
                          ? role['color'].withOpacity(0.1)
                          : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDisabled
                      ? Colors.grey.shade300
                      : (isSelected
                            ? role['color']
                            : AppTheme.textDisabled.withOpacity(0.3)),
                  width: 2,
                ),
                boxShadow: isSelected && !isDisabled
                    ? AppTheme.cardShadow
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDisabled
                          ? Colors.grey.shade200
                          : role['color'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      role['icon'],
                      color: isDisabled ? Colors.grey : role['color'],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              role['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDisabled
                                    ? Colors.grey
                                    : (isSelected
                                          ? role['color']
                                          : AppTheme.textPrimary),
                              ),
                            ),
                            if (isDisabled) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.warning.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Bientôt',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.warning,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          role['subtitle'],
                          style: TextStyle(
                            fontSize: 13,
                            color: isDisabled
                                ? Colors.grey.shade500
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected && !isDisabled)
                    Icon(Icons.check_circle, color: role['color'], size: 24),
                  if (isDisabled)
                    Icon(
                      Icons.lock_outline,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
