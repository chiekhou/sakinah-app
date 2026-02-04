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
  String? _errorMessage;
  String? _successMessage;

  // Rôle sélectionné
  String _selectedRole = 'USER';

  // Tranche d'âge sélectionnée
  String _selectedAgeRange = '18-25';

  // Consentement parental
  bool _parentalConsentGiven = false;
  bool _showParentalConsent = false;

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
      'disabledMessage': 'Le rôle Psychologue sera disponible prochainement selon l\'évolution du projet. Restez connecté !',
    },
    {
      'value': 'EDUCATEUR',
      'title': 'Éducateur',
      'subtitle': 'Je suis éducateur spécialisé',
      'icon': Icons.school,
      'color': AppTheme.moodCalm,
      'disabled': true,
      'disabledMessage': 'Le rôle Éducateur sera disponible prochainement selon l\'évolution du projet. Restez connecté !',
    },
    {
      'value': 'INTERVENANT',
      'title': 'Intervenant',
      'subtitle': 'J\'interviens auprès des jeunes',
      'icon': Icons.work,
      'color': AppTheme.warning,
      'disabled': true,
      'disabledMessage': 'Le rôle Intervenant sera disponible prochainement selon l\'évolution du projet. Restez connecté !',
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

  Future<void> _handleRegister() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Vérifier le consentement parental pour les mineurs
    if (_isMinor && !_parentalConsentGiven) {
      setState(() {
        _errorMessage =
            'Le consentement parental est requis pour les moins de 18 ans';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        ageRange: _selectedAgeRange,
        role: _selectedRole,
        professionalTitle: _isProfessional
            ? _professionalTitleController.text.trim()
            : null,
        parentEmail: _isMinor ? _parentEmailController.text.trim() : null,
      );

      if (!mounted) return;

      if (result['success']) {
        setState(() {
          _successMessage = result['message'];
        });

        // Attendre 2 secondes puis naviguer vers l'écran de vérification email
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;

        Navigator.of(context).pushReplacementNamed(
          '/email-verification',
          arguments: _emailController.text.trim(),
        );
      } else {
        setState(() {
          _errorMessage = result['error'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur est survenue. Réessaie plus tard.';
      });
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

                // Messages
                if (_successMessage != null) ...[
                  SuccessMessage(message: _successMessage!),
                  const SizedBox(height: 20),
                ],
                if (_errorMessage != null) ...[
                  ErrorMessage(message: _errorMessage!),
                  const SizedBox(height: 20),
                ],

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
                  hintText: 'john_doe',
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

                const SizedBox(height: 32),

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.schedule,
              color: AppTheme.warning,
              size: 28,
            ),
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
              role['disabledMessage'] ?? 'Ce rôle sera disponible prochainement.',
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
                    : (isSelected ? role['color'].withOpacity(0.1) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDisabled
                      ? Colors.grey.shade300
                      : (isSelected
                          ? role['color']
                          : AppTheme.textDisabled.withOpacity(0.3)),
                  width: 2,
                ),
                boxShadow: isSelected && !isDisabled ? AppTheme.cardShadow : null,
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
                    Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
